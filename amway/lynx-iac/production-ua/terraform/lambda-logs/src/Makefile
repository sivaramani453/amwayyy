GOCMD 		= $(shell which go)
GOBUILD 	= $(GOCMD) build
GOCLEAN 	= $(GOCMD) clean
GOTEST 		= $(GOCMD) test
GOGET 		= $(GOCMD) get
BINARY_NAME 	= "log"
GOOS		= "linux"
BINARY_UNIX 	= $(BINARY_NAME)_unix


all: deps test build

##build: build binary with go build 
build: 
	$(info building "$(BINARY_NAME)" binary)
	@GOOS=$(GOOS) $(GOBUILD) -o $(BINARY_NAME) -v

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
	$(info zipping "$(BINARY_NAME)" file )
	zip -j $(BINARY_NAME).zip $(BINARY_NAME)

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
