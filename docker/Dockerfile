FROM ruby:3.4.1-alpine3.20 AS base

# Stage 1: installs gems and npm packages
FROM base AS builder

RUN set -ex

ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

RUN apk --update-cache upgrade \
 && apk --no-cache add \
                   build-base \
                   git \
                   postgresql-dev \
                   yarn

ENV RAILS_ENV production

COPY Gemfile Gemfile.lock .ruby-version $APP_HOME/

RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
&& bundle config without test development \
&& bundle install --jobs 4 --retry 3 \
&& rm -rf /usr/local/bundle/cache/*.gem \
&& find /usr/local/bundle/gems/ -name "*.c" -delete \
&& find /usr/local/bundle/gems/ -name "*.o" -delete

COPY package.json yarn.lock $APP_HOME/
RUN yarn install --frozen-lockfile --production --silent

COPY . $APP_HOME/

RUN SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here \
RAILS_ENV=production \
bundle exec rails assets:precompile 2> /dev/null

RUN rm -rf node_modules

# Stage 2: copies dependencies from the build stage and creates final image for running the application
FROM base
LABEL Organisation="Ministry of Justice"
LABEL Service="Claim for Crown Court Defence"
LABEL Contact="crowncourtdefence@digital.justice.gov.uk"

RUN set -ex

ENV RAILS_ENV production
ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

RUN apk --update-cache upgrade \
 && apk --no-cache add \
                   file \
                   libreoffice \
                   linux-headers \
                   nodejs \
                   postgresql-client \
                   redis \
                   runit \
                   ttf-freefont

RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=appuser:appgroup $APP_HOME $APP_HOME

ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH
ARG LIVE1_DB_TASK
ENV VERSION_NUMBER=${VERSION_NUMBER}
ENV COMMIT_ID=${COMMIT_ID}
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
ENV APP_BRANCH=${APP_BRANCH}
ENV LIVE1_DB_TASK=${LIVE1_DB_TASK}

USER 1000

# Create tmp/pids/ needed for puma
RUN mkdir -p $APP_HOME/tmp/pids

CMD "./docker/docker-entrypoint.sh"
