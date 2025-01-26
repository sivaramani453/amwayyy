PIP 		= $(shell which pip3)
AWS		= $(shell which aws)
ARCHIVE_NAME 	= "ec2_overseer.zip"


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


build:
	$(info building on linux system)
	@pip3 install --target=. requests

##install: create zip archive to push to lambda
install:
	$(info Creating zip archive ready to push to lambda func)
	@zip -r $(ARCHIVE_NAME) *
	@read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-dev-eu-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [EC2Overseer]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-EC2Overseer} --s3-bucket $${s3_name:-amway-dev-eu-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	@find . -not -name 'ec2_overseer.py' -not -name 'Makefile' -delete

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
