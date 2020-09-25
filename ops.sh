#!/bin/bash -e
usage="ops [create|update|delete]"

# Configuration
declare region="eu-central-1"
declare clustername="mediawiki-eks-cluster"
declare sshkeyname="${clustername}-keypair"
declare kmsname="$clustername-kms"

# Go home
cd $DEVOPS_HOME

function create {
    
    echo "Creating EKS cluster"
    
    #Check if ssh key exists in AWS Systems Manager -> parameter store
    if [ -z "$(aws ec2 describe-key-pairs --key-name ${sshkeyname})" ];
    then
        generate_ssh_key
        echo "keypair has been generated and uploaded to aws"
    else 
        echo "keypair already exists"
    fi 
    
    #if kms key exists then skip or generate it
    if [ -z "$(aws kms describe-key --key-id alias/$kmsname)" ];
    then
         echo "generating kms key"
         generate_kms_key
    else
        echo "kms key already exists"
    fi

    echo "replacing environment variables in eks-cluster.yaml file"
    #sed -i 's/{\(.*\)}/{\U\1}/g' ${DEVOPS_HOME}/eks-cluster.yml
    echo "$(envsubst < ${DEVOPS_HOME}/eks-cluster.yml)" > ${DEVOPS_HOME}/eks-cluster.yml

    eksctl create cluster -f eks-cluster.yml > output.txt &
    wait
}

function update {
    
    echo "Updating Cluster"
    eksctl update cluster --config-file=$DEVOPS_HOME/eks-cluster.yml
}

function delete {

    echo "Deleting Cluster"
    eksctl delete cluster --name=${clustername}
}

function generate_ssh_key {
    
    echo "generating ssh keypair..."

    #Generate SSH key for nodes
    private_key=$(aws ec2 create-key-pair --key-name ${sshkeyname})
    echo "private_key: ${private_key}"
    
    # Put ssh key into AWS Systems Manager -> parameter store
    aws ssm put-parameter \
    --name "$sshkeyname" \
    --type SecureString \
    --description "SSH private key for ls-eks-cluster environment" \
    --value "${private_key}" \
    --tags "Key"="Owner","Value"="anuradha.gunjute" "Key"="ProjectName","Value"="LS K8s Cluster"
   
}

function generate_kms_key {
    
    #generate kms key
    aws kms create-alias \
    --alias-name alias/$kmsname \
    --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)

    export MASTER_ARN=$(aws kms describe-key --key-id alias/$kmsname --query KeyMetadata.Arn --output text)
    echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile
    
    #copy ARN key to eks-cluster.yml file
    sed -i "s~MASTER_ARN~${MASTER_ARN}~" $DEVOPS_HOME/eks-cluster.yml
    
}


case $1 in
    c|create)
        create $2
        ;;
    u|update)
        update $2
        ;;
    d|delete)
        delete $2
        ;;
    n|nothing)
        ;;
    *)
        echo "$usage"
        ;;
esac

