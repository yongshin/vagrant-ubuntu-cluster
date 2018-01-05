#!/bin/bash

export GITLAB_TOKEN=<gitlab token>

# Create users
curl --insecure --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --header "Content-Type:application/json" https://gitlab.local/api/v3/users -d "{ \"name\": \"docker\", \"username\": \"docker\", \"password\": \"docker123\", \"email\": \"docker@docker.local\" }"
curl --insecure --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --header "Content-Type:application/json" https://gitlab.local/api/v3/users -d "{ \"name\": \"jenkins\", \"username\": \"jenkins\", \"password\": \"docker123\", \"email\": \"jenkins@docker.local\" }"

# Generate SSH Key
ssh-keygen -t rsa -C "docker@docker.local" -f files/id_rsa -q -N ""
export SSH_KEY_GITLAB=$(cat files/id_rsa.pub)

# Add SSH Key for pushing
curl --insecure --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --header "Content-Type:application/json" https://gitlab.local/api/v3/users/2/keys -d "{ \"title\": \"docker-ssh-key\", \"key\": \"$SSH_KEY_GITLAB\" }"

# Clone repo from Github and Push to gitlab.local
git clone https://github.com/yongshin/docker-node-app
cd docker-node-app
git remote rename origin old-origin
git remote add origin git@gitlab.local:root/docker-node-app.git
GIT_SSH_COMMAND="ssh -i files/id_rsa" git push -u origin --all
GIT_SSH_COMMAND="ssh -i files/id_rsa" git push -u origin --tags

# Create Docker Node App project
curl --insecure --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --header "Content-Type:application/json" https://gitlab.local/api/v3/projects/user/2 -d "{ \"name\": \"docker-node-app\" }"

# Create Project webhook
curl --insecure --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --header "Content-Type:application/json" https://gitlab.local/api/v3/projects/1/hooks -d "{ \"url\": \"http://jenkins.local\" }"
