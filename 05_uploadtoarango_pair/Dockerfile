#FROM alpine:3.6
FROM ubuntu:16.04

USER root
RUN addgroup --gid 999 --system docker
RUN adduser --uid 1000 --disabled-password --no-create-home  sintef
RUN usermod -aG docker sintef
#RUN adduser sintef docker

RUN apt-get update && apt-get install -y docker.io

USER sintef
COPY ./bash_scripts /code
COPY ./common_scripts /code

ENTRYPOINT ["/code/main.sh"]
