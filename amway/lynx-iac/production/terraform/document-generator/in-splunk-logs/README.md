### Lambda logs
#### Installation
  * Go to src dir
  * make deps
  * make
  * make install

You will see log.zip file in ./src/ dir
Now you are ready for terraform apply

### Usage
Note that this func supports 2 outputs:
 * elasticsearch
 * splunk

Different env vars needed for each output. And you can choose only one of it by setting DEST env var. Default is elasticsearch
