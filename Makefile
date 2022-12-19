BACKEND_SERVICE=api
APPS_FOLDER_NAME=apps

# colors
GREEN = $(shell tput -Txterm setaf 2)
YELLOW = $(shell tput -Txterm setaf 3)
WHITE = $(shell tput -Txterm setaf 7)
RESET = $(shell tput -Txterm sgr0)
GRAY = $(shell tput -Txterm setaf 6)
TARGET_MAX_CHAR_NUM = 20

# Common

all: run

## Runs application. Builds, creates, starts, and attaches to containers for a service. | Common
run:
	@docker-compose up $(BACKEND_SERVICE)

## Runs entire application with `docker-compose up`
up:
	@docker-compose up

## Rebuild web container
build:
	@docker-compose build

## Runs application on service ports.
debug:
	@docker-compose run --service-ports --rm $(BACKEND_SERVICE)

## Stops application. Stops running container without removing them.
stop:
	@docker-compose stop

## Removes stopped service containers.
clean:
	@docker-compose down

## Runs command `bash` commands in docker container.
bash:
	@docker-compose exec $(BACKEND_SERVICE) bash

## Runs command `bash` commands in docker container.
python:
	@docker-compose exec $(BACKEND_SERVICE) ipython

## Django debug shell
shell:
	@docker-compose exec $(BACKEND_SERVICE) ./manage.py shell

## Load fixture data
loaddata:
	@docker-compose exec $(BACKEND_SERVICE) ./manage.py loaddata apps

# Help

## Shows help.
help:
	@echo ''
	@echo 'Usage:'
	@echo ''
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
		    if (index(lastLine, "|") != 0) { \
				stage = substr(lastLine, index(lastLine, "|") + 1); \
				printf "\n ${GRAY}%s: \n\n", stage;  \
			} \
			helpCommand = substr($$1, 1, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			if (index(lastLine, "|") != 0) { \
				helpMessage = substr(helpMessage, 0, index(helpMessage, "|")-1); \
			} \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''

# Docs

# Linters & tests

## Formats code with `black`. | Linters
black:
	@docker-compose run --rm $(BACKEND_SERVICE) black $(APPS_FOLDER_NAME)

## Formats code with `flake8`.
lint:
	@docker-compose run --rm $(BACKEND_SERVICE) flake8 $(APPS_FOLDER_NAME)

# Database

## Runs PostgreSQL UI. | Database
psql:
	@docker-compose exec postgres psql -U postgres

## Create DB dump.
pg-dump:
	@docker-compose exec -T $(BACKEND_SERVICE) pg_dump -U postgres -h postgres -W -F t postgres > dump.tar

## Restore DB dump.
pg-restore:
	@docker-compose exec -T $(BACKEND_SERVICE) pg_restore -d postgres dump.tar -c -U postgres -h postgres

## Makes migrations. 'make migrations'
migrations:
	@docker-compose run --rm $(BACKEND_SERVICE) ./manage.py makemigrations

## Upgrades database.
migrate:
	@docker-compose run --rm $(BACKEND_SERVICE) ./manage.py migrate

## History of a database.
history:
	@docker-compose run --rm $(BACKEND_SERVICE) ./manage.py showmigrations


## Runs tests.
test:
	@docker-compose run --rm $(BACKEND_SERVICE) ./manage.py test

## Generate locales files
makemessages:
	@docker-compose run --rm $(BACKEND_SERVICE) ./manage.py makemessages

## Compile locales files
compilemessages:
	@docker-compose run --rm $(BACKEND_SERVICE) ./manage.py compilemessages
