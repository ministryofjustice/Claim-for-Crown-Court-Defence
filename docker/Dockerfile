FROM ruby:2.6.3-alpine3.8

# Install pre-requisites for building nokogiri & pg gems, as well
# as the packages for converting and generating PDF's
RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    libxml2-dev libxslt-dev \
    postgresql-dev pdftk runit nodejs libreoffice redis git

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app
COPY . .
RUN mkdir -p /app/tmp

RUN bundle config --global without test:development
RUN gem install bundler -v 1.17.3
RUN bundle install

RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

RUN chown -R appuser:appgroup /app/
RUN chown -R appuser:appgroup /app/tmp/
RUN chown -R appuser:appgroup /app/log/

USER 1000

CMD "./docker/non_root_run.sh"
