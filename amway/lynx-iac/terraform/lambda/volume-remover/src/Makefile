ARCHIVE_NAME 	= "volume_remover.zip"

##install: create zip archive to push to lambda
install:
	$(info Creating zip archive ready to push to lambda func)
	@zip $(ARCHIVE_NAME) volume_remover.py
	@read -p "Enter S3 bucket Name [amway-dev-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-dev-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [volume-remover]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-volume-remover} --s3-bucket $${s3_name:-amway-dev-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	@find . -not -name 'volume_remover.py' -not -name 'Makefile' -delete

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
