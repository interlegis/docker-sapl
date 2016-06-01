#!/bin/sh
#
# Unified SAPL installer build script
# Maintainer: Jean Rodrigo Ferri (jeanferri at interlegis.gov.br)
# Original Author: Kamal Gill (kamalgill at mac.com)
#
# Note: this script must be run as root
#

# Export libraries
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# Configure SAPL installation options
INSTALL_HOME=$INSTALLDIR
EFFECTIVE_USER=zope
LOCAL_HOME=$INSTALL_HOME
PY_HOME=$INSTALL_HOME/Python-2.4
SITECUSTOMIZE_FILE=$PY_HOME/lib/python2.4/sitecustomize.py
PY=$PY_HOME/bin/python2.4
ZOPE_HOME=$INSTALL_HOME/Zope-2.9
#MYSQL_HOME=$INSTALL_HOME/mysql
SITE_PACKAGES=$PY_HOME/lib/python2.4/site-packages
INSTANCE_HOME=$INSTALL_HOME/instances
SAPL_HOME=$INSTANCE_HOME/sapl25
#PYTHON_EGG_CACHE=$SAPL_HOME/var/.python-eggs
PRODUCTS_HOME=$SAPL_HOME/Products
PWFILE=$INSTALL_HOME/adminPassword.txt
SAPL_STARTUP_SCRIPT=$SAPL_HOME/bin/startsapl.sh
SAPL_SHUTDOWN_SCRIPT=$SAPL_HOME/bin/shutdownsapl.sh
SAPL_RESTART_SCRIPT=$SAPL_HOME/bin/restartsapl.sh
RECEIPTS_HOME=$INSTALL_HOME/receipts

#export PYTHON_EGG_CACHE

# Include the following tarballs in the packages/ directory in the bundle
PYTHON_TB=Python-2.4.6.tar.bz2
PYTHON_DIR=Python-2.4.6
PYXML_TB=PyXML-0.8.4.tar.bz2
PYXML_DIR=PyXML-0.8.4
REPLAB_TB=reportlab_2_5.tar.bz2
REPLAB_DIR=reportlab-2.5
JPEG_TB=jpeg-6b.tar.bz2
JPEG_DIR=jpeg-6b
ZLIB_TB=zlib-1.2.3.tar.bz2
ZLIB_DIR=zlib-1.2.3
PIL_TB=Imaging-1.1.6.tar.bz2
PIL_DIR=Imaging-1.1.6
ZOPE_TB=Zope-2.9.12-final.tar.bz2
ZOPE_DIR=Zope-2.9.12-final
SAPL_TB=SAPL.tar.bz2
SAPL_DIR=ILSAPL
CMF_TB=CMF-1.6.4-final.tar.bz2
CMF_DIR=CMF-1.6.4-final
TXNG2_TB=TextIndexNG-2.2.0.tar.bz2
TXNG2_DIR=TextIndexNG2
HSCRIPTS_TB=HelperScripts.tar.bz2
HSCRIPTS_DIR=HelperScripts
ETREE_TB=elementtree-1.2.6-20050316.tar.bz2
ETREE_DIR=elementtree-1.2.6-20050316
SETUP_TB=setuptools-0.6c7-py2.4.tar.bz2
LIBXML2_TB=libxml2-2.7.8.tar.bz2
LIBXML2_DIR=libxml2-2.7.8
LIBXSLT_TB=libxslt-1.1.26.tar.bz2
LIBXSLT_DIR=libxslt-1.1.26
PYLIBXML2_TB=libxml2-python-2.6.21.tar.bz2
PYLIBXML2_DIR=libxml2-python-2.6.21
MYSQLPYTHON_TB=MySQL-python-1.2.1.tar.bz2
MYSQLPYTHON_DIR=MySQL-python-1.2.1
TRML2PDF_TB=trml2pdf-1.2.tar.bz2
TRML2PDF_DIR=trml2pdf
SDE_TB=StructuredDoc.tar.bz2
SDE_DIR=StructuredDoc
ZMYSQLDA_TB=ZMySQLDA-2.0.8.tar.bz2
ZMYSQLDA_DIR=ZMySQLDA
LXML2_TB=lxml-2.3.1.tar.bz2
LXML2_DIR=lxml-2.3.1
PYOAI_TB=pyoai-2.4.3.tar.bz2
PYOAI_DIR=pyoai-2.4.3

# Capture current working directory for build script
PWD=`pwd`

PACKAGES_DIR=packages
PKG=$PWD/$PACKAGES_DIR

GNU_TAR=`which tar`
GCC=`which gcc`
GPP=`which g++`
GNU_MAKE=`which make`
TAR_BZIP2_FLAG="--bzip2"
#TAR_BZIP2_FLAG="-j"

# The Unified Installer requires root privileges to install
ROOT_INSTALL=1

#####
# Verifica se existe uma instalacao do SAPL 2.2
if [ -d /var/lib/zope2.8/instance/sapl ]; then
    INST_PATH="/var/lib/zope2.8/instance/sapl"
else
    INST_PATH="/var/lib/zope2.9/instance/sapl"
fi

#####
# Verifica se existe uma instalacao do SAPL 2.3
if [ -d /var/interlegis/SAPL-2.3/ ]; then
    INST_PATH="/var/interlegis/SAPL-2.3"
else
    INST_PATH="/var/interlegis/SAPL-2.3"
fi

#####
# Verifica se existe uma instalacao do SAPL 2.4
if [ -d /var/interlegis/SAPL-2.4/ ]; then
    INST_PATH="/var/interlegis/SAPL-2.4"
else
    INST_PATH="/var/interlegis/SAPL-2.4"
fi

if [ -e $INST_PATH ]; then
    echo ""
    echo -e "\033[1;31mUma instalacao do SAPL 2.4/2.3/2.2/2.1 foi detectada\033[m"
    echo -e "\033[1;31mExecute a instalacao descrita em:\033[m"
    echo -e "\033[1;31mhttp://colab.interlegis.gov.br/wiki/HOWTO-Migracao22-23\033[m"
    echo -e "\033[1;31mou\033[m"
    echo -e "\033[1;31mhttp://colab.interlegis.gov.br/wiki/HOWTO-Migracao23-24\033[m"
    echo -e "\033[1;31mDependendo da sua versao\033[m"
    echo -e "\033[1;31mRoteiro alternativo\033[m"
    echo -e "\033[1;31mInstalacao abortada\033[m"
    echo ""
    exit 1
fi

#################################################################
# Exit if potential conflict with existing install at $INSTALL_HOME
if [ -e $INSTALL_HOME ]
then
    echo ""
    echo -e "\033[1;31mUma instalacao anterior foi detectada em $INSTALL_HOME.\033[m"
    echo -e "\033[1;31mInstalacao abortada\033[m"
    echo ""
    exit 1
fi

# Desabilitado para instalacao automatica via Puppet
# Verifica se existe o mysql server está sendo executado

#mysql_pid=`ps ax | grep mysqld_safe  | grep \/bin\/ | cut -d " " -f1`
#mysql_port=`netstat -ant | grep 3306 | cut -d ':' -f 2 | cut -d ' ' -f 1`


#if [ ! $mysql_pid ] && [ ! $mysql_port ]; then
#
#    echo ""
#    echo -e "\033[1;31mO Mysql Server não está em execução\033[m"
#    echo -e "\033[1;31mPara continuar a instalação, o MySQL deve estar em execução.\033[m"
#    echo -e "\033[1;31mInstalação abortada\033[m"
#    echo ""
#    exit 1
#fi

# Caso esteja sendo executado, pergunta o usuário e senha

#ok=0
#while [ $ok = 0 ]; do
#
#    echo "Digite o nome do usuário MySQL: "
#    read usuario
#
#    if [ -z $usuario ]; then
#        echo -e "\033[1;31mO usuário não pode ser em branco!\033[m";
#    else
#        ok=1
#    fi
#    
#done

#Desabilitado para instalacao automatica via Puppet
#echo "Digite a senha do usuário admin (root) do MySQL: "
#read senha

#echo "Testando usuário e senha: "

#if [ -z $senha ]; then
#    mysqladmin status -u $usuario > /dev/null 2>&1
#else
#    mysqladmin status -u $usuario --password=$senha > /dev/null 2>&1
#fi

#if [ $? -gt 0 ]; then
#
#    echo ""
#    echo -e "\033[1;31mO usuário e/ou senha estão incorretos!\033[m";
#    echo -e "\033[1;31mInstalacao abortada\033[m"
#    echo ""
#    exit 1
#fi

# Verifica se existe o banco 'interlegis'
#if [ -z $senha ]; then
#    mysqlcheck interlegis -u $usuario > /dev/null 2>&1
#else
#    mysqlcheck interlegis -u $usuario --password=$senha > /dev/null 2>&1
#fi

#if [ "$?" = "0" ]; then
#
#    echo ""
#    echo -e "\033[1;31mUma instalacao do SAPL 2.4/2.3/2.2/2.1 foi detectada\033[m"
#    echo -e "\033[1;31mO instalador encontrou o database 'interlegis' no servidor MySQL\033[m"
#    echo -e "\033[1;31mExecute a instalacao descrita em:\033[m"
#    echo -e "\033[1;31mhttp://colab.interlegis.gov.br/wiki/HOWTO-Migracao22-23\033[m"
#    echo -e "\033[1;31mou\033[m"
#    echo -e "\033[1;31mhttp://colab.interlegis.gov.br/wiki/HOWTO-Migracao23-24\033[m"
#    echo -e "\033[1;31mou\033[m"
#    echo -e "\033[1;31mhttp://colab.interlegis.gov.br/wiki/HOWTO-Migracao24-25\033[m"
#    echo -e "\033[1;31mDependendo da sua versao\033[m"
#    echo -e "\033[1;31mRoteiro alternativo\033[m"
#    echo -e "\033[1;31mInstalacao abortada\033[m"
#    echo ""
#    exit 1
#fi

############################
# Configure zlib and libjpeg
#
# This install requires the zlib and libjpeg libraries, which are
# usually installed as system libraries.
# Set the options below to
#   auto -   to have this program determine whether or not you need the
#            library installed, and where.
#   global - to force install to /usr/local/ (requires root)
#   local  - to force install to $INSTALL_HOME (or $LOCAL_HOME) for static link
#   no     - to force no install
INSTALL_ZLIB=auto
INSTALL_JPEG=auto

# library need determination
if [ $INSTALL_ZLIB = "auto" ]
then
    # check for zconf.h, zlib.h, libz.[so|a]
    if [ -e /usr/include/zconf.h ] || [ -e /usr/local/include/zconf.h ]
    then
        HAVE_ZCONF=1
        #echo have zconf
    else
        HAVE_ZCONF=0
        #echo no zconf
    fi
        if [ -e /usr/include/zlib.h ] || [ -e /usr/local/include/zlib.h ]
        then
                HAVE_ZLIB=1
                #echo have zlib
        else
                HAVE_ZLIB=0
                #echo no zlib
        fi
        if [ -e /usr/lib/libz.so ] || [ -e /usr/local/lib/libz.so ] || \
       [ -e /usr/lib/libz.dylib ] || [ -e /usr/local/lib/libz.dylib ] || \
       [ -e /usr/lib/libz.a ] || [ -e /usr/local/lib/libz.a ]
        then
                HAVE_LIBZ=1
                #echo have libz
        else
                HAVE_LIBZ=0
                #echo no libz
        fi
    if [ $HAVE_ZCONF -eq 1 ] && [ $HAVE_ZLIB -eq 1 ] && [ $HAVE_LIBZ -eq 1 ]
    then
        INSTALL_ZLIB=no
        #echo do not install zlib
    fi
    if [ $INSTALL_ZLIB = "auto" ] && [ $ROOT_INSTALL -eq 1 ]
    then
        INSTALL_ZLIB="global"
    fi
    if [ $INSTALL_ZLIB = "auto" ]
    then
        INSTALL_ZLIB="local"
    fi
    echo -e "\033[32mzlib installation: $INSTALL_ZLIB\033[m"
fi

if [ $INSTALL_JPEG = "auto" ]
then
    # check for jpeglib.h and libjpeg.[so|a]
    if [ -e /usr/include/jpeglib.h ] || [ -e /usr/local/include/jpeglib.h ]
    then
        HAVE_JPEGH=1
    else
        HAVE_JPEGH=0
    fi
    if [ -e /usr/lib/libjpeg.so ] || [ -e /usr/local/lib/libjpeg.so ] || \
       [ -e /usr/lib/libjpeg.dylib ] || [ -e /usr/local/lib/libjpeg.dylib ] || \
       [ -e /usr/lib/libjpeg.a ] || [ -e /usr/local/lib/libjpeg.a ]
    then
        HAVE_LIBJPEG=1
    else
        HAVE_LIBJPEG=0
    fi
    if [ $HAVE_JPEGH -eq 1 ] && [ $HAVE_LIBJPEG -eq 1 ]
    then
        INSTALL_JPEG="no"
    fi
    if [ $INSTALL_JPEG = "auto" ] && [ $ROOT_INSTALL -eq 1 ]
    then
        INSTALL_JPEG="global"
    fi
    if [ $INSTALL_JPEG = "auto" ]
    then
        INSTALL_JPEG="local"
    fi
    echo -e "\033[32mlibjpeg installation: $INSTALL_JPEG\033[m"
fi


#############################
# Preflight dependency checks
#
# Abort install if not running as root
if [ `whoami` != root ] && [ $ROOT_INSTALL -eq 1 ]
then
    echo "Este script de instalação precisa ser executado como root.  Uso: sudo ./install.sh  ( or su ; ./install.sh )."
    exit 1
fi

# Abort install if no gcc
if [ ! -e /usr/bin/gcc ]
then
    echo "Nota: gcc é necessário para a instalação. Saindo agora."
    exit 1
fi

# Abort install if no g++
if [ ! -e /usr/bin/g++ ]
then
    echo "Nota: g++ é necessário para a instalação. Saindo agora."
    exit 1
fi

# Abort install if no make
if [ ! -e /usr/bin/make ]
then
    echo "Nota: make é necessário para a instalação. Saindo agora."
    exit 1
fi

# Abort install if this script is not run from within it's parent folder
if [ ! -e $PACKAGES_DIR ]
then
    echo "Nota: Este script de instalação precisa ser executado dentro de um diretório.  Uso: sudo ./install.sh  (or su ; ./install.sh)"
    exit 1
fi


#################################
# Install will begin in 3 seconds
echo ""
echo -e "\033[32mInstalando SAPL 2.5 em $INSTALL_HOME\033[m"
sleep 3
echo ""


##################
# build zlib 1.2.3
# Note that, even though we're building static libraries, python
# is going to try to build a shared library for it's own use.
# The "-fPIC" flag is thus required for some platforms.
if [ "X$INSTALL_ZLIB" = "Xglobal" ]
then
    echo "Compilando e instalando zlib ..."
    cd $PKG
    $GNU_TAR $TAR_BZIP2_FLAG -xf $ZLIB_TB
    chmod -R 775 $ZLIB_DIR
    cd $ZLIB_DIR
    CFLAGS="-fPIC" ./configure
    $GNU_MAKE test
    $GNU_MAKE install
    cd $PKG
    if [ -d $ZLIB_DIR ]
    then
        rm -rf $ZLIB_DIR
    fi
elif [ "X$INSTALL_ZLIB" = "Xlocal" ]
then
    echo "Compilando e instalando zlib local ..."
    cd $PKG
    $GNU_TAR $TAR_BZIP2_FLAG -xf $ZLIB_TB
    chmod -R 775 $ZLIB_DIR
    cd $ZLIB_DIR
    CFLAGS="-fPIC" ./configure --prefix=$LOCAL_HOME
    $GNU_MAKE test
    $GNU_MAKE install
    cd $PKG
    if [ -d $ZLIB_DIR ]
    then
        rm -rf $ZLIB_DIR
    fi
    if [ ! -e "$LOCAL_HOME/lib/libz.a" ]
    then
        echo "Instalacao local da zlib falhou"
        exit 1
    fi
else
    echo "Pulando compilacao e instalacao da zlib"
fi


###################
# build libjpeg v6b
if [ "X$INSTALL_JPEG" = "Xglobal" ]
then
    echo "Compilando e instalando bibliotecas jpeg no sistema ..."

    # It's not impossible that the /usr/local hierarchy doesn't
    # exist. The libjpeg install will not create it itself.
    # (The zlib install will, but we can't count on it having
    # run, since we've made it an option.)
    if [ ! -e /usr/local ]
    then
        mkdir /usr/local
    fi
    if [ ! -e /usr/local/bin ]
    then
        mkdir /usr/local/bin
    fi
    if [ ! -e /usr/local/include ]
    then
        mkdir /usr/local/include
    fi
    if [ ! -e /usr/local/lib ]
    then
        mkdir /usr/local/lib
    fi
    if [ ! -e /usr/local/man ]
    then
        mkdir /usr/local/man
    fi
    if [ ! -e /usr/local/man/man1 ]
    then
        mkdir /usr/local/man/man1
    fi

    cd $PKG
    $GNU_TAR $TAR_BZIP2_FLAG -xf $JPEG_TB
    chmod -R 775 $JPEG_DIR
    cd $JPEG_DIR
    # Oddities to workaround: on Mac OS X, using the "--enable-static"
    # flag will cause the make to fail. So, we need to manually
    # create and place the static library.
    ./configure CFLAGS='-fPIC'
    $GNU_MAKE
    $GNU_MAKE install
    ranlib libjpeg.a
    cp libjpeg.a /usr/local/lib
    cp *.h /usr/local/include
    cd $PKG
    if [ -d $JPEG_DIR ]
    then
            rm -rf $JPEG_DIR
    fi
elif [ "X$INSTALL_JPEG" = "Xlocal" ]
then
    echo "Compilando e instalando bibliotecas jpeg locais ..."

    mkdir $LOCAL_HOME/lib
    mkdir $LOCAL_HOME/bin
    mkdir $LOCAL_HOME/include
    mkdir $LOCAL_HOME/man
    mkdir $LOCAL_HOME/man/man1

    cd $PKG
    $GNU_TAR $TAR_BZIP2_FLAG -xf $JPEG_TB
    chmod -R 775 $JPEG_DIR
    cd $JPEG_DIR
    # Oddities to workaround: on Mac OS X, using the "--enable-static"
    # flag will cause the make to fail. So, we need to manually
    # create and place the static library.
    ./configure CFLAGS='-fPIC' --prefix=$LOCAL_HOME
    $GNU_MAKE
    $GNU_MAKE install
    # --enable-static flag doesn't work on OS X, make sure
    # we get an install anyway
    if [ ! -e "$LOCAL_HOME/lib/libjpeg.a" ]
    then
        ranlib libjpeg.a
        cp libjpeg.a $LOCAL_HOME/lib
        cp *.h $LOCAL_HOME/include
    fi

    if [ ! -e "$LOCAL_HOME/lib/libjpeg.a" ]
    then
        echo "Instalacao local da libjpeg falhou"
        exit 1
    fi

    cd $PKG
    if [ -d $JPEG_DIR ]
    then
            rm -rf $JPEG_DIR
    fi
else
    echo "Pulando compilacao e instalacao da libjpeg"
fi


######################################
# Build Python (with readline support)
# note: Install readline before running this script
echo -e "\033[32mInstalando Python 2.4.6...\033[m"
cd $PKG
$GNU_TAR -jxf $PYTHON_TB
chmod -R 775 $PYTHON_DIR
cd $PYTHON_DIR
# Look for Leopard
uname -v | grep "Darwin Kernel Version 9" > /dev/null
if [ "$?" = "0" ]; then
    # patch for Leopard setpgrp
    sed -E -e "s|(CPPFLAGS=.+)|\\1 -D__DARWIN_UNIX03|" -i.bak Makefile.pre.in
    # if /opt/local is available, make sure it's included in the component
    # build so that we can get fixed readline lib
    if [ -d /opt/local/include ] && [ -d /opt/local/lib ]; then
        sed -E -e "s|#(add_dir_to_list\(self\.compiler\..+_dirs, '/opt/local/)|\\1|" -i.bak setup.py
    fi
fi
./configure \
    --prefix=$PY_HOME \
    --with-readline \
    --with-zlib \
    --disable-tk \
    --with-gcc="$GCC"
make
make install
# make sistecustomize.py file
touch $SITECUSTOMIZE_FILE
echo "import sys" >> "$SITECUSTOMIZE_FILE"
echo "sys.setdefaultencoding('iso-8859-1')" >> "$SITECUSTOMIZE_FILE"

cd $PKG
if [ -d $PYTHON_DIR ]
then
    rm -rf $PYTHON_DIR
fi

#########################
# install ReportLab 2.5
echo -e "\033[32mInstalando ReportLab (PDF toolkit)...\033[m"
cd $PKG
$GNU_TAR -jxf $REPLAB_TB
mv $REPLAB_DIR/reportlab $SITE_PACKAGES/reportlab
cd $PKG
if [ -d $REPLAB_DIR ]
then
    rm -rf $REPLAB_DIR
fi

########################
# install trml2pdf 1.2
echo -e "\033[32mInstalando trml2pdf...\033[m"
cd $PKG
$GNU_TAR -jxf $TRML2PDF_TB
mv $TRML2PDF_DIR $SITE_PACKAGES/$TRML2PDF_DIR
cd $PKG
if [ -d $TRML2PDF_DIR ]
then
    rm -rf $TRML2PDF_DIR
fi

###################
# build PyXML 0.8.4
echo -e "\033[32mCompilando e instalando PyXML ...\033[m"
cd $PKG
$GNU_TAR -jxf $PYXML_TB
chmod -R 775 $PYXML_DIR
cd $PYXML_DIR
$PY ./setup.py build
$PY ./setup.py install
cd $PKG
if [ -d $PYXML_DIR ]
then
    rm -rf $PYXML_DIR
fi

#########################
# install setuptools
echo -e "\033[32mInstalando setuptools via ez_setup...\033[m"
cd $PKG
$GNU_TAR -jxf $SETUP_TB
$PY ./ez_setup.py -l 
if [ -e setup*.egg ]
then
    rm -rf setup*.egg
fi
rm ez_setup.py

#################
# build PIL 1.1.6
echo -e "\033[32mCompilando e instalando PIL ...\033[m"
cd $PKG
$GNU_TAR -jxf $PIL_TB
chmod -R 775 $PIL_DIR
cd $PIL_DIR
$PY ./setup.py build_ext -i
$PY ./selftest.py
$PY ./setup.py install
cd $PKG
if [ -d $PIL_DIR ]
then
    rm -rf $PIL_DIR
fi

#####################
# install ElementTree
echo -e "\033[32mInstalando ElementTree ...\033[m"
cd $PKG
$GNU_TAR -jxf $ETREE_TB
chmod -R 775 $ETREE_DIR
cd $ETREE_DIR
$PY ./setup.py build
$PY ./setup.py install
cd $PKG
if [ -d $ETREE_DIR ]
then
        rm -rf $ETREE_DIR
fi

#################
# install libxml2
echo -e "\033[32mInstalando libxml2 ...\033[m"
cd $PKG
$GNU_TAR -jxf $LIBXML2_TB
chmod -R 775 $LIBXML2_DIR
cd $LIBXML2_DIR
./configure --with-python=$PY
make
make install
cd $PKG
if [ -d $LIBXML2_DIR ]
then
    rm -rf $LIBXML2_DIR
fi

#################
# install libxslt
echo -e "\033[32mInstalando libxslt ...\033[m"
cd $PKG
$GNU_TAR -jxf $LIBXSLT_TB
chmod -R 775 $LIBXSLT_DIR
cd $LIBXSLT_DIR
./configure --with-python=$PY --prefix=/usr/local --with-libxml-prefix=/usr/local --with-libxml-include-prefix=/usr/local/include --with-libxml-libs-prefix=/usr/local/lib
make
make install
cd $PKG
if [ -d $LIBXSLT_DIR ]
then
    rm -rf $LIBXSLT_DIR
fi

########################
# Install libxml2-python
# Properly configure libxml2-python to use our libxml2/libxslt
echo -e "\033[32mConfigurando libxml2-python ...\033[m"
cd $PKG
$GNU_TAR -jxf $PYLIBXML2_TB
chmod -R 775 $PYLIBXML2_DIR
cd $PYLIBXML2_DIR
# Point libxml2-python to /usr/local/lib and /usr/local/include for libxml2/libxslt headers
# escape string for sed-compatible string replacement (warning: insane hack ahead)
# replace ROOT with /usr/local (to bypass OSX's libxml2/libxslt)
FIND="ROOT = r'/usr'"
REPLACE="ROOT = r'/usr/local'"
ESCAPED_REPLACE=`echo $REPLACE | sed 's/\//\\\@/g' | tr @ /`
# replace /usr/include with /usr/local/include (to bypass OSX's libxml2/libxslt)
FIND2="/usr/include"
REPLACE2="/usr/local/include"
ESCAPED_REPLACE2=`echo $REPLACE2 | sed 's/\//\\\@/g' | tr @ /`
ESCAPED_REPLACE3=`echo $FIND2 | sed 's/\//\\\@/g' | tr @ /`
FILE=setup.py
mv $FILE $FILE.tmp
cat $FILE.tmp | sed "s/^.*ROOT = r\'\/usr\'.*$/$ESCAPED_REPLACE/g" | \
sed "s/^.*\/usr\/include.*$/\"$ESCAPED_REPLACE2\", \"$ESCAPED_REPLACE3\",/g" > $FILE
rm $FILE.tmp
# With the proper libraries in setup.py, now install libxml2-python
$PY ./setup.py install
cd $PKG
if [ -d $PYLIBXML2_DIR ]
then
    rm -rf $PYLIBXML2_DIR
fi
$PY_HOME/bin/python -c "import libxml2"
if [ $? -gt 0 ]
then
    echo "Python libxml2 support is missing; something went wrong in the libxml2 build;"
    echo "probably missing development headers."
    echo "This is an optional component. It's absence will result in a log warning."
fi

#################
# install lxml
echo -e "\033[32mCompilando e Instalando lxml-2.3.1 ...\033[m"
cd $PKG
$GNU_TAR -jxf $LXML2_TB
chmod -R 775 $LXML2_DIR
cd $LXML2_DIR
$PY ./setup.py build --with-xslt-config=/usr/local/include/libxslt
$PY ./setup.py install
cd $PKG
if [ -d $LXML2_DIR ]
then
    rm -rf $LXML2_DIR
fi


##########################
# install PyOAI 2.4.3
echo -e "\033[32mCompilando e instalando PyOAI (OAI-PMH)...\033[m"
cd $PKG
$GNU_TAR -jxf $PYOAI_TB
chmod -R 775 $PYOAI_DIR
cd $PYOAI_DIR
$PY ./setup.py build
$PY ./setup.py install
cd $PKG
if [ -d $PYOAI_DIR ]
then
    rm -rf $PYOAI_DIR
fi

###################
# build Zope 2.9.12
echo -e "\033[32mCompilando e instalando Zope 2.9.12 ...\033[m"
cd $PKG
$GNU_TAR -jxf $ZOPE_TB
chmod -R 775 $ZOPE_DIR
cd $ZOPE_DIR
./configure --with-python=$PY --prefix=$ZOPE_HOME
make
make install
cd $PKG
if [ -d $ZOPE_DIR ]
then
    rm -rf $ZOPE_DIR
fi

###################
# install MySQL-python
echo -e "\033[32mCompilando e instalando MySQL-python ...\033[m"
cd $PKG
$GNU_TAR -jxf $MYSQLPYTHON_TB
cd $MYSQLPYTHON_DIR
$PY setup.py build
$PY setup.py install
if [ $? -gt 0 ]; then
    echo ""
    echo -e "\033[1;31mErro na compilação do python-mysql!\033[m";
    echo -e "\033[1;31mInstalação abortada!\033[m";
    echo ""
    exit 1
fi
cd $PKG
if [ -d $MYSQLPYTHON_DIR ]
then
    rm -rf $MYSQLPYTHON_DIR
fi

######################
# Postinstall steps
######################

##########################
# Generate random password
echo -e "\033[32mGenerando senha randomica ...\033[m"
cd $PKG
$GNU_TAR -jxf $HSCRIPTS_TB
chmod -R 775 $HSCRIPTS_DIR
cd $HSCRIPTS_DIR
PASSWORD_SCRIPT=./generateRandomPassword.py
PASSWORD=`$PY $PASSWORD_SCRIPT`
cd $PKG


####################
# Create SAPL instance

echo -e "\033[32mCriando instancia SAPL ...\033[m"
$ZOPE_HOME/bin/mkzopeinstance.py --dir=$SAPL_HOME --user=admin:$PASSWORD

#########################################
# Configure mount point
echo "<zodb_db documentos>
    # Zodb para conter documento do sapl
    <filestorage>
      path $SAPL_HOME/var/DocumentosSapl.fs
    </filestorage>
    mount-point /sapl/sapl_documentos
</zodb_db>

#<zodb_db antigo>
# Mount-point apontando para um Data.fs
# de versão anterior
#    <filestorage>
#      path $SAPL_HOME/old/Data.fs
#    </filestorage>
#    mount-point /sapl_old
#</zodb_db>" >> $SAPL_HOME/etc/zope.conf

########################################
# Criando a pasta 'old' para a migracao

#if [ ! -d $SAPL_HOME/old ]; then
#    mkdir $SAPL_HOME/old
#    chown zope:zope $SAPL_HOME/old
#fi

#####################################
# Set effective-user in etc/zope.conf
# set user in ZEO server
mv $SAPL_HOME/etc/zope.conf $SAPL_HOME/etc/zope.conf.tmp
cat $SAPL_HOME/etc/zope.conf.tmp | sed 's/^.*#.*effective-user.*chrism.*$/effective-user zope/g'> $SAPL_HOME/etc/zope.conf
rm $SAPL_HOME/etc/zope.conf.tmp

###############################################################
# Extract and move SDE tarball to Products folder of Instance
echo -e "\033[32mExtraindo SDE tarball ...\033[m"
cp $PKG/$SDE_TB $INSTALL_HOME/$SDE_TB
cd $INSTALL_HOME
$GNU_TAR -jxf ./$SDE_TB
rm $INSTALL_HOME/$SDE_TB
mv $INSTALL_HOME/$SDE_DIR $PRODUCTS_HOME
chmod -R 775 $PRODUCTS_HOME
cd $PKG

###############################################################
# Extract and move ZMySQLDA tarball to Products folder of Instance
echo -e "\033[32mExtraindo ZMySQLDA tarball ...\033[m"
cp $PKG/$ZMYSQLDA_TB $INSTALL_HOME/$ZMYSQLDA_TB
cd $INSTALL_HOME
$GNU_TAR -jxf ./$ZMYSQLDA_TB
rm $INSTALL_HOME/$ZMYSQLDA_TB
mv $INSTALL_HOME/$ZMYSQLDA_DIR $PRODUCTS_HOME
chmod -R 775 $PRODUCTS_HOME
cd $PKG

###############################################################
# Extract and move CMFL tarball to Products folder of Instance
echo -e "\033[32mExtraindo CMF tarball ...\033[m"
cp $PKG/$CMF_TB $INSTALL_HOME/$CMF_TB
cd $INSTALL_HOME
$GNU_TAR -jxf ./$CMF_TB
rm $INSTALL_HOME/$CMF_TB
mv $INSTALL_HOME/$CMF_DIR/* $PRODUCTS_HOME
if [ -d $CMF_DIR ]
then
    rm -rf $CMF_DIR
fi
chmod -R 775 $PRODUCTS_HOME
cd $PKG

######################
# Install TextIndexNG2
echo -e "\033[32mInstalando TextIndexNG2\033[m"
cp $PKG/$TXNG2_TB $PRODUCTS_HOME
cd $PRODUCTS_HOME
$GNU_TAR -jxf ./$TXNG2_TB
chmod -R 775 ./$TXNG2_DIR
rm $PRODUCTS_HOME/$TXNG2_TB
cd $PRODUCTS_HOME/$TXNG2_DIR
$PY ./setup.py install
cd $PKG

###############################################################
# Extract and move SAPL tarball to Products folder of Instance
echo -e "\033[32mExtraindo o SAPL tarball ...\033[m"
cp $PKG/$SAPL_TB $INSTALL_HOME/$SAPL_TB
cd $INSTALL_HOME
$GNU_TAR -jxf ./$SAPL_TB
svn up $SAPL_DIR
mv $SAPL_DIR $PRODUCTS_HOME
mv $PRODUCTS_HOME/$SAPL_DIR/Products/PythonModules $PRODUCTS_HOME
rm $INSTALL_HOME/$SAPL_TB
chmod -R 775 $PRODUCTS_HOME
cd $PKG

########################
# Write password to file
echo -e "\033[32mEscrevendo, em arquivo, o password randomico ...\033[m"
touch $PWFILE
# Write admin password and startup/shutdown info to password file
echo "Use as informações da conta a seguir para logar no Zope Management Interface" >> "$PWFILE"
echo "A conta tem privilégios de 'Manager'." >> "$PWFILE"
echo " " >> "$PWFILE"
echo "  Username: admin" >> "$PWFILE"
echo "  Senha: $PASSWORD" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "Antes de iniciar o SAPL, você deverá rever as configurações em:" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "  $SAPL_HOME/etc/zope.conf" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "Ajuste as portas do SAPL antes de inicar seu uso, caso necessário" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "Para iniciar o SAPL, execute o seguinte comando no terminal:" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "  sudo $SAPL_STARTUP_SCRIPT" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "Para parar o SAPL, execute o seguinte comando no terminal:" >> "$PWFILE"
echo " " >> "$PWFILE"
echo "  sudo $SAPL_SHUTDOWN_SCRIPT" >> "$PWFILE"
echo " " >> "$PWFILE"

####################################################
# Write SAPL startup/shutdown/restart scripts to file
# ---- DESABILITADO PARA INSTALACAO AUTOMATICA VIA PUPPET ---
# Write startup script
#echo -e "\033[32mEscrevendo o arquivo de script startup ...\033[m"
#touch $SAPL_STARTUP_SCRIPT
#echo "#!/bin/sh" >> "$SAPL_STARTUP_SCRIPT"
#echo "#" >> "$SAPL_STARTUP_SCRIPT"
#echo "PYTHON_EGG_CACHE=$SAPL_HOME/var/.python-eggs" >> "$SAPL_STARTUP_SCRIPT"
#echo "export PYTHON_EGG_CACHE" >> "$SAPL_STARTUP_SCRIPT"
#echo "# SAPL startup script" >> "$SAPL_STARTUP_SCRIPT"
#echo "#" >> "$SAPL_STARTUP_SCRIPT"
#echo "echo 'Starting MySQL server...'" >> "$SAPL_STARTUP_SCRIPT"
#echo "$MYSQL_HOME/bin/mysqld_safe --user=mysql &" >> "$SAPL_STARTUP_SCRIPT"
#echo "sleep 1" >> "$SAPL_STARTUP_SCRIPT"
#echo "echo 'Starting SAPL server...'" >> "$SAPL_STARTUP_SCRIPT"
#echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> "$SAPL_STARTUP_SCRIPT"
#echo "$SAPL_HOME/bin/zopectl start" >> "$SAPL_STARTUP_SCRIPT"
#
# Write shutdown script
#echo -e "\033[32mEscrevendo o arquivo de script shutdown ...\033[m"
#touch $SAPL_SHUTDOWN_SCRIPT
#echo "#!/bin/sh" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "#" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "# SAPL shutdown script" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "#" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "echo 'Stopping SAPL server...'" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "$SAPL_HOME/bin/zopectl stop" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "sleep 1" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "echo 'Stopping MySQL server...'" >> "$SAPL_SHUTDOWN_SCRIPT"
#echo "$MYSQL_HOME/bin/mysqladmin -u root shutdown" >> "$SAPL_SHUTDOWN_SCRIPT"

# Write restart script
#echo -e "\033[32mEscrevendo o arquivo de script restart ...\033[m"
#touch $SAPL_RESTART_SCRIPT
#echo "#!/bin/sh" >> "$SAPL_RESTART_SCRIPT"
#echo "#" >> "$SAPL_RESTART_SCRIPT"
#echo "# SAPL restart script" >> "$SAPL_RESTART_SCRIPT"
#echo "#" >> "$SAPL_RESTART_SCRIPT"
#echo "echo 'Restarting MySQL server...'" >> "$SAPL_RESTART_SCRIPT"
#echo "$MYSQL_HOME/bin/mysqladmin -u root shutdown" >> "$SAPL_RESTART_SCRIPT"
#echo "$MYSQL_HOME/bin/mysqld_safe --user=mysql &" >> "$SAPL_RESTART_SCRIPT"
#echo "echo 'Restarting SAPL server...'" >> "$SAPL_RESTART_SCRIPT"
#echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> "$SAPL_RESTART_SCRIPT"
#echo "$SAPL_HOME/bin/zopectl restart" >> "$SAPL_RESTART_SCRIPT"

#########################################################
# Fix path for Zope command line utils (repozo.py et.al.)
echo -e "\033[32mEscrevendo o arquivo de script restart ...\033[m"
echo "$INSTALL_HOME/lib/python" > "$SITE_PACKAGES/zope.pth"

#####################################
# Clean up any .DS_Store files (OS X)
find $INSTALL_HOME -name '.DS_Store' -delete

################################################
# Add user account via platform-specific methods
echo -e "\033[32mAdicionando usuario 'zope' ao sistema ...\033[m"
# Add unprivileged user account via 'useradd', if exists (Linux)
if [ -e /usr/sbin/useradd ]
then
    /usr/sbin/useradd $EFFECTIVE_USER
# Add unprivileged user account via 'adduser', if exists (*BSD)
elif [ -e /usr/sbin/adduser ]
then
    /usr/sbin/adduser -f $PKG/$HSCRIPTS_DIR/adduser.txt
fi

# Add zope user to NetInfo if we're on Mac OS X
# try dscl for Mac OS X
if [ -e /usr/bin/dscl ]; then
    UNAME=$EFFECTIVE_USER
    # find or create a $UNAME group
    dscl . search /groups RecordName $UNAME | grep "($UNAME)" > /dev/null
    if [ "$?" = "0" ]; then
        gid=$(dscl . read /groups/$UNAME PrimaryGroupID | cut -d" " -f2 -)
    else
        gid="50"
        dscl . search /groups PrimaryGroupID $gid | grep "($gid)" > /dev/null
        while [ "$?" = "0" ]; do
            if [ "$gid" = "500" ]; then
                echo Falhou ao achar uid disponível abaixo de 500. Saindo.
                exit 1
            else
                gid=$(($gid + 1))
                dscl . search /groups PrimaryGroupID $gid | grep "($gid)" > /dev/null
            fi
        done
        echo Criando grupo $UNAME com gid $gid via dscl...
        dscl . -create /groups/$UNAME
        dscl . -create /groups/$UNAME gid $gid
    fi
    # find or create a $UNAME user
    dscl . search /users RecordName $UNAME | grep "($UNAME)" > /dev/null
    if [ "$?" != "0" ]; then
        # Add zope user via dscl, with a uid below 500
        echo Criando usuário zope
        uiddef=$gid
        dscl . search /users UniqueID $uiddef | grep "($uiddef)" > /dev/null
        while [ "$?" = "0" ]; do
            if [ "$uiddef" = "500" ]; then
                echo Falhou ao achar uid disponível abaixo de 500. Saindo.
                exit 1
            else
                uiddef=$(($uiddef + 1))
                dscl . search /users UniqueID $uiddef | grep "($uiddef)" > /dev/null
            fi
        done
        #
        echo Criando usuário $UNAME com uid $uiddef via dscl...
        dscl . -create /users/$UNAME
        if [ "$?" = "0" ]; then
            dscl . -create /users/$UNAME UniqueID $uiddef
            dscl . -create /users/$UNAME RealName "SAPL Administrator"
            dscl . -create /users/$UNAME PrimaryGroupID $gid
            dscl . -create /users/$UNAME NFSHomeDirectory $INSTALL_HOME
            dscl . -create /users/$UNAME Password '*'
            dscl . -create /users/$UNAME UserShell /usr/bin/false
        else
            echo "Criação do usuário zope falhou"
            exit 1
        fi
    else
        oldgid=$(dscl . read /users/$UNAME PrimaryGroupID | cut -f2 -d" " -)
        if [ $oldgid != $gid ]; then
            dscl . -create /users/$UNAME PrimaryGroupID $gid
        fi
    fi
elif [ -e /usr/bin/niutil ]; then
    niutil -readprop -t localhost/local /users/$EFFECTIVE_USER uid
    if [ "$?" != "0" ]
    then
        # Add zope user to NetInfo, with a uid below 500
        echo Criando o usuário zope
        uiddef="50"
        niutil -readprop -t localhost/local /users/uid=$uiddef name
        while [ "$?" = "0" ]
        do
            if [ "$uiddef" = "500" ]
            then
                echo Falhou ao achar uid disponível abaixo de 500. Saindo.
                exit 1
            else
                uiddef=`echo $uiddef + 1 | bc`
                niutil -readprop -t localhost/local /users/uid=$uiddef name
            fi
        done
        #
        echo Criando usuário zope com o uid $uiddef...
        niutil -create  -t localhost/local /users/$EFFECTIVE_USER
        if [ "$?" = "0" ]
        then
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER realname "SAPL Administrator"
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER uid $uiddef
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER gid 20
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER home "$INSTALL_HOME"
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER name $EFFECTIVE_USER
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER passwd '*'
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER shell /bin/tcsh
            niutil -createprop -t localhost/local /users/$EFFECTIVE_USER _writers_passwd $EFFECTIVE_USER
        else
            echo "Criação do usuário zope falhou"
            exit 1
        fi
    fi
fi

###########################################
# Clean up helper scripts directory
cd $PKG
if [ -d $HSCRIPTS_DIR ]
then
    rm -rf $HSCRIPTS_DIR
fi

###########################################
# Set appropriate ownership and permissions
echo -e "\033[32mColocando as propriedades e permissões apropriadas aos arquivos ...\033[m"
chmod -R 775 $INSTALL_HOME
chmod 660 "$PWFILE"
if [ `whoami` = root ]
then
    chown -R $EFFECTIVE_USER $INSTALL_HOME
fi

# Set appropriate ownership and permissions to MySQL
#echo "Colocando a propriedade e a permissão para o MySQL..."
#chmod -R 755 $MYSQL_HOME
#chown -R root $MYSQL_HOME
#chgrp -R mysql $MYSQL_HOME
#chown -R mysql $MYSQL_HOME/var

######################
# Import sql script to database
# ---- DESABILITADO PARA INSTALACAO AUTOMATICA VIA PUPPET
#echo -e "\033[32mImportando o script do banco de dados\033[m"
#if [ -z $senha ]; then
#    mysql -h 127.0.0.1 -u $usuario < $PRODUCTS_HOME/$SAPL_DIR/instalacao/sapl_create.sql
#    mysql -h 127.0.0.1 -u $usuario interlegis < $PRODUCTS_HOME/$SAPL_DIR/instalacao/sapl.sql
#else
#    mysql -h 127.0.0.1 -u $usuario --password=$senha < $PRODUCTS_HOME/$SAPL_DIR/instalacao/sapl_create.sql
#    mysql -h 127.0.0.1 -u $usuario interlegis --password=$senha < $PRODUCTS_HOME/$SAPL_DIR/instalacao/sapl.sql
#fi
#if [ $? -gt 0 ]; then
#    echo ""
#    echo -e "\033[1;31mErro na importação da estrutura da base de dados!\033[m";
#    echo -e "\033[1;31mVerifique o usuário e senha e refaça a instalação!\033[m";
#    echo -e "\033[1;31mInstalação abortada!\033[m";
#    echo ""
#    exit 1
#fi

#######################
# Building the SAPL instance
# --- DESABILITADO PARA INSTALACAO AUTOMATICA VIA PUPPET
#echo -e "\033[32mConfigurando a instancia SAPL\033[m"
#$SAPL_SHUTDOWN_SCRIPT
#sleep 1
#echo "cp $PRODUCTS_HOME/$SAPL_DIR/import/* $SAPL_HOME/import/"
#echo "$SAPL_HOME/bin/zopectl run $PRODUCTS_HOME/$SAPL_DIR/instalacao/sapl_configurador.py"
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
#cp $PRODUCTS_HOME/$SAPL_DIR/import/* $SAPL_HOME/import/
#$SAPL_HOME/bin/zopectl run $PRODUCTS_HOME/$SAPL_DIR/instalacao/sapl_configurador.py
#$SAPL_STARTUP_SCRIPT
#sleep 1

#######################
# Conclude installation
if [ -d $INSTALL_HOME ]
    then
    mkdir $RECEIPTS_HOME
    echo "Instalacao do SAPL 2.5 completada em" `date` > $RECEIPTS_HOME/installReceipt.txt
    echo " "
    echo "#####################################################################"
    echo "######################  Instalacao Completa  ########################"
    echo " "
    cat $INSTALL_HOME/adminPassword.txt
    echo " "
    echo "SAPL foi instalado com sucesso em $INSTALL_HOME"
    echo "Leia o arquivo $INSTALL_HOME/adminPassword.txt para ver a senha e instruções para inicialização"
    echo " "
    echo "Submissão de feedback e report de erros em http://colab.interlegis.gov.br/newticket"
    echo " "
    echo "Este instalador é mantido por Jean Rodrigo Ferri (jeanferri em interlegis.gov.br)"
    echo " "
else
    echo "Ocorreram erros durante a instalacao. Por favor leia o LEIAME.txt e tente novamente."
fi
