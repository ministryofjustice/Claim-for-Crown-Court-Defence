FROM ruby:3.1.2-alpine3.15
MAINTAINER Ministry of Justice, Claim for crown court defence <crowncourtdefence@digital.justice.gov.uk>

# fail early and print all commands
RUN set -ex

# build dependencies:
# -virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - ruby-dev/libc-dev for compiling raindrops, at least
# - libxml2-dev/libxslt-dev for nokogiri, at least
# - postgres-dev for pg/activerecord gems
# - git for installing gems referred to use as git:// uri
# - yarn for js dependency management
#
# runtime dependencies:
# - file: for paperclip file type spoofing check
# - nodejs: for ExecJS and asset compilation
# - runit for process management (because we have multiple services)
# - libreoffice: for pdf conversion
# - ttf-freefont: needed for libreoffice
# - redis: for backend key-value store
# - postgresql-client - only needed for database dump
#
RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    libxml2-dev \
                    libxslt-dev \
                    postgresql-dev \
                    git \
                    yarn \
                    gmp=6.2.1-r1 \
&& apk --no-cache add \
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

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

######################
# DEPENDENCIES START #
######################
# Env vars needed for dependency install and asset precompilation?? maybe not
ENV RAILS_ENV production

COPY Gemfile* ./

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
# note: installs bundler version used in Gemfile.lock
#
RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
&& bundle config without test development devunicorn \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production --silent

####################
# DEPENDENCIES END #
####################
COPY . .

# precompile assets, silently (as verbose)
# note: webpacker:compile appended to the assets:precompile task
RUN SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here \
RAILS_ENV=production \
bundle exec rails assets:precompile 2> /dev/null

# tidy up installation
RUN apk update && apk del build-dependencies

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

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
