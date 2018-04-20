FROM alpine:3.6

RUN apk update
RUN apk add bash
RUN apk add openjdk7-jre

ADD main.sh /code/main.sh

ENTRYPOINT ["/code/main.sh"]
