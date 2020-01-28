FROM ruby:2.5-alpine

WORKDIR /work
COPY . /work/

RUN apk update && \
	apk upgrade && \
	apk add --no-cache git gcc g++ libc-dev linux-headers make

RUN source bin/setup && rake spec && bundle exec rake install

ARG REDASH_URL
ARG REDASH_API_KEY
ENV REDASH_URL $REDASH_URL
ENV REDASH_API_KEY $REDASH_API_KEY

ENTRYPOINT ["redash-qr"]
