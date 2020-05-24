#!/bin/sh

echo "docker-deploy-stage bash script is now executing"
echo "docker-deploy-stage 'pwd' is .. $(pwd)"
echo "docker-deploy-stage 'ls -al' is .. $(ls -al)"
echo "docker-deploy-stage 'ls -al ecs' is .. $(ls -al ecs)"

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then

  if [ "$TRAVIS_BRANCH" == "staging" ]
  then

    JQ="jq --raw-output --exit-status"

    configure_aws_cli() {
        aws --version
        aws configure set default.region us-west-1
        aws configure set default.output json
        echo "AWS Configured!"
    }

    register_definition() {
      if revision=$(aws ecs register-task-definition --cli-input-json "$task_def" | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
      else
        echo "Failed to register task definition"
        return
      fi
    }

    # new
    update_service() {
      if [[ $(aws ecs update-service --cluster $cluster --service $service --task-definition $revision | $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        echo "service: $service .. cluster: $cluster .. revision:$revision"
        return
      else  
        echo "Success updating service."
        echo "service: $service .. cluster: $cluster .. revision:$revision"
      fi
      
    }

    deploy_cluster() {

      # new
      cluster="test-driven-staging-cluster"

      # users
      service="testdriven-users-stage-service"
      template="ecs_users_stage_taskdefinition.json"
      task_template=$(cat "ecs/$template")
      task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $AWS_ACCOUNT_ID)
      echo "$task_def"

      register_definition
      status=$?
      if ! $(exit $status); then
        echo "register_definition failed."
        echo "dumping current value of template: $template"
        return
      fi

      update_service
      status=$?
      if ! $(exit $status); then
        echo "register_definition failed."
        echo "dumping current value of template: $template"
        return
      fi
      

      # client
      service="testdriven-client-stage-service"
      template="ecs_client_stage_taskdefinition.json"
      task_template=$(cat "ecs/$template")
      task_def=$(printf "$task_template" $AWS_ACCOUNT_ID)
      echo "$task_def"

      register_definition
      status=$?
      if ! $(exit $status); then
        echo "register_definition failed."
        echo "dumping current value of template: $template"
      fi

      update_service
      status=$?
      if ! $(exit $status); then
        echo "register_definition failed."
        echo "dumping current value of template: $template"
      fi

      # swagger
      service="testdriven-swagger-stage-service"
      template="ecs_swagger_stage_taskdefinition.json"
      task_template=$(cat "ecs/$template")
      task_def=$(printf "$task_template" $AWS_ACCOUNT_ID)
      echo "$task_def"

      register_definition
      status=$?
      if ! $(exit $status); then
        echo "register_definition failed."
        echo "dumping current value of template: $template"
      fi

      update_service
      status=$?
      if ! $(exit $status); then
        echo "register_definition failed."
        echo "dumping current value of template: $template"
      fi


    }

    configure_aws_cli
    deploy_cluster

  fi

fi