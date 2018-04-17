FROM ubuntu:16.04

RUN apt-get update
RUN apt-get --yes install unzip

ADD main.sh /code/main.sh
ENTRYPOINT ["/code/main.sh"]
