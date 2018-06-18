FROM ubuntu:16.04

RUN apt-get update

COPY ./bash_scripts /code
COPY ./common_scripts /code

ENTRYPOINT ["/code/main.sh"]
