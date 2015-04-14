FROM ministryofjustice/ruby:2-webapp-onbuild

ENV APP_HOME /rails

ADD ./ /rails
WORKDIR /rails

EXPOSE 80