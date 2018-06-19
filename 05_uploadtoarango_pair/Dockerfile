FROM alpine:3.6

RUN apk update
RUN apk add bash

COPY ./bash_scripts /code
COPY ./common_scripts /code

ENTRYPOINT ["/code/main.sh"]
