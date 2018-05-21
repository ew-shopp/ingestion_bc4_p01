FROM alpine:3.6

RUN apk update
RUN apk add bash

ADD supervisor_sigterm.sh /code/supervisor_sigterm.sh
ADD main.sh /code/main.sh
# ADD run_job.sh /code/run_job.sh
# ADD move_to_output.sh /code/move_to_output.sh
ENTRYPOINT ["/code/supervisor_sigterm.sh"]
