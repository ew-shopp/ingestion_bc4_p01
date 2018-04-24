FROM ubuntu:16.04

RUN apt-get update

ADD main.sh /code/main.sh
ADD run_job.sh /code/run_job.sh
ADD move_to_output.sh /code/move_to_output.sh
ENTRYPOINT ["/code/main.sh"]
