FROM alpine:3.8

RUN mkdir -p /var/www/html /run/nginx /var/lib/nginx && mkdir -p /var/cache/nginx /var/log/mysql /var/log/elasticsearch /opt && \
    addgroup -S nginx && adduser -S -h /var/www/html -s /bin/sh -G nginx nginx && echo 'nginx:nginx' | chpasswd && adduser -D -h /usr/share/elasticsearch elasticsearch && \
    addgroup -S rabbitmq && adduser -S -h /var/lib/rabbitmq -G rabbitmq rabbitmq 
#&& \
#    chown -R nginx:nginx /var/lib/nginx /var/www /var/www/html /run/nginx

 #RUN adduser -D -u 1000 -g 1000 nginx -h /var/www -s /bin/sh && echo 'nginx:nginx' | chpasswd && adduser -D -h /usr/share/elasticsearch elasticsearch && \
 #   addgroup -S rabbitmq && adduser -S -h /var/lib/rabbitmq -G rabbitmq rabbitmq && \
 #   mkdir -p /var/www/html && mkdir -p /var/cache/nginx /var/log/mysql /var/log/elasticsearch /opt && \
 #   mkdir -p /run/nginx /var/lib/nginx && \
#    chown -R nginx:nginx /var/lib/nginx /var/www /var/www/html /run/nginx

#RUN addgroup -S nginx && adduser -S -h /var/www/html -s /bin/sh -G nginx nginx


RUN apk add --no-cache --update \
    curl \
    wget \
    openssl \
    bash \
    openjdk8 \
    git \
    erlang-asn1 \
    erlang-crypto \
    erlang-eldap \
    erlang-inets \
    erlang-mnesia \
    erlang \
    erlang-os-mon \
    erlang-public-key \
    erlang-sasl \
    erlang-ssl \
    erlang-syntax-tools \
    erlang-xmerl \    
    openssh \
    coreutils \
    sudo
    
RUN apk add --no-cache --update \
    nginx \
    php7 \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-cgi \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fpm \
    php7-ftp \
    php7-gd \
    php7-iconv \
    php7-json \
    php7-mbstring \
    php7-oauth \
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-redis \
    php7-session \
    php7-simplexml \
    php7-tokenizer \
    php7-xdebug \
    php7-xml \
    php7-xmlwriter \
    php7-zip \
    php7-zlib \
    php7-zmq  \
    php7-soap \
    php7-mcrypt \
    php7-fileinfo \
    php7-xmlreader \
    php7-posix \
    php7-sockets \
    php7-xsl \
    php7-intl \
    mysql \
    mysql-client \
    varnish \
    redis \
    tzdata && \
    rm -rf /var/cache/apk/*

RUN echo "root:root" | chpasswd && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config && \
    sed -i 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config && \
    sed -i 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config && \
    sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config && \
    sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config && \
    /usr/bin/ssh-keygen -A && ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_key && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/.default.conf.bak && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    cp /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo "Asia/Kolkata" >  /etc/timezone && \
    echo 'nginx ALL=(ALL:ALL) /usr/sbin/nginx, /usr/bin/php, /usr/bin/mysql, /usr/bin/composer, /usr/sbin/crond' | sudo EDITOR='tee -a' visudo && \
    chmod o-rx /home/ /root/ /opt/ && \
    addgroup mysql mysql && apk del tzdata && chown -R mysql:mysql /var/log/mysql

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-6.5.4.tar.gz && \
    tar -xvzf elasticsearch-oss-6.5.4.tar.gz && \
    mv elasticsearch-6.5.4/* /usr/share/elasticsearch/ && rm -rf elasticsearch* && \
    sed -ie 's/-Xms2g/-Xms256m/g' "/usr/share/elasticsearch/config/jvm.options" && \
    sed -ie 's/-Xmx2g/-Xmx256m/g' "/usr/share/elasticsearch/config/jvm.options" && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
    export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre && \
    sed -ie 's/memory_limit = 128M/memory_limit = -1/g' "/etc/php7/php.ini" 

RUN wget https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_12/rabbitmq-server-generic-unix-3.6.12.tar.xz && \
    tar -xf rabbitmq-server-generic-unix-3.6.12.tar.xz && mv rabbitmq_server-3.6.12 /opt/rabbitmq && rm -rf rabbitmq* && \
    mkdir -p /var/lib/rabbitmq /etc/rabbitmq && chown -R rabbitmq:rabbitmq /opt/rabbitmq /var/lib/rabbitmq /etc/rabbitmq && \
    chmod -R 777 /var/lib/rabbitmq /etc/rabbitmq && \
    echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_7.2.so' >  /etc/php7/conf.d/00-ioncube.ini
ENV PATH /opt/rabbitmq/sbin:/usr/share/elasticsearch/bin:$PATH

COPY scripts/my.cnf /etc/mysql
COPY scripts/ioncube_loader_lin_7.2.so /usr/lib/php7/modules/ 
COPY scripts/redis.conf /etc/redis.conf
COPY scripts/php-fpm-www.conf /etc/php7/php-fpm.conf
COPY scripts/www.conf /etc/php7/php-fpm.d/www.conf
COPY scripts/host.conf /etc/nginx/conf.d/
COPY scripts/default.vcl /etc/varnish/default.vcl
COPY scripts/elasticsearch.yml /usr/share/elasticsearch/config/ 
COPY scripts/start.sh /usr/local/bin/start.sh
EXPOSE 80 22 3306 9200 6379 5672 15672 
WORKDIR /var/www/html
ENTRYPOINT [ "sh", "/usr/local/bin/start.sh" ]
