#!/bin/bash
set -euxo pipefail
source static-info.sh

#Resrouce to configure a cluster
aws s3 cp $RESOURCE_BUCKET/$SPARK_TGZ ./resources/ --profile $PROFILE
aws s3 cp $RESOURCE_BUCKET/$HADOOP_TGZ ./resources/ --profile $PROFILE
aws s3 cp $RESOURCE_BUCKET/$HBASE_TGZ ./resources/ --profile $PROFILE

#Access directly to a docker-machine
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
