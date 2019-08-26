FROM golang:1.12.9-alpine AS build

ENV GO111MODULE=on

COPY . /go/src/

RUN \
    cd /go/src/ && \ 
    apk add --no-cache git mercurial &&\
    go build -o /srv/my-app && \
    apk del git mercurial && \
    rm -rf /go/src/*


FROM alpine:latest

WORKDIR /srv
COPY --from=build /srv ./

RUN apk add --no-cache ca-certificates && \
    apk add --update curl gnupg tzdata

VOLUME .certs/server

EXPOSE 443

WORKDIR /srv

CMD ["/srv/my-app"]