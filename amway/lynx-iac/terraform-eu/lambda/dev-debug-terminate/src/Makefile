PIP 		= $(shell which pip3)
AWS		= $(shell which aws)
ARCHIVE_NAME 	= "dev_debug_terminate.zip"

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


##install: create zip archive to push to lambda
install:
	$(info Creating zip archive ready to push to lambda func)
	@zip $(ARCHIVE_NAME) dev_debug_terminate.py
	@read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-dev-eu-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [DevDebugTerminate]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-DevDebugTerminate} --s3-bucket $${s3_name:-amway-dev-eu-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	@find . -not -name 'dev_debug_terminate.py' -not -name 'Makefile' -delete

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
