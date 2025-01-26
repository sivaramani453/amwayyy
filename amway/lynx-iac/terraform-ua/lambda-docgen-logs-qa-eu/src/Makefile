ZIP		= $(shell which zip)
PIP 		= $(shell which pip3)
UNAME 		= $(shell uname)
ARCHIVE_NAME 	= "docgen_logs.zip"
THIS_FILE := $(lastword $(MAKEFILE_LIST))

all: test build

##test: test if pip3 is installed
test: 
ifeq ($(PIP),)
	$(error pip3 not found in "$(PATH)")
endif
ifeq ($(ZIP),)
        $(error zip not found in "$(PATH)")
endif

##install: create zip archive to push to lambda
install: 
	$(info Creating zip archive ready to push to lambda func)
	@zip -r $(ARCHIVE_NAME) *

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
	@pip3 install --target=. elasticsearch

_build_linux:
	$(info building on linux system)
	@pip3 install --target=. elasticsearch

##clean: delete all deps form src dir
clean:
	@find . -not -name 'docgen_log_sender.py' -not -name 'Makefile' -delete        

##help: show this message
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
