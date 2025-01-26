# IAC RUNNER

In case you need to add/upgrade terraform binaries, simply add/update it in group_vars/all.yaml, and rebuild image. The ansible part iterates terraform_downloads variable to install all versions you may want, so just add/update it there.