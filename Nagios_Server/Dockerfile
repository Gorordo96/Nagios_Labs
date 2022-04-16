FROM ubuntu:20.04
# Prerequisitos
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive TZ=America/Buenos_Aires apt install -y tzdata autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.4 libgd-dev vim ufw ssh
# Descargar fuentes
RUN cd /tmp && \
    wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz && \
    tar xzvf nagioscore.tar.gz
# Compilar los fuentes
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \
    ./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
    make all
# Crear usuario y grupo 
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \
    make install-groups-users && \
    usermod -a -G nagios www-data
# Instalar binarios
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \
    make install
# Instalar servicio / Demonio
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \
    make install-daemoninit
# Instalacion del modo comando
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \
    make install-commandmode
# Instalacion de archivos de configuracion base para que nagios pueda iniciar
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \ 
    make install-config
# Instalacion de los archivos de configuracion de apache
RUN cd /tmp/nagioscore-nagios-4.4.6/ && \
    make install-webconf && \
    a2enmod rewrite && \
    a2enmod cgi
# Configuracion de firewall 
RUN ufw allow Apache && \
    ufw reload
# Creando usuario admin nagios
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
# Descargando NagiosQL y configurandolo
RUN apt install -y php libmcrypt-dev php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear gcc php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2 mariadb-server build-essential
RUN pear channel-update pear.php.net && pear install HTML_Template_IT
RUN pecl install mcrypt && ls -l /etc/php
RUN echo "extension=mcrypt.so" >> /etc/php/7.4/apache2/php.ini && \
    echo "date.timezone=America/Buenos_Aires"  >> /etc/php/7.4/apache2/php.ini && \
    service apache2 restart 
RUN wget -O nagiosql.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.4.1/nagiosql-3.4.1-git2020-01-19.tar.gz/download && \
    tar xvfz nagiosql.tar.gz  && \
    cp -vprf nagiosql-3.4.1/ /usr/local/nagios/share/nagiosql
RUN service mysql start && \
    mariadb -e "CREATE USER 'nagiosql'@'localhost' IDENTIFIED BY 'pass_nagiosql';" && \
    mariadb -e "GRANT ALL PRIVILEGES ON *.* TO 'nagiosql'@'localhost';" && \
    mariadb -e "GRANT USAGE ON *.* TO 'nagiosql'@'localhost' WITH GRANT OPTION;" && \
    mariadb -e "FLUSH PRIVILEGES;"
RUN mkdir /usr/local/nagios/etc/nagiosql && \
    mkdir /usr/local/nagios/etc/nagiosql/hosts && \
    mkdir /usr/local/nagios/etc/nagiosql/services && \
    mkdir /usr/local/nagios/etc/nagiosql/backup && \
    mkdir /usr/local/nagios/etc/nagiosql/backup/hosts && \
    mkdir /usr/local/nagios/etc/nagiosql/backup/services && \
    chown nagios:nagios /usr/local/nagios/var/rw && \
    chown -R nagios.www-data /usr/local/nagios/etc/nagiosql && \
    chown nagios.www-data /usr/local/nagios/etc/nagios.cfg && \
    chown nagios.www-data /usr/local/nagios/etc/cgi.cfg && \
    chown nagios.www-data /usr/local/nagios/etc/resource.cfg && \
    chown nagios.www-data /usr/local/nagios/var/spool/checkresults && \
    chown nagios:www-data /usr/local/nagios/bin/nagios && \
    chmod 775 /usr/local/nagios/etc/ && \
    chmod 777 /usr/local/nagios/bin/nagios && \
    chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
    chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
    chmod 775 /usr/local/nagios/etc/ && \
    chmod 664 /usr/local/nagios/etc/nagios.cfg && \
    chmod 664 /usr/local/nagios/etc/cgi.cfg && \
    chmod g+x /usr/local/nagios/var/rw/ && \
    chgrp www-data /usr/local/nagios/etc/ && \
    chgrp www-data /usr/local/nagios/etc/nagios.cfg && \
    chgrp www-data /usr/local/nagios/etc/cgi.cfg && \
    sed -i 's/^cfg/#cfg/' /usr/local/nagios/etc/nagios.cfg && \
    echo "" >> /usr/local/nagios/etc/nagios.cfg && \
    echo "cfg_dir=/usr/local/nagios/etc/nagiosql" >> /usr/local/nagios/etc/nagios.cfg 

# Instalacion de plugins Nagios
RUN cd /tmp/ && \
    wget -O /tmp/nagiosplugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.0/nagios-plugins-2.4.0.tar.gz && \
    tar xzvf /tmp/nagiosplugins.tar.gz && \
    cd /tmp/nagios-plugins-2.4.0 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && make install 

# Instalacion de NRPE (Nagios Remote Plugin Executor - NRPE)
RUN cd /tmp/ && \
    wget -O /tmp/nagiosnrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/refs/tags/nrpe-4.0.3.tar.gz && \
    tar xzvf /tmp/nagiosnrpe.tar.gz && \
    cd /tmp/nrpe-nrpe-4.0.3 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make check_nrpe && make install-plugin

# Instalacion de ansible.
RUN apt install -y ansible 

# Creacion de carpeta donde estan los host monitoreados
RUN mkdir -p /usr/local/nagios/etc/objects/host_monitor && chown nagios.nagios /usr/local/nagios/etc/objects/host_monitor

# Iniciando servicios
CMD exec /bin/bash -c "service ssh start && service mysql start && service apache2 start && service nagios start && trap : TERM INT; sleep infinity & wait"