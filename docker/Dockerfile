FROM ruby:3.1.3-alpine3.17 AS base

FROM base AS builder

# fail early and print all commands
RUN set -ex

ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

# build dependencies:
# -virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - ruby-dev/libc-dev for compiling raindrops, at least
# - libxml2-dev/libxslt-dev for nokogiri, at least
# - postgres-dev for pg/activerecord gems
# - git for installing gems referred to use as git:// uri
# - yarn for js dependency management
#
RUN apk --no-cache add \
                   build-base \
                   libxml2-dev \
                   libxslt-dev \
                   postgresql-dev \
                   git \
                   yarn \
                   gmp=6.2.1-r2

######################
# DEPENDENCIES START #
######################
# Env vars needed for dependency install and asset precompilation?? maybe not
ENV RAILS_ENV production

COPY Gemfile Gemfile.lock $APP_HOME/

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
# note: installs bundler version used in Gemfile.lock
#
RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
&& bundle config without test development devunicorn \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install --jobs 4 --retry 3 \
&& rm -rf /usr/local/bundle/cache/*.gem \
&& find /usr/local/bundle/gems/ -name "*.c" -delete \
&& find /usr/local/bundle/gems/ -name "*.o" -delete

COPY package.json yarn.lock $APP_HOME/
RUN yarn install --frozen-lockfile --production --silent

COPY . $APP_HOME/

# precompile assets, silently (as verbose)
RUN SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here \
RAILS_ENV=production \
bundle exec rails assets:precompile 2> /dev/null

# tidy up installation
RUN apk --update-cache upgrade
RUN rm -rf node_modules

####################
# DEPENDENCIES END #
####################

FROM base
LABEL Organisation="Ministry of Justice"
LABEL Service="Claim for Crown Court Defence"
LABEL Contact="crowncourtdefence@digital.justice.gov.uk"

# fail early and print all commands
RUN set -ex

ENV RAILS_ENV production
ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

# runtime dependencies:
# - file: for paperclip file type spoofing check
# - nodejs: for ExecJS and asset compilation
# - runit for process management (because we have multiple services)
# - libreoffice: for pdf conversion
# - ttf-freefont: needed for libreoffice
# - redis: for backend key-value store
# - postgresql-client - only needed for database dump
#
RUN apk --no-cache add \
                   file \
                   nodejs \
                   linux-headers \
                   runit \
                   ttf-freefont \
                   libreoffice \
                   redis \
                   postgresql-client

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=appuser:appgroup $APP_HOME $APP_HOME

# tidy up installation
RUN apk --update-cache upgrade

# expect ping environment variables
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
CMD "./docker/docker-entrypoint.sh"
