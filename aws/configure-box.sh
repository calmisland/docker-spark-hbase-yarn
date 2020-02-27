#!/bin/bash

set -euxo pipefail

export MOCK_ACCESS_KEY=mock_access_key
export MOCK_SECRET_ACCESS_KEY=mock_secret_access_key

mkdir -p /root/.aws/
mkdir -p /tmp/localstack/data

touch /root/.aws/config
echo "[profile default]" >> /root/.aws/config
echo "region = ap-northeast-2" >> /root/.aws/config

touch /root/.aws/credentials
echo "[default]" >> /root/.aws/credentials
echo "aws_access_key_id = $MOCK_ACCESS_KEY" >> /root/.aws/credentials
echo "aws_secret_access_key = $MOCK_SECRET_ACCESS_KEY" >> /root/.aws/credentials
