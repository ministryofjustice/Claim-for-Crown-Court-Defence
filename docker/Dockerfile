FROM ministryofjustice/ruby:2-webapp-onbuild

ENV APP_HOME /rails

ADD ./ /rails
ADD ./docker/run.sh $APP_HOME/run.sh
RUN chmod 777 $APP_HOME/run.sh
WORKDIR $APPHOME

EXPOSE 80

#SECRET_TOKEN set here because otherwise devise blows up during the precompile.
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

CMD $APP_HOME/run.sh
