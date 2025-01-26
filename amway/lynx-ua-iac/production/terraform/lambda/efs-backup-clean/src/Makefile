ZIP             = $(shell which zip) 
AWS             = $(shell which aws)
ARCHIVE_NAME 	= "efs_backup_cleanup.zip"

all: test

##test: test if zip is installed
test:
ifeq ($(ZIP),)
        $(error zip not found in "$(PATH)")
else
	$(info zip was found)	
endif
ifeq ($(AWS),)
        $(error awscli not found in "$(PATH)")
else
        $(info awscli was found)
endif

##install: create zip archive to push to lambda
install:
	$(info Creating zip archive ready to push to lambda func)
	@zip $(ARCHIVE_NAME) efs_backup_cleanup.py
	@read -p "Enter S3 bucket Name [amway-prod-lambda-functions]: " s3_name; aws s3 cp $(ARCHIVE_NAME) s3://$${s3_name:-amway-prod-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [EFSBackupCleanupAVPRODRU | EFSBackupCleanupAVPRODKZ]: " func_name; \
	read -p "Enter S3 bucket Name [amway-prod-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $$func_name --s3-bucket $${s3_name:-amway-prod-lambda-functions} --s3-key $(ARCHIVE_NAME)

##clean: delete all deps form src dir
clean:
	@find . -not -name 'efs_backup_cleanup.py' -not -name 'Makefile' -delete

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
