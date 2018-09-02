FROM ruby:2.5-alpine

ARG version

RUN if [[ "$version" = "" ]]; then gem install redash-query-replace --no-document; else gem install redash-query-replace --no-document --version ${version}; fi

ENTRYPOINT ["redash-qr"]
