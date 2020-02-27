FROM localstack/localstack:latest

# Kinesis
EXPOSE 4568
# Lambda
EXPOSE 4574
# WEB-PORT-UI
EXPOSE 8080

ENV SERVICES lambda,kinesis
ENV DEBUG 1
ENV DATA_DIR /tmp/localstack/data
ENV LAMBDA_EXECUTOR local
ENV DOCKER_HOST unix:///var/run/docker.sock

RUN mkdir /build
ADD configure-box.sh /build/

RUN chmod -R +x /build/*.sh && /build/configure-box.sh

