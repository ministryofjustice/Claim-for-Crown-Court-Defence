FROM registry.service.dsd.io/ruby:2.4.2

# add official nodejs repo
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
        echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list

# install runit, nodejs and libreoffice (used by ADP to generate PDFs)
RUN apt-get update && apt-get install -y runit nodejs libreoffice redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# SSH proxy settings
ENV SSH_AUTH_SOCK /tmp/ssh-auth
ENV SSH_AUTH_PROXY_PORT 1234

RUN mkdir -p /usr/src/app
RUN bundle config --global without test:development

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

# Hack to install private gems
#RUN socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork TCP4:$(ip route|awk '/default/ {print $3}'):$SSH_AUTH_PROXY_PORT & bundle install
RUN bundle install

COPY . /usr/src/app
RUN mkdir -p /usr/src/app/public/assets

COPY ./docker/run.sh $APP_HOME/run.sh
RUN chmod 777 $APP_HOME/run.sh

WORKDIR $APP_HOME

EXPOSE 80

#SECRET_TOKEN set here because otherwise devise blows up during the precompile.
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

CMD "$APP_HOME/run.sh"
