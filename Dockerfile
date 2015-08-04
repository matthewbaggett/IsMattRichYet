FROM ubuntu:trusty
MAINTAINER Matthew Baggett <matthew@baggett.me>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Install base packages
RUN apt-get update && \
    apt-get -yq install \
        wget \
        curl \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-gd \
        php5-curl \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/*
RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV TZ "Europe/London"
RUN echo $TZ | tee /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata
  
# Add NewRelic repo & install
RUN wget -O - https://download.newrelic.com/548C16BF.gpg | sudo apt-key add -
RUN sudo sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list'
RUN sudo apt-get update;
RUN sudo apt-get install -yq newrelic-php5

# Run Newrelic Install & Configure
RUN newrelic-install install
ADD newrelic.ini /etc/php5/cli/conf.d/newrelic.ini
ADD newrelic.ini /etc/php5/apache2/conf.d/newrelic.ini

# Add image configuration and scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD . /app
ADD .htaccess /app/.htaccess
ADD ApacheConfig.conf /etc/apache2/sites-enabled/000-default.conf

# Run Composer
#RUN cd /app && composer update

# Run NPM install
#RUN cd /app && npm install

# Enable mod_rewrite
RUN a2enmod rewrite && /etc/init.d/apache2 restart

#================================
# Expose Container's Directories
#================================
VOLUME /var/log

EXPOSE 80

WORKDIR /app
CMD ["/run.sh"]