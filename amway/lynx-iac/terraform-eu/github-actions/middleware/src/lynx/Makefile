GOCMD 		= $(shell which go)
GOBUILD 	= $(GOCMD) build
GOCLEAN 	= $(GOCMD) clean
GOTEST 		= $(GOCMD) test
GOGET 		= $(GOCMD) get
BINARY_NAME 	= "gh-middleware-v2"
GOOS		= "linux"
BINARY_UNIX 	= $(BINARY_NAME)_unix


all: build

##build: build binary with go build
build:
	$(info building "$(BINARY_NAME)" binary)
	#@GOOS=$(GOOS) $(GOBUILD) -o $(BINARY_NAME) -v
	docker run --rm -it -w /go/src/middleware -v ${PWD}:/go/src/middleware golang:1.15-buster bash -c "go get github.com/aws/aws-lambda-go/events && go get github.com/aws/aws-lambda-go/lambda && go get github.com/pymhd/go-logging && go get github.com/pymhd/go-logging/handlers && go build -o $(BINARY_NAME) ."

##test: test  go deps
test:
	$(info Cheking dependencies)
	@$(GOTEST) -v ./... > /dev/null


##clean: exec go clean and delete binaries
clean:
	$(info  go clean and binary file deleting)
	@$(GOCLEAN)
	@rm -f $(BINARY_NAME)
	@rm -f $(BINARY_NAME).zip
	@rm -f $(BINARY_UNIX)

##install: copy binary file to /usr/local/bin dir
install:
	$(info copy "$(BINARY_NAME).zip" file to s3 bucket)
	@zip -j $(BINARY_NAME).zip $(BINARY_NAME)
	@read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; aws s3 cp $(BINARY_NAME).zip s3://$${s3_name:-amway-dev-eu-lambda-functions}

##deploy: trigger lambda to update code
deploy:
	@read -p "Enter function name [gh-middleware-test-v2]: " func_name; \
	read -p "Enter S3 bucket Name [amway-dev-eu-lambda-functions]: " s3_name; \
	aws lambda update-function-code --function-name $${func_name:-gh-middleware-test-v2} --s3-bucket $${s3_name:-amway-dev-eu-lambda-functions} --s3-key $(BINARY_NAME).zip


##deps: go get all required packages
deps:
	$(info go get: github.com/pymhd/go-logging)
	@$(GOGET) -u github.com/pymhd/go-logging
	$(info go get: github.com/aws/aws-lambda-go/events)
	@$(GOGET) -u github.com/aws/aws-lambda-go/events
	$(info go get: github.com/aws/aws-lambda-go/lambda)
	@$(GOGET) -u github.com/aws/aws-lambda-go/lambda

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
