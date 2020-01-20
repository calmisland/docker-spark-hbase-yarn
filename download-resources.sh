
#Resrouce to configure a cluster
aws s3 cp s3://data-collection-code-artifacts/data-pipeline/spark-2.4.4-bin-without-hadoop.tgz ./resources/ --profile $PROFILE
aws s3 cp s3://data-collection-code-artifacts/data-pipeline/hadoop-2.8.5.tar.gz ./resources/ --profile $PROFILE
aws s3 cp s3://data-collection-code-artifacts/data-pipeline/hbase-1.4.10-bin.tar.gz ./resources/ --profile $PROFILE

#Access directly to a docker-machine
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
