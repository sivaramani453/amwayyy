AWS		= $(shell which aws)
UNAME 		= $(shell uname)
ARCHIVE_NAME 	= "curator.zip"
THIS_FILE 	:= $(lastword $(MAKEFILE_LIST))

all: test build

##test: test if awscli is installed
test:
ifeq ($(AWS),)
        $(error awscli not found in "$(PATH)")
else
	$(info awscli was found)
endif

##build: install dependencies via pip3
build:
	$(info Install dependencies for the lambda function)
	docker run --rm -it -w /app -v ${PWD}:/app python:3.7-slim bash -c "pip3 install --target=. elasticsearch elasticsearch-curator requests_aws4auth"

##clean: delete all deps form src dir
clean:
	$(info Deleting dependencies)
	@find . -not -name 'clean_docs.py' -not -name 'Makefile' -delete 

##install: create zip archive to push to lambda
install:
	$(info Creating zip archive and push it to the lambda function)
	@zip -r $(ARCHIVE_NAME) * -x $(ARCHIVE_NAME)
	@read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-dev-eu-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [ElasticSearchCurator]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-ElasticSearchCurator} --s3-bucket $${s3_name:-amway-dev-eu-lambda-functions} --s3-key $(ARCHIVE_NAME)

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
