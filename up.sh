#!/bin/bash


env=$1
fails=""

inspect() {
  if [ $1 -ne 0 ]; then
    fails="${fails} $2"
  fi
}

# bring local dev up
dev() {
  # set env vars
  export REACT_APP_API_GATEWAY_URL=https://p8xqn5cer1.execute-api.us-east-2.amazonaws.com/v1/execute
	export REACT_APP_USERS_SERVICE_URL=http://localhost
	export REACT_APP_EXERCISES_SERVICE_URL=http://localhost
  export REACT_APP_SCORES_SERVICE_URL=http://localhost
  echo "REACT_APP_API_GATEWAY_URL=${REACT_APP_API_GATEWAY_URL}"
  echo "REACT_APP_USERS_SERVICE_URL=${REACT_APP_USERS_SERVICE_URL}"
  echo "REACT_APP_EXERCISES_SERVICE_URL=${REACT_APP_EXERCISES_SERVICE_URL}"
  echo "REACT_APP_SCORES_SERVICE_URL=${REACT_APP_SCORES_SERVICE_URL}"
  # docker up
  docker-compose up -d --build
  echo "recreate_db.."
  # recreate_db
  docker-compose exec users python manage.py recreate_db
  inspect $? users-recreate_db
  docker-compose exec exercises python manage.py recreate_db
  inspect $? exercises-recreate_db
  docker-compose exec scores python manage.py recreate_db
  inspect $? scores-recreate_db
  echo "seed_db.."
  # seed_db
  docker-compose exec users python manage.py seed_db
  inspect $? users-seed_db
  docker-compose exec exercises python manage.py seed_db
  inspect $? exercises-seed_db
  docker-compose exec scores python manage.py seed_db
  inspect $? scores-seed_db
  docker-compose logs
}

# bring local staging up
e2e() {
  # set env vars
  export REACT_APP_API_GATEWAY_URL=https://p8xqn5cer1.execute-api.us-east-2.amazonaws.com/v1/execute
	export REACT_APP_USERS_SERVICE_URL=http://localhost
	export REACT_APP_EXERCISES_SERVICE_URL=http://localhost
  # docker up
  docker-compose -f docker-compose-stage.yml up -d --build
  # recreate_db
  docker-compose -f docker-compose-stage.yml exec users python manage.py recreate_db
  inspect $? users-recreate_db
  # open cypress
  ./node_modules/.bin/cypress open \
    --config baseUrl=http://localhost \
    --env REACT_APP_API_GATEWAY_URL=$REACT_APP_API_GATEWAY_URL,LOAD_BALANCER_STAGE_DNS_NAME=http://localhost
  inspect $? e2e
}


# run appropriate tests
if [[ "${env}" == "dev" ]]; then
  echo "setting dev up!"
  dev
elif [[ "${env}" == "e2e" ]]; then
  echo "\n"
  echo "setting staging up & opening cypress!\n"
  e2e
fi

# return proper code
if [ -n "${fails}" ]; then
  echo "up for ${env} failed: ${fails}"
  exit 1
else
  echo "up for ${env} passed!"
  exit 0
fi