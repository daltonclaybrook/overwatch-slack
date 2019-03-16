#!/bin/bash

$(aws ecr get-login --no-include-email --region us-east-1)
docker build --build-arg env=docker -t overwatch .
docker tag overwatch:latest 073174792857.dkr.ecr.us-east-1.amazonaws.com/overwatch:latest
docker push 073174792857.dkr.ecr.us-east-1.amazonaws.com/overwatch:latest
aws ecs update-service --cluster overwatch2 --service overwatch2-service --task-definition overwatch --force-new-deployment
