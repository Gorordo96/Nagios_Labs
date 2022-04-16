FROM ubuntu:20.04

# Prerequisitos
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=America/Buenos_Aires apt install -y ssh autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext

# Creacion del usuario Nagios
RUN useradd -d /home/nagios -c "usuario nagios para monitoreo" nagios 

#Instalacion de Plugins
RUN cd /tmp/ && \
    wget -O /tmp/nagiosplugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.0/nagios-plugins-2.4.0.tar.gz && \
    tar xzvf /tmp/nagiosplugins.tar.gz && \
    cd /tmp/nagios-plugins-2.4.0 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && make install 

#Instalacion del NRPE
RUN cd /tmp/ && \
    wget -O /tmp/nagiosnrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/refs/tags/nrpe-4.0.3.tar.gz && \
    tar xzvf /tmp/nagiosnrpe.tar.gz && \
    cd /tmp/nrpe-nrpe-4.0.3 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make all && make install && make install-config 

#Iniciando los servicios
CMD exec /bin/bash -c "service ssh start && chmod u+x /tmp/nrpe-nrpe-4.0.3/startup/default-init && /tmp/nrpe-nrpe-4.0.3/startup/default-init start && trap : TERM INT; sleep infinity & wait"