FROM alpine:3.6

RUN apk update
RUN apk add bash
RUN apk add openjdk7-jre

ADD main.sh /code/main.sh
ADD run_job.sh /code/run_job.sh
ADD move_to_output.sh /code/move_to_output.sh

ENTRYPOINT ["/code/main.sh"]
