FROM ruby:2.5 as builder

WORKDIR /tmp/redash-query-replace
COPY . /tmp/redash-query-replace
RUN gem build redash-query-replace.gemspec

FROM ruby:2.5

WORKDIR /work
COPY --from=builder /tmp/redash-query-replace/redash-query-replace-0.0.1.gem .
RUN gem install redash-query-replace-0.0.1.gem

ENTRYPOINT ["redash-qr"]
