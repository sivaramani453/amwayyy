PIP 		= $(shell which pip3)
AWS		= $(shell which aws)
UNAME 		= $(shell uname)
ARCHIVE_NAME 	= "pull-requests-queue.zip"
THIS_FILE 	:= $(lastword $(MAKEFILE_LIST))

all: test build

##test: test if pip3 is installed
test: 
ifeq ($(PIP),)
	$(error pip3 not found in "$(PATH)")
else
	$(info pip3 was found)
endif
ifeq ($(AWS),)
        $(error awscli not found in "$(PATH)")
else
	$(info awscli was found)
endif

##build: install all required deps via pip3
build:
ifeq ($(UNAME), Linux)
	$(info Linux system detected)
	@$(MAKE) -f $(THIS_FILE) _build_linux
endif
ifeq ($(UNAME), Darwin)
	$(info MacOS system detected)
	@$(MAKE) -f $(THIS_FILE) _build_mac
endif


_build_mac: export CC = llvm-gcc-4.2
_build_mac: export CCX = g++-4.2
_build_mac:
	$(info building on mac with some specific args and setup.cg file)
	$(shell echo  "[install]\nprefix =" > setup.cfg)
	@pip3 install --target=. PyGithub

_build_linux:
	$(info building on linux system)
	@pip3 install --target=. PyGithub

##install: create zip archive to push to lambda
install:
	$(info Creating zip archive ready to push to lambda func)
	@zip -r $(ARCHIVE_NAME) *
	@read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; aws s3 cp pull-requests-queue.zip s3://$${s3_name:-amway-dev-eu-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [PullRequestQueueEU]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $$func_name --s3-bucket $${s3_name:-amway-dev-eu-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	@find . -not -name 'main.py' -not -name 'Makefile' -not -name 'git.py' -not -name 'helpers.py' -not -name 'config.py' -not -name 'handlers.py' -not -name 'notificator.py' -not -name 'log.py' -not -name 'dynamodb.py' -not -name 'ssm.py' -delete

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
