open terminus

tab 1 - .\node_modules\.bin\cypress open --config baseUrl=http://localhost

tab 2 - docker-compose exec client npm test

tab 3 - docker-compose up --force-recreate client

........

export REACT_APP_API_GATEWAY_URL=https://mceljmlm76.execute-api.us-west-1.amazonaws.com/v1
