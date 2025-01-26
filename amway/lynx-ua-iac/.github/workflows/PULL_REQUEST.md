# Pull request workflow

Most of the tasks is defined in ```pull_request.yaml```, excluding Terraform linter, which is in ```pull_request/terraform_lint.sh```

## terraform_lint.sh

This script can be used anywhere, including pre-push hook, just to make you sure everything is fine before pushing to repo. To install a hook, please read [https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks]

### Requirements

To run this script we need different versions of terraform installed, and being available in the path. The naming convention is ```terraform-{version}```, eg ```terraform-13```. We also need binary or a symlink named ```terraform```, to be used as a default version.

### Running

Script needs ```WORKDIR``` envvar to be set to the root of the repository. If envvar is not set, it will use current directory as a root.

### Overall algorithm description

* Linting is performed only for directories containing any changed files, which are obtained from git
* Terraform version used is detected by scanning ```backend.tf``` file in a checked directory with a regexp
* ```.terraform``` directory is fully removed
* Everything is initialized without backend; plugins, modules etc are fetched
* Linting and validating is performed with proper terraform command, depending on the version