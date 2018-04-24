FROM mhart/alpine-node:6

RUN apk update
RUN apk add bash
RUN apk add git
RUN mkdir /code && \
    cd /code && \
    git clone https://github.com/datagraft/Datagraft-RDF-to-Arango-DB.git && \
    cd Datagraft-RDF-to-Arango-DB && \
    npm install

ADD main.sh /code/main.sh
ADD run_job.sh /code/run_job.sh
ADD move_to_output.sh /code/move_to_output.sh

ENTRYPOINT ["/code/main.sh"]
