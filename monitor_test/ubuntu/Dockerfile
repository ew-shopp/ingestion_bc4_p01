FROM ubuntu:16.04

RUN apt-get --yes update
RUN apt-get --yes --fix-missing install curl 

ADD *.sh /code/

ENTRYPOINT ["/code/supervisor_sigterm.sh"]
