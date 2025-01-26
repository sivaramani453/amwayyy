#!/bin/bash
# Overall strategy for this script is described in PULL_REQUEST.md in a dir above
# For implementation details check comments below

#for debug purposes
#set -x

set +e

export ERROR=0
export TFVERSION=''
export TFVALIDATE=''

#Perform scan only for recently changed files
for TFDIR in $(git --no-pager diff --diff-filter=MRT --name-only $(git --no-pager merge-base HEAD origin/master) | grep .tf | sed -r 's|/[^/]+$||' | sort | uniq); do
    cd $TFDIR
    echo "Checking $TFDIR..."

    TFVERSION=''
    #Detect tf version or use empty
    if [ -f backend.tf ]; then
        export TFVERSION=$(grep -onzE "terraform\s*{\s*required_version\s*=\s*.~?>?\s?0\.([0-9]{2})" backend.tf | grep -aoE "[0-9]{2}");
        echo "Detected terraform version: $TFVERSION"
    fi

    rm -rf .terraform

    #Run fmt before any initialization, as we want only our code to be checked
    echo "Running terraform${TFVERSION:+-$TFVERSION} fmt"
    terraform${TFVERSION:+-$TFVERSION} fmt -check=true
    if [[ $? -ne 0 ]]; then
    ERROR=1;
    echo "^^^ terraform fmt problem in $TFDIR"
    fi;

    #Choose proper validate command, depending on version detected
    case $TFVERSION in
    12) 
        TFVALIDATE='terraform-12 validate'
        ;;
    11)
        TFVALIDATE='terraform-11 validate -check-variables=false'
        ;;
    *)
        TFVALIDATE='terraform validate -check-variables=false'
        ;;
    esac

    terraform${TFVERSION:+-$TFVERSION} init -backend=false
    terraform${TFVERSION:+-$TFVERSION} get
    $TFVALIDATE
    if [[ $? -ne 0 ]]; then
        ERROR=;
        echo "^^^ terraform validate problem in $TFDIR"
    fi;
done

exit $ERROR
