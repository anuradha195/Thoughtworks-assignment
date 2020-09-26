#!/bin/bash

NONE='\033[00m'
GREEN='\033[01;32m'
BOLD='\033[1m'


echo -e "${GREEN}.....Installing kubectl.....${NONE}"
sudo curl --location -o /usr/local/bin/kubectl \
          https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.7/2020-07-08/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl

echo -e "${GREEN}.....Installing pip.....${NONE}"
sudo yum -y install python-pip

echo -e "${GREEN}.....Installing awscli.....${NONE}"
sudo pip install --upgrade awscli && hash -r

echo -e "${GREEN}.....Installing jq.....${NONE}"
sudo yum -y install jq gettext bash-completion moreutils

echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc


echo -e "${GREEN}.....Checking if kubectl,jq aws is in correct PATH.....${NONE}"
for command in kubectl jq envsubst aws
          do
              which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
          done

kubectl completion bash >>  ~/.bash_completion
 /etc/profile.d/bash_completion.sh
 ~/.bash_completion

echo -e "${GREEN}.....Installing eksctl.....${NONE}"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin

echo -e "${GREEN}.....Installing helm.....${NONE}"
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo -e "${GREEN}Installation complete!${NONE}"
