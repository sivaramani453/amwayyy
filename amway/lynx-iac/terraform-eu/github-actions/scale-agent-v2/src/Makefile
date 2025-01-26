PIP 		= $(shell which pip3)
AWS		= $(shell which aws)
UNAME 		= $(shell uname)
ARCHIVE_NAME 	= "scale-agent-v2.zip"
THIS_FILE 	:= $(lastword $(MAKEFILE_LIST))
LAMBDA_FUNC_NAME = ${LambdaFuncName}

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
	@pip3 install --target=. pymsteams
	@pip3 install --target=. PyGithub
	@pip3 install --target=. boto3

##upload: create zip archive to push to lambda
upload:
    ## we may not upload any boto* modules, as they are already installed on AWS - we keep things much smaller, by saving about 10MB
	$(info Creating zip archive ready to push to lambda func $(ARCHIVE_NAME))
	rm $(ARCHIVE_NAME) || 1
	@zip -r $(ARCHIVE_NAME) * -x 'boto*/*'
	@read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-dev-eu-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name: [${LAMBDA_FUNC_NAME}]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-${LAMBDA_FUNC_NAME}} --s3-bucket $${s3_name:-amway-dev-eu-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	rm -rf ./botocore || 1
	rm -rf ./urllib3 || 1
	
	@find . \
	  -not -name 'aws.py' \
	  -not -name 'main.py' \
	  -not -name 'Makefile' \
	  -not -name 'git.py' \
	  -not -name 'helpers.py' \
	  -not -name 'config.py' \
	  -not -name 'cache.py' \
	  -not -name 'log.py' \
	  -not -name 'queued.py' \
	  -not -name 'completed.py' \
	  -not -name 'in_progress.py' \
	  -not -name 'request.py' \
	  -not -name 'di.py' \
	  -not -name 'notificator.py' \
	  -not -name 'sqs.py' \
	  -delete
	
##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
