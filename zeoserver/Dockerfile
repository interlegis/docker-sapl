FROM ubuntu:12.04
MAINTAINER "Fabio Rauber" <fabiorauber@gmail.com>

ENV LANG="pt_BR.UTF-8" \
    LANGUAGE="pt_BR:pt" \
    LC_ALL="pt_BR.UTF-8" \
    INSTALLDIR="/opt/zope" \ 
    ZEOPORT="8100" \
    TEMPSTORAGE="True" 

RUN apt-get update && apt-get upgrade && \
    apt-get install -y \
        language-pack-pt-base \
        build-essential \
        zlib1g-dev \
        wget \
        zlib1g && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \ 
    locale-gen $LANG

# Python install
ENV PYTHON_VERSION 2.4.6

RUN cd /tmp && \
    wget --no-check-certificate https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz && \
    tar -xvf Python-$PYTHON_VERSION.tgz && \
    ln -s /lib/x86_64-linux-gnu/libz.so.1 /lib/libz.so && \
    cd Python-$PYTHON_VERSION && \
    ./configure --prefix $INSTALLDIR/python && \
    make && make install

# Zope installation
ENV ZOPE_VERSION 2.9.12

RUN cd /tmp && \ 
    wget http://old.zope.org/Products/Zope/$ZOPE_VERSION/Zope-$ZOPE_VERSION-final.tgz && \
    tar -xvf Zope-$ZOPE_VERSION-final.tgz && \
    cd Zope-$ZOPE_VERSION-final && \
    ./configure --prefix=$INSTALLDIR/zope2.9 --with-python=$INSTALLDIR/python/bin/python && make install

# ZEO instance prereqs
COPY src/start.sh /usr/bin/start

RUN groupadd -g 500 zope && \
    useradd -g 500 -u 500 -m -s /bin/bash zope && \
    chmod +x /usr/bin/start

# Create ZEO instance
ENV ZEOHOME $INSTALLDIR/instances/zeo
RUN $INSTALLDIR/zope2.9/bin/mkzeoinstance.py $ZEOHOME $ZEOPORT && \
    touch $ZEOHOME/log/zeo.log && \
    chown -R zope:zope $ZEOHOME

VOLUME $ZEOHOME/var

USER zope 
   
EXPOSE $ZEOPORT

CMD ["start"]
