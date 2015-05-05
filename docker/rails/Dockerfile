FROM ministryofjustice/ruby:2-webapp-onbuild

ENV APP_HOME /rails

ADD ./ /rails
ADD ./docker/rails/run.sh /rails/run.sh
RUN chmod 777 /rails/run.sh
WORKDIR /rails

EXPOSE 80

CMD /rails/run.sh