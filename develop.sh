#!/bin/bash

# Usage:
# 1. Make this file executable (only needed once): 'chmod +x develop.sh'
# 2. List the available commands: './develop.sh'

# Make sure the .env file is present
if  [ ! -f .env ]; then
  echo "No .env file found."
  exit 1;
fi

# Export environment variables from the root .env file to get access to the PROJECT NAME value
export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)

# Set output colors and spacing
DEFAULT="\033[0m"
CATEGORY="\033[33m"
COMMAND="\033[32m"
SPACING=" "

if [ -z "$1" ] || [ "$1" == "help" ] || [ "$1" == "commands" ]; then
  printf "${DEFAULT}Use ./develop.sh ${COMMAND}<command>${DEFAULT}\n\n"

  printf "${DEFAULT}Available ${COMMAND}commands${DEFAULT} per ${CATEGORY}category${DEFAULT}:\n"

  printf "${CATEGORY} Composer\n"
  printf "${COMMAND}   install        ${SPACING}${DEFAULT}Install composer dependencies\n"
  printf "${COMMAND}   install-dry    ${SPACING}${DEFAULT}Fake install composer dependencies\n"
  printf "${COMMAND}   outdated       ${SPACING}${DEFAULT}Show outdated composer dependencies\n"
  printf "${COMMAND}   update         ${SPACING}${DEFAULT}Update composer dependencies\n"
  printf "${COMMAND}   update-dry     ${SPACING}${DEFAULT}Fake update composer dependencies\n"

  printf "${CATEGORY} Database\n"
  printf "${COMMAND}   db             ${SPACING}${DEFAULT}Open the database\n"
  printf "${COMMAND}   dbtest         ${SPACING}${DEFAULT}Open the test database\n"
  printf "${COMMAND}   fresh|refresh  ${SPACING}${DEFAULT}Drop all tables and run all migrations\n"
  printf "${COMMAND}   fresh-seed     ${SPACING}${DEFAULT}Drop all tables and run all migrations and seeders\n"
  printf "${COMMAND}   migrate        ${SPACING}${DEFAULT}Run the database migrations\n"
  printf "${COMMAND}   seed           ${SPACING}${DEFAULT}Seed the database with records\n"

  printf "${CATEGORY} Docker\n"
  printf "${COMMAND}   build|rebuild  ${SPACING}${DEFAULT}Build the images without cache\n"
  printf "${COMMAND}   down           ${SPACING}${DEFAULT}Stop and remove the containers\n"
  printf "${COMMAND}   ps             ${SPACING}${DEFAULT}List the running containers\n"
  printf "${COMMAND}   psa            ${SPACING}${DEFAULT}List all the containers\n"
  printf "${COMMAND}   restart        ${SPACING}${DEFAULT}Restart the containers\n"
  printf "${COMMAND}   restart-down   ${SPACING}${DEFAULT}Restart the containers using down\n"
  printf "${COMMAND}   stop           ${SPACING}${DEFAULT}Stop the containers\n"
  printf "${COMMAND}   up             ${SPACING}${DEFAULT}Start the containers\n"

  printf "${CATEGORY} Inspection\n"
  printf "${COMMAND}   cov|coverage   ${SPACING}${DEFAULT}Run Pest code coverage analysis with PCOV\n"
  printf "${COMMAND}   cs             ${SPACING}${DEFAULT}Show codestyle issues with PHP-CS-Fixer\n"
  printf "${COMMAND}   fix            ${SPACING}${DEFAULT}Fix codestyle issues with PHP-CS-Fixer\n"
  printf "${COMMAND}   stan|larastan  ${SPACING}${DEFAULT}Run static analysis with larastan\n"

  printf "${CATEGORY} Logging\n"
  printf "${COMMAND}   log|logs       ${SPACING}${DEFAULT}Tail logs, use optional 1st argument to specify a service (mysql,nginx,php,redis)\n"

  printf "${CATEGORY} Npm\n"
  printf "${COMMAND}   n-install      ${SPACING}${DEFAULT}Install npm dependencies\n"
  printf "${COMMAND}   n-outdated     ${SPACING}${DEFAULT}Show outdated npm dependencies\n"
  printf "${COMMAND}   n-update       ${SPACING}${DEFAULT}Update npm dependencies\n"
  printf "${COMMAND}   run-dev        ${SPACING}${DEFAULT}Compile assets for development\n"
  printf "${COMMAND}   run-prod       ${SPACING}${DEFAULT}Compile assets for production\n"
  printf "${COMMAND}   watch          ${SPACING}${DEFAULT}Run scripts from package.json when files change\n"

  printf "${CATEGORY} Optimization\n"
  printf "${COMMAND}   cache|clear    ${SPACING}${DEFAULT}Clear all the cache\n"
  printf "${COMMAND}   ide-helper     ${SPACING}${DEFAULT}Create IDE autocompletion files\n"

  printf "${CATEGORY} Routes\n"
  printf "${COMMAND}   routes         ${SPACING}${DEFAULT}List all routes\n"
  printf "${COMMAND}   routes-method  ${SPACING}${DEFAULT}List routes filtered by method use 1st argument as filter-value\n"
  printf "${COMMAND}   routes-name    ${SPACING}${DEFAULT}List routes filtered by name, use 1st argument as filter-value\n"
  printf "${COMMAND}   routes-path    ${SPACING}${DEFAULT}List routes filtered by path, use 1st argument as filter-value\n"

  printf "${CATEGORY} Testing\n"
  printf "${COMMAND}   pest|test|tests${SPACING}${DEFAULT}Run all tests\n"

  printf "${CATEGORY} Other\n"
  printf "${COMMAND}   a|art|artisan  ${SPACING}${DEFAULT}Run artisan commands on the php container\n"
  printf "${COMMAND}   bash|enter     ${SPACING}${DEFAULT}Run bash in the php container\n"
  printf "${COMMAND}   *              ${SPACING}${DEFAULT}Anything else will be run in the php container, e.g. \"php -m | grep mysql\"\n"
  exit 0
fi

# Exit if the Docker daemon is not running
dockerResponse=$(docker info --format '{{json .}}')
if echo "${dockerResponse}" | grep -q "Is the docker daemon running?"; then
  echo "Docker is not running."
  exit 1
fi

composerPackageIsInstalled () {
  docker exec "${PROJECT_NAME}"-php composer show | grep "$1" > /dev/null
}

exitIfPhpContainerIsNotRunning () {
  if [ ! "$(docker ps -q -f name="${PROJECT_NAME}"-php)" ] || [ "$(docker inspect -f '{{.State.Running}}' "${PROJECT_NAME}"-php)" == "false" ]; then
      echo "Container '${PROJECT_NAME}-php' is not up and running."
      exit 1
  fi
}

exitIfComposerPackageIsNotInstalled () {
  exitIfPhpContainerIsNotRunning
  if ! composerPackageIsInstalled "$1"; then
    echo "Package $1 is not installed."
    exit 1
  fi
}

declare -a targets
declare -a commands
commandCounter=0

addCommandForTarget () {
  ((commandCounter++))
  targets[$commandCounter]=$1
  commands[$commandCounter]=$2
}

case "$1" in
  # Composer
  install)
    addCommandForTarget container "composer install" ;;
  install-dry)
    addCommandForTarget container "composer install --dry-run" ;;
  outdated)
    addCommandForTarget container "composer outdated" ;;
  update)
    addCommandForTarget container "composer update" ;;
  update-dry)
    addCommandForTarget container "composer update --dry-run" ;;

  # Database
  db)
    if  [ ! -f src/.env ]; then
      echo "No src/.env file found."
      exit 1;
    fi
    DB_CONNECTION=$(grep DB_CONNECTION src/.env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    DB_USERNAME=$(grep DB_USERNAME src/.env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    DB_PASSWORD=$(grep DB_PASSWORD src/.env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    DB_DATABASE=$(grep DB_DATABASE src/.env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    addCommandForTarget host "open ${DB_CONNECTION}://${DB_USERNAME}:${DB_PASSWORD}@127.0.0.1:${MYSQL_EXTERNAL_PORT}/${DB_DATABASE}" ;;
  dbtest)
    if  [ ! -f src/.env.testing ]; then
      echo "No src/.env.testing file found."
      exit 1;
    fi
    DB_CONNECTION=$(grep DB_CONNECTION src/.env.testing | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    DB_USERNAME=$(grep DB_USERNAME src/.env.testing | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    DB_PASSWORD=$(grep DB_PASSWORD src/.env.testing | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    DB_DATABASE=$(grep DB_DATABASE src/.env.testing | grep -v -e '^\s*#' | cut -d '=' -f 2-)
    addCommandForTarget host "open ${DB_CONNECTION}://${DB_USERNAME}:${DB_PASSWORD}@127.0.0.1:${MYSQL_EXTERNAL_PORT}/${DB_DATABASE}" ;;
  fresh|refresh)
    addCommandForTarget container "php artisan migrate:fresh" ;;
  fresh-seed)
    addCommandForTarget container "php artisan migrate:fresh"
    addCommandForTarget container "php artisan db:seed" ;;
  migrate)
    addCommandForTarget container "php artisan migrate" ;;
  seed)
    addCommandForTarget container "php artisan db:seed" ;;

  # Docker
  build|rebuild)
    addCommandForTarget host "docker-compose build --no-cache" ;;
  down)
    addCommandForTarget host "docker-compose down" ;;
  ps)
    addCommandForTarget host "docker-compose ps" ;;
  psa)
    addCommandForTarget host "docker-compose ps --all" ;;
  restart)
    addCommandForTarget host "docker-compose restart" ;;
  restart-down)
    addCommandForTarget host "docker-compose down"
    addCommandForTarget host "docker-compose up --detach" ;;
  stop)
    addCommandForTarget host "docker-compose stop" ;;
  up)
    addCommandForTarget hots "docker-compose up --detach" ;;

  # Inspection
  cov|coverage)
    exitIfComposerPackageIsNotInstalled pestphp/pest
    addCommandForTarget container "pest --coverage" ;;
  cs)
    exitIfComposerPackageIsNotInstalled friendsofphp/php-cs-fixer
    addCommandForTarget container "php-cs-fixer fix --dry-run --diff" ;;
  fix)
    exitIfComposerPackageIsNotInstalled friendsofphp/php-cs-fixer
    addCommandForTarget container "php-cs-fixer fix" ;;
  stan|larastan)
    exitIfComposerPackageIsNotInstalled nunomaduro/larastan
    addCommandForTarget container "phpstan analyse" ;;

  # Logging
  log|logs)
    addCommandForTarget host "docker-compose logs --follow --timestamps --tail=100 $([[ $# -gt 1 ]] && echo "$2")" ;;

  # Npm
  n-install)
    addCommandForTarget container "npm install" ;;
  n-outdated)
    addCommandForTarget container "npm outdated" ;;
  n-update)
    addCommandForTarget container "npm update" ;;
  run-dev)
    addCommandForTarget container "npm run dev" ;;
  run-prod)
    addCommandForTarget container "npm run prod" ;;
  watch)
    addCommandForTarget container "npm run watch" ;;

  # Optimization
  cache|clear)
    addCommandForTarget container "php artisan event:clear"
    addCommandForTarget container "php artisan optimize:clear" ;;
  ide-helper)
    exitIfComposerPackageIsNotInstalled barryvdh/laravel-ide-helper
    addCommandForTarget container "php artisan clear-compiled"
    addCommandForTarget container "php artisan ide-helper:generate --helpers"
    addCommandForTarget container "php artisan ide-helper:models --write"
    addCommandForTarget container "php artisan ide-helper:meta" ;;

  # Routes
  routes)
    addCommandForTarget container "php artisan route:list" ;;
  routes-method)
    addCommandForTarget container "php artisan route:list --method=$2" ;;
  routes-name)
    addCommandForTarget container "php artisan route:list --name=$2" ;;
  routes-path|routes-uri)
    addCommandForTarget container "php artisan route:list --path=$2" ;;

  # Testing
  pest|test|tests)
    addCommandForTarget container "pest" ;;

  # Other
  a|art|artisan)
    addCommandForTarget container "php artisan $([[ $# -gt 1 ]] && echo "${*:2}")" ;;
  bash|enter)
    addCommandForTarget container "bash" ;;
  *)
    addCommandForTarget container "${*}" ;;
esac

# Loop over the commands
for (( i=1; i<=${#commands[@]}; i++ ))
do
  # Run command on right target
  if [ "${targets[$i]}" == "container" ]; then
    # Check if PHP container is up and running
    exitIfPhpContainerIsNotRunning
    # Display actual command
    printf "${CATEGORY}Executing: ${DEFAULT}docker exec -it ${PROJECT_NAME}-php %s\n" "${commands[$i]}"
    # Execute command
    docker exec -it "${PROJECT_NAME}"-php ${commands[$i]}
  else
    # Display actual command
    printf "${CATEGORY}Executing: ${DEFAULT}%s\n" "${commands[$i]}"
    # Execute command
    ${commands[$i]}
  fi
done

exit 0

