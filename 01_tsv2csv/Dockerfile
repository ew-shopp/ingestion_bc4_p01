FROM alpine:3.6

RUN apk update
RUN apk add bash

ADD main.sh /code/main.sh
ENTRYPOINT ["/code/main.sh"]
