#!/bin/bash

# This is added to ~/.bash_profile by adding 'source $microservice_app/.bash_profile_ext.sh'

export REACT_APP_USERS_SERVICE_URL="http://localhost"
printf "REACT_APP_USERS_SERVICE_URL=${REACT_APP_USERS_SERVICE_URL}"

# Docker / Flask testdriven.io commands
function myapp()
{
	winpty docker-compose -f "${MYAPPDIR}/docker-compose.yml" "$@"
}

function myapp-init()
{
	source "${MYAPPDIR}/init_dev.sh"
}

function myapp-m()
{
	winpty docker-compose -f docker-compose.yml exec users python manage.py "$@"
}

# prod stuff
function myapp-build-client-prod()
{
	docker build -f Dockerfile-prod -t "test" ./ \
	 --build-arg NODE_ENV=development \
	 --build-arg REACT_APP_USERS_SERVICE_URL=http://localhost
}

function myapp-prod-init()
{
	docker-machine start testdriven-prod && \
	docker-machine regenerate-certs testdriven-prod --force && \
	docker-machine env testdriven-prod && \
	eval $("C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env testdriven-prod) && \
	docker info
}

# up / build 
alias myapp-build="docker-compose -f docker-compose.yml up -d --build"
alias myapp-build-client="docker-compose -f docker-compose.yml up -d --build client"
alias myapp-up="docker-compose -f docker-compose.yml up"
alias myapp-build-force="docker-compose -f docker-compose.yml build --no-cache"
alias myapp-stop="docker-compose -f docker-compose.yml stop"
alias myapp-rm="docker-compose -f docker-compose.yml rm"
alias myapp-logs="docker-compose -f docker-compose.yml logs"
alias myapp-logs-tail="docker-compose -f docker-compose.yml logs --follow"
# test
alias myapp-test="winpty docker-compose -f docker-compose.yml exec users python manage.py test"
alias myapp-test-client="winpty docker-compose -f docker-compose.yml exec client npm test"
alias myapp-shell="winpty docker-compose -f docker-compose.yml exec users flask shell"
alias myapp-flake="winpty docker-compose -f docker-compose.yml exec users flake8 project"
# shell / db
alias myapp-recreate-db="winpty docker-compose -f docker-compose.yml exec users python manage.py recreate_db"
alias myapp-seed-db="winpty docker-compose -f docker-compose.yml exec users python manage.py seed_db"
alias myapp-postgres="winpty docker-compose -f docker-compose.yml exec users-db psql -U postgres"

# Docker / Amazon AWS commands
alias myapp-prod-create="docker-machine create --driver amazonec2 testdriven-prod"
alias myapp-prod-env="docker-machine env testdriven-prod"
alias myapp-prod-ip="docker-machine ip testdriven-prod"
# alias myapp-prod-build="docker-compose -f docker-compose-prod.yml up -d --build"
alias myapp-prod-test="winpty docker-compose -f docker-compose-prod.yml exec users python manage.py test"

function myapp-prod-connect()
{
	docker-machine start testdriven-prod
	docker-machine regenerate-certs -f testdriven-prod
	eval "$(docker-machine env --shell bash testdriven-prod)"
	export SECRET_KEY=$(python init_secrets.py)
	export DOCKER_MACHINE_STAGING_IP=$(docker-machine ip testdriven-prod)
	export REACT_APP_USERS_SERVICE_URL="http://$DOCKER_MACHINE_STAGING_IP"
	echo DOCKER_MACHINE_STAGING_IP=$DOCKER_MACHINE_STAGING_IP
	echo REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL
	python services/swagger/update-spec.py $REACT_APP_USERS_SERVICE_URL
}

function myapp-prod-build()
{
	export SECRET_KEY=$(python init_secrets.py)
	export DOCKER_MACHINE_STAGING_IP=$(docker-machine ip testdriven-prod)
	export REACT_APP_USERS_SERVICE_URL="http://$DOCKER_MACHINE_STAGING_IP"
	echo DOCKER_MACHINE_STAGING_IP=$DOCKER_MACHINE_STAGING_IP
	echo REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL
	python services/swagger/update-spec.py $REACT_APP_USERS_SERVICE_URL
	docker-compose -f docker-compose-prod.yml build --build -d
}

function myapp-prod-test()
{
	export SECRET_KEY=$(python init_secrets.py)
	export DOCKER_MACHINE_STAGING_IP=$(docker-machine ip testdriven-prod)
	export REACT_APP_USERS_SERVICE_URL="http://$DOCKER_MACHINE_STAGING_IP"
	docker-compose -f docker-compose-prod.yml exec users python manage.py recreate_db
	docker-compose -f docker-compose-prod.yml exec users python manage.py seed_db
	docker-compose -f docker-compose-prod.yml exec users python manage.py test
	docker-compose -f docker-compose-prod.yml exec users flake8 project
}

function myapp-stage-connect()
{
	# figure out how to do a .. if docker-machine testdriven-stage doesn't exist.. create it.. else start it..
	docker-machine create --driver amazonec2 testdriven-stage
	docker-machine start testdriven-stage
	docker-machine regenerate-certs -f testdriven-stage
	eval "$(docker-machine env --shell bash testdriven-stage)"
	export DOCKER_MACHINE_STAGING_IP=$(docker-machine ip testdriven-stage)
	export REACT_APP_USERS_SERVICE_URL="http://$DOCKER_MACHINE_STAGING_IP"
	echo DOCKER_MACHINE_STAGING_IP=$DOCKER_MACHINE_STAGING_IP
	echo REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL
	python services/swagger/update-spec.py $REACT_APP_USERS_SERVICE_URL
}

function myapp-stage-init()
{
	export DOCKER_MACHINE_STAGING_IP=$(docker-machine ip testdriven-prod)
	export REACT_APP_USERS_SERVICE_URL="http://$DOCKER_MACHINE_STAGING_IP"
	echo DOCKER_MACHINE_STAGING_IP=$DOCKER_MACHINE_STAGING_IP
	echo REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL
	python services/swagger/update-spec.py $REACT_APP_USERS_SERVICE_URL
}

function myapp-stage-test()
{
	export DOCKER_MACHINE_STAGING_IP=$(docker-machine ip testdriven-prod)
	export REACT_APP_USERS_SERVICE_URL="http://$DOCKER_MACHINE_STAGING_IP"
	docker-compose -f docker-compose-stage.yml exec users python manage.py recreate_db
	docker-compose -f docker-compose-stage.yml exec users python manage.py seed_db
	docker-compose -f docker-compose-stage.yml exec users python manage.py test
	docker-compose -f docker-compose-stage.yml exec users flake8 project
	# ./node_modules/.bin/cypress open --config baseUrl=http://$DOCKER_MACHINE_STAGING_IP
}