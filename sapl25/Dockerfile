FROM ubuntu:12.04
MAINTAINER "Fabio Rauber" <fabiorauber@gmail.com>

ENV SVNSOURCE http://repositorio.interlegis.gov.br/ILSAPL/install/2.5/
ENV INSTALLSRC /usr/local/src/sapl25
ENV INSTALLDIR /opt/interlegis/SAPL25
ENV LANG pt_BR.UTF-8
ENV LANGUAGE pt_BR:pt
ENV LC_ALL pt_BR.UTF-8

RUN apt-get update && apt-get upgrade && \
    apt-get install -y \
        language-pack-pt-base \
        build-essential \
        zlib1g-dev \
        libjpeg62-dev \
        libssl-dev \
        libreadline6-dev \
        libreadline6 \
        readline-common \
        libxml2-dev \
        wv \
        poppler-utils \
        libxslt1-dev \
        libfreetype6-dev \
        xpdf-utils \
        gs-common \
        catdoc \
        ppthtml \
        subversion \ 
        unzip \ 
        lynx \
        mysql-client \
        libmysqlclient-dev \
        mailutils \
        subversion && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  

COPY src/start.sh /usr/bin/start

RUN mkdir -p $INSTALLSRC && \
    groupadd -g 500 zope && \
    useradd -g 500 -u 500 -m -s /bin/bash zope && \
    chmod +x /usr/bin/start && \
    locale-gen pt_BR.UTF-8

WORKDIR $INSTALLSRC

RUN /usr/bin/svn co $SVNSOURCE install_sapl
COPY src/install.sh $INSTALLSRC/install_sapl
RUN cd install_sapl && \ 
    /bin/bash install.sh && \
    rm -rf $INSTALLSRC/install_sapl && \
    touch $INSTALLDIR/instances/sapl25/log/event.log && \
    chown -R zope:zope $INSTALLDIR/instances/sapl25

VOLUME $INSTALLDIR/instances/sapl25/var

USER zope 
   
EXPOSE 8080

CMD ["start"]
