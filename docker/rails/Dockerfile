FROM ministryofjustice/ruby:2-webapp-onbuild

ENV APP_HOME /rails

ADD ./ /rails
ADD ./docker/rails/run.sh /rails/run.sh
RUN chmod 777 /rails/run.sh
WORKDIR /rails

EXPOSE 80

#SECRET_TOKEN set here because otherwise devise blows up during the precompile.
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

CMD /rails/run.sh
