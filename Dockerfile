# Copyright (C) 2020 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <github.com@nemonik.com>

FROM python:3.6
MAINTAINER Michael Joseph Walsh <github.com@nemonik.com>

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE true

RUN useradd -g 0 taiga

RUN  cd /tmp && \
        echo "APT::Acquire::Retries \"60\";" > /etc/apt/apt.conf.d/80-retries && \
        apt-get update && \
        apt-get install -y --no-install-recommends build-essential binutils-doc autoconf flex bison libjpeg-dev libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev automake libtool libffi-dev libssl-dev curl git tmux gettext && \
        apt-get install -y --no-install-recommends nginx curl wget gettext nano postgresql-client locales && \
        curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
        apt-get install -y --no-install-recommends nodejs && \
        curl -L https://npmjs.org/install.sh | sh && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

RUN pip install --upgrade pip

RUN mkdir -p /taiga/media && \
        mkdir -p /taiga/static

WORKDIR /taiga

RUN mkdir taiga-back && \
        git -c http.sslVerify=false clone --depth 1 --branch stable https://github.com/taigaio/taiga-back.git taiga-back && \
        cd taiga-back && \
        sed -i 's/git+git/git+https/g' requirements.txt && \
        pip install --no-cache-dir -r requirements.txt

RUN mkdir taiga-front-dist &&  \
        git -c http.sslVerify=false clone --depth 1 --branch stable https://github.com/taigaio/taiga-front-dist.git taiga-front-dist && \
        cd taiga-front-dist && \
        npm install

RUN mkdir -p /etc/nginx/conf.d

COPY ./taiga-front-dist/dist/conf.template /taiga/taiga-front-dist/dist/

COPY ./taiga-back/settings/local.py /taiga/taiga-back/settings/.

COPY ./nginx/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/etc/nginx/conf.d/taiga.conf /etc/nginx/conf.d/default.conf

RUN chgrp 0 /var/log/nginx/error.log && \
        chmod g=u /var/log/nginx/error.log

RUN pip install taiga-contrib-ldap-auth-ext

COPY ./django /etc/init.d/.

RUN chmod +x /etc/init.d/django && \
        update-rc.d django defaults

# Disable nginux spinning up by default
RUN update-rc.d -f nginx remove

COPY ./docker-entrypoint.sh /.

RUN chmod +x /docker-entrypoint.sh

RUN chmod g=u /etc/passwd && \
        chgrp -R 0 /taiga && \
        chmod -R g=u /taiga && \
        chgrp 0 /docker-entrypoint.sh && \
        chmod g=u /docker-entrypoint.sh

USER 1001

WORKDIR /taiga

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8080
