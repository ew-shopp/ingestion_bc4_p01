FROM alpine:3.6

RUN apk update
RUN apk add bash
RUN apk add openjdk7-jre

ADD main.sh /code/main.sh
ADD transformation-csv3.jar /code/transformation-csv3.jar

ENTRYPOINT ["/code/main.sh"]
