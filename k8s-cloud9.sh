#!/bin/bash
set -x
date
id
pwd
export HOME=/home/ec2-user
echo '=== INSTALL Some Tools ==='
sudo yum -y -q install jq gettext bash-completion moreutils
echo '=== Configure workshop code ==='
pip install --user --upgrade awscli
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
unzip awscliv2.zip -d /tmp
sudo /tmp/aws/install -i /home/ec2-user/.local/aws -b /home/ec2-user/.local/bin --update
rm -rf aws awscliv2.zip
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform
sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.24.7/2022-10-31/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
echo "source <(kubectl completion bash)" >> /home/ec2-user/.bash_completion
echo "complete -F __start_kubectl k" >> /home/ec2-user/.bashrc
echo ". /etc/profile.d/bash_completion.sh" >> /home/ec2-user/.bashrc
echo ". /home/ec2-user/.bash_completion" >> /home/ec2-user/.bashrc
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
sudo curl -Lo /usr/local/bin/kubectl-argo-rollouts https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo chmod +x /usr/local/bin/kubectl-argo-rollouts
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
/home/ec2-user/.nvm/versions/node/v18.17.1/bin/npm  i -g c9
curl -sS https://webinstall.dev/k9s | bash
sudo curl -L https://github.com/awslabs/eks-node-viewer/releases/download/v0.2.1/eks-node-viewer_Linux_x86_64 -o /usr/local/bin/eks-node-viewer  && sudo chmod +x $_
echo "export TERM=xterm-color" >> /home/ec2-user/.bashrc
git clone --depth 1 https://github.com/junegunn/fzf.git /home/ec2-user/.fzf
/home/ec2-user/.fzf/install --all
sudo curl https://raw.githubusercontent.com/blendle/kns/master/bin/kns -o /usr/local/bin/kns && sudo chmod +x $_
sudo curl https://raw.githubusercontent.com/blendle/kns/master/bin/ktx -o /usr/local/bin/ktx && sudo chmod +x $_
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a /home/ec2-user/.bashrc
echo "alias k=kubectl" | tee -a /home/ec2-user/.bashrc
echo "alias ll='ls -la'" | tee -a /home/ec2-user/.bashrc
echo "alias kgp='kubectl get pods'" | tee -a /home/ec2-user/.bashrc
echo "alias tfi='terraform init'" | tee -a /home/ec2-user/.bashrc
echo "alias tfp='terraform plan'" | tee -a /home/ec2-user/.bashrc
echo "alias tfy='terraform apply --auto-approve'" | tee -a /home/ec2-user/.bashrc
source /home/ec2-user/.bashrc
!Sub |
                  mkdir -p /home/ec2-user/environment/code-eks-blueprint ; 
                  cd /home/ec2-user/environment/code-eks-blueprint ; 
                  echo aws s3 ls s3://${AssetsBucketName}/${AssetsBucketPrefix}/ ;
                  aws s3 ls s3://${AssetsBucketName}/${AssetsBucketPrefix} ;
                  aws s3 cp s3://${AssetsBucketName}/${AssetsBucketPrefix}code-eks-blueprint.zip .
                  unzip -o code-eks-blueprint.zip -d ~/environment/code-eks-blueprint
                - chown -R 1000:1000 /home/ec2-user/environment/code-eks-blueprint ; ls -la
                - echo '=== Exporting ENV Vars ==='
                - export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)" && echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> /home/ec2-user/.bashrc
                - export AWS_REGION="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)" && echo "export AWS_REGION=${AWS_REGION}" >> /home/ec2-user/.bashrc
                - echo "export AWS_DEFAULT_REGION=\$AWS_REGION" >>  /home/ec2-user/.bashrc
                - echo 'aws sts get-caller-identity --query Arn | grep eks-blueprints-for-terraform-workshop-admin -q || aws cloud9 update-environment  --environment-id $C9_PID --managed-credentials-action DISABLE' >> /home/ec2-user/.bashrc
                - rm -vf /home/ec2-user/.aws/credentials
                - sudo chown -R ec2-user:ec2-user /home/ec2-user/
                - echo "Bootstrap completed with return code $?"
                - shutdown -r +1