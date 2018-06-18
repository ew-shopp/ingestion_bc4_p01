FROM alpine:3.6

RUN apk update
RUN apk add bash
RUN apk add openjdk7-jre

COPY ./bash_scripts /code
COPY ./common_scripts /code

ENTRYPOINT ["/code/main.sh"]
