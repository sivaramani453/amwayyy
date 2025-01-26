ARCHIVE_NAME 	= "ec2_overseer.zip"

##install: create zip archive to push to lambda
install:
	$(info Creating zip archive ready to push to lambda func)
	@zip $(ARCHIVE_NAME) ec2_overseer.py
	@read -p "Enter S3 bucket Name [amway-dev-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-dev-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [EC2Overseer]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-EC2Overseer} --s3-bucket $${s3_name:-amway-dev-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	@find . -not -name 'ec2_overseer.py' -not -name 'Makefile' -delete

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
