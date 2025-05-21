
#!/bin/bash -e

cd $(dirname $0)

git pull

bash ./deploy.sh $*
