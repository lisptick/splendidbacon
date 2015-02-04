FROM ubuntu

RUN apt-get update -q
RUN apt-get install -qy curl ruby1.9.3 ruby1.9.1-dev rake make build-essential g++ git mysql-server sqlite3 libxslt-dev libxml2-dev libsqlite3-dev nodejs nginx unicorn postgresql-9.3 libpq-dev

##INSTALLING BUNDLER
RUN /bin/bash -c -l 'gem install bundler --no-ri --no-rdoc'

# Add 'web' user which will run the application
RUN adduser web --home /home/web --shell /bin/bash --disabled-password --gecos ""

# Add scripts
ADD https://gist.github.com/3533822bf6a261233169.git /usr/local/bin/install-splendidbeacon
RUN chmod a+rx /usr/local/bin/install-splendidbeacon

## Add build directory
RUN git clone git@gitlab.corp.gandi.net:lisptick/splendidbacon.git /var/www
RUN chown -R web:web /var/www

RUN mkdir -p /var/bundle
RUN chown -R web:web /var/bundle

# install
RUN /usr/local/bin/install-splendidbeacon

WORKDIR /var/www
USER web

#### start splendidbacon
EXPOSE 5000
CMD ["bundle", "exec", "foreman", "start"]
