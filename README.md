# Laboratorio de Nagios

## Idea General 

Este repositorio tiene como proposito montar una infraestructura de red dockerizada (192.168.50.0/24) para aplicar conceptos basicos de monitoreo.
Esta red posee un servidor con Nagios donde se centraliza el monitoreo. Los nodos a monitorear son equipos Linux, servidores Tomcat y servidores de base de datos.

![Estructura de red dockerizada](https://github.com/Gorordo96/Nagios_Labs/blob/main/Img/Red_dockerizada.png?raw=true)

## Servidor de Monitoreo

El servidor Nagios es accesible desde el navegador utilizando la siguiente informacion: 

* URL:  http://localhost:9090/nagios
* Usuario: nagiosadmin
* Password: nagiosadmin

Tambien puede acceder a nagiosql e instalarlo. A continuacion se listan unas variables de referencia para realizar este procedimiento:

* database_name: nagiosdb
* database_user:nagios
* database_password: nagios
* database_adm_user: nagiosql
* database_adm_password: pass_nagiosql
* nagiosql_user:nagiosql
* nagiosql_password: nagiosql
* import_sample_config: yes
* create_nagiosql_config_path: yes
* /usr/local/nagios/etc/nagiosql
* /usr/local/nagios/etc 

Enlace de referencia: https://www.adictosaltrabajo.com/2011/08/17/nagios-nagiosql-pnp-4nagios/

Respecto al monitoreo de los diferentes equipos, se utiliza NRPE (Nagios Remote Plugin Executor). Es una herramienta de extensión de nagios, utilizada en el host monitoreado. Puede proporcionar información local del host al servidor de monitoreo de nagios. Sin embargo, no es la unica alternativa. Tambien esta disponible el monitoreo via SSH utilizando la utilidad de Nagios "check_ssh".

Enlace de referencia: https://programmerclick.com/article/70921153919/

Para lograr monitorear cualquier servidor remoto con Nagios es necesario tenerlo instalado y configurado tanto en el servidor como en el cliente. Este proceso puede ser tedioso y para nada escalable si hablamos de una arquitectura de red con cien o miles de equipos. Por ello, se presenta el directorio basic_tools que utiliza python para automatizar la construccion de los archivos de configuracion del servidor Nagios y Ansible que instala todo lo necesario en los nodos remotos.

### Ansible scripts

El directorio donde se hacen presentes los script de ansible es "basic_tools/ansible". Alli encontrara los siguientes ficheros:

**hosts.txt**. Este fichero contiene la informacion de los servidores que necesitan ser aprovisionados. Alli, la informacion se divide en tres bloques. "[nagiosclient]", "[tomcatnodes]" y "[postgresnodes]". 
¿A que se debe esta division? ¿Por que?. Porque hay tres playbook diferentes, donde cada uno de ellos hace referencia a uno de estos grupos y ejecutan diferentes tareas. El primero de ellos, "[nagiosclient]" , configura el servidor remoto para que tenga Nagios y el plugins de NRPE configurado correctamente. De esta forma, el nodo remoto es accesible por el servidor de monitoreo. El playbook de ansible que maneja esta parte y utiliza el grupo "[nagiosclient]" es "installnagios.yaml".
El segundo grupo, "[tomcatnodes]" permite identificar y configurar solo aquellos servidores que tengan tomcat. Resulta que el playbook "installpluginsTomcat.yaml" apunta a este grupo y configura plugins particulares que se encuentran en "basic_tools/ansible/custom_plugins/check_tomcat.py-2.2.tar.gz". Este grupo necesita que primero ya se haya aplicado "installnagios.yaml".
El ultimo grupo, "[postgresnodes]" permite identificar y configurar solo aquellos servidores que tengan postgres. Resulta que el playbook "installpluginsPostgresql.yaml" apunta a este grupo y configura plugins particulares que se encuentran en "basic_tools/ansible/custom_plugins/check_postgres-2.24.0.tar.gz". Al igual que el grupo anterior, este necesita que se ejecute anteriormente "installnagios.yaml".

```
[nagiosclient]
192.168.50.4 user=root
192.168.50.5 user=root
192.168.50.6 user=root
192.168.50.7 user=root

[tomcatnodes]
192.168.50.4 user=root

[postgresnodes]
192.168.50.7 user=root
```

Cada grupo indica los host mediante sus IPs y usuario de acceso remoto. En este caso, se utiliza el usuario root.

**installnagios.yaml**. Playbook de ansible que ejecuta las siguientes tareas sobre los host configurados en el grupo "nagiosclient":
* Crear usuario nagios
* Instalacion de paquetes necesarios (paquetes para que Nagios funcione y ansible pueda desempeñar el resto de tareas sobre el nodo)
* Descarga de plugins (Descarga del cliente Nagios)
* Instalacion de plugins (Configuracion del cliente Nagios)
* Descarga de NRPE (Descarga del plugin NRPE)
* Instalacion de NRPE 
* Configuraciones de NRPE
* Iniciando Servicio

A continuacion se muestra el resultado de ejecutar este playbook desde el servidor Nagios.

```
root@ea4f5f33a7dc:~/ansible_scripts# ansible-playbook -i hosts.txt installnagios.yaml --private-key /root/keys/id_rsa

PLAY [Instalacion de Cliente Nagios] ********************************************************

TASK [Gathering Facts] **********************************************************************
ok: [192.168.50.4]
ok: [192.168.50.7]
ok: [192.168.50.5]
ok: [192.168.50.6]

TASK [Crear usuario nagios] *****************************************************************
changed: [192.168.50.4]
changed: [192.168.50.5]
changed: [192.168.50.7]
changed: [192.168.50.6]

TASK [Instalacion de paquetes necesarios] ***************************************************
[WARNING]: Updating cache and auto-installing missing dependency: python3-apt
changed: [192.168.50.6]
changed: [192.168.50.7]
changed: [192.168.50.5]
changed: [192.168.50.4]

TASK [Descarga de plugins] ******************************************************************
changed: [192.168.50.4]
changed: [192.168.50.7]
changed: [192.168.50.5]
changed: [192.168.50.6]

TASK [Instalacion de plugins] ***************************************************************
changed: [192.168.50.4]
changed: [192.168.50.6]
changed: [192.168.50.5]
changed: [192.168.50.7]

TASK [Descarga de NRPE] *********************************************************************
changed: [192.168.50.5]
changed: [192.168.50.4]
changed: [192.168.50.6]
changed: [192.168.50.7]

TASK [Instalacion de NRPE] ******************************************************************
changed: [192.168.50.4]
changed: [192.168.50.6]
changed: [192.168.50.7]
changed: [192.168.50.5]

TASK [Configuraciones de NRPE] **************************************************************
changed: [192.168.50.7]
changed: [192.168.50.5]
changed: [192.168.50.6]
changed: [192.168.50.4]

TASK [Iniciando Servicio] *******************************************************************
[WARNING]: Consider using the file module with mode rather than running 'chmod'.  If you
need to use command because file is insufficient you can add 'warn: false' to this command
task or set 'command_warnings=False' in ansible.cfg to get rid of this message.
changed: [192.168.50.6]
changed: [192.168.50.5]
changed: [192.168.50.7]
changed: [192.168.50.4]

PLAY RECAP **********************************************************************************
192.168.50.4               : ok=9    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.50.5               : ok=9    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.50.6               : ok=9    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.50.7               : ok=9    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

**installpluginsTomcat.yaml** . Playbook de ansible que ejecuta las siguientes tareas sobre los host configurados en el grupo "tomcatnodes":
* Instalar dependencias necesarias (el plugin de tomcat funcionacon python2, es necesario asegurarnos de que este instalado)
* Copiar check_tomcat.py-2.2.tar.gz (transferir el plugins desde el servidor ansible al nodo a aprovisionar)
* Descomprimir check_tomcat.py-2.2.tar.gz
* Mover ejecutable (El ejecutable se mueve a los directorios de nagios para tener mayor orden)
* Modificacion de /opt/tomcat/conf/tomcat-users.xml (se configuran accesos a los roles "manager-gui" y "manager-script")
* Modificacion de /usr/local/nagios/etc/nrpe.cfg (se agregan los comandos NRPE que va a consultar el servidor de monitoreo)
* Reiniciando Servicio

A continuacion se muestra el resultado de ejecutar este playbook desde el servidor Nagios.

```
root@ea4f5f33a7dc:~/ansible_scripts# ansible-playbook -i hosts.txt installpluginsTomcat.yaml --private-key /root/keys/id_rsa

PLAY [Instalacion de plugins para Tomcat] ***************************************************

TASK [Gathering Facts] **********************************************************************
ok: [192.168.50.4]

TASK [Instalar dependencias necesarias] *****************************************************
changed: [192.168.50.4]

TASK [Copiar check_tomcat.py-2.2.tar.gz] ****************************************************
changed: [192.168.50.4]

TASK [Descomprimir check_tomcat.py-2.2.tar.gz] **********************************************
changed: [192.168.50.4]

TASK [Mover ejecutable] *********************************************************************
changed: [192.168.50.4]

TASK [Modificacion de /opt/tomcat/conf/tomcat-users.xml] ************************************
changed: [192.168.50.4] => (item=<user username="tomcat" password="s3cret" roles="manager-gui"/>)
changed: [192.168.50.4] => (item=<user username="tomcat" password="s3cret" roles="manager-script"/>)

TASK [Modificacion de /usr/local/nagios/etc/nrpe.cfg] ***************************************
changed: [192.168.50.4] => (item=command[check_tomcat_app]=python /usr/local/nagios/libexec/check_tomcat.py -H localhost -p 8080 -m app -u tomcat -a s3cret -n SampleWebApp)
changed: [192.168.50.4] => (item=command[check_tomcat_mem]=python /usr/local/nagios/libexec/check_tomcat.py -H localhost -p 8080 -m mem -u tomcat -a s3cret -w 15 -c 30)
changed: [192.168.50.4] => (item=command[check_tomcat_thread]=python /usr/local/nagios/libexec/check_tomcat.py -H localhost -p 8080 -m thread -u tomcat -a s3cret -w 100 -c 250)
changed: [192.168.50.4] => (item=command[check_tomcat_status]=python /usr/local/nagios/libexec/check_tomcat.py -H localhost -p 8080 -m status -u tomcat -a s3cret)

TASK [Reiniciando Servicio] *****************************************************************
changed: [192.168.50.4]

PLAY RECAP **********************************************************************************
192.168.50.4               : ok=8    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

**installpluginsPostgresql.yaml** . Playbook de ansible que ejecuta las siguientes tareas sobre los host configurados en el grupo "postgresnodes":
* Copiar check_postgres-2.24.0.tar.gz
* Configurando check_postgres-2.24.0 (se ejecutan una serie de pasos para configurar el plugin)
* Configuramos el fichero /etc/postgresql-common/pg_service.conf (este fichero indica todas las configuraciones de acceso a la base de datos a monitorear)
* Configuracion de acceso a base de datos (cambiamos las caracteristicas de acceso a la base de datos para no tener errores al conectarnos usando las configuraciones de "pg_service.conf")
* Modificacion de /usr/local/nagios/etc/nrpe.cfg (agregamos los comandos NRPE particulares para el monitoreo de la base de datos)
* Reiniciando Servicio (Reiniciando NRPE para que tome los cambios)

A continuacion se muestra el resultado de ejecutar este playbook desde el servidor Nagios.

```
root@ea4f5f33a7dc:~/ansible_scripts# ansible-playbook -i hosts.txt installpluginsPostgresql.yaml --private-key /root/keys/id_rsa

PLAY [Instalacion de plugins para Postgres] *************************************************

TASK [Gathering Facts] **********************************************************************
ok: [192.168.50.7]

TASK [Copiar check_postgres-2.24.0.tar.gz] **************************************************
changed: [192.168.50.7]

TASK [Configurando check_postgres-2.24.0] ***************************************************
changed: [192.168.50.7]

TASK [Configuramos el fichero /etc/postgresql-common/pg_service.conf] ***********************
changed: [192.168.50.7]

TASK [Configuracion de acceso a base de datos] **********************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running
su
changed: [192.168.50.7]

TASK [Modificacion de /usr/local/nagios/etc/nrpe.cfg] ***************************************
changed: [192.168.50.7] => (item=command[check_postgres_connection]=/usr/local/nagios/libexec/check_postgres_connection --dbservice=managed-db)
changed: [192.168.50.7] => (item=command[check_postgres_database_size]=/usr/local/nagios/libexec/check_postgres_database_size --dbservice=managed-db --critical=2048MB)
changed: [192.168.50.7] => (item=command[check_postgres_locks]=/usr/local/nagios/libexec/check_postgres_locks --dbservice=managed-db)
changed: [192.168.50.7] => (item=command[check_postgres_backends]=/usr/local/nagios/libexec/check_postgres_backends --dbservice=managed-db)
changed: [192.168.50.7] => (item=command[check_postgres_query_time]=/usr/local/nagios/libexec/check_postgres_query_time --dbservice=managed-db --critical=5s)
changed: [192.168.50.7] => (item=command[check_postgres_indexes_size]=/usr/local/nagios/libexec/check_postgres_indexes_size --dbservice=managed-db --critical=1024MB)

TASK [Reiniciando Servicio] *****************************************************************
changed: [192.168.50.7]

PLAY RECAP **********************************************************************************
192.168.50.7               : ok=7    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

**install.sh**. Script de bash encargado de generar las claves SSH que utilizara ansible y copiar todos los ficheros necesarios al servidor Nagios para ejecutar los playbook de ansible. Tambien, carga la clave ssh publica en todos los nodos remotos para que el servidor ansible se pueda conectar sin problemas. Este script debe ejecutarse siempre desde el directorio "basic_tools/ansible".

Una vez que usted levanto la estructura dockerizada, debe ejecutar este script para poder empezar el proceso de configuracion de Nagios.

### Python script

La idea de este script y todo lo que se comenta en esta seccion es simplificar el mantenimiento y generacion de configuraciones para nagios. Sabemos que nagios estructura su informacion mediante diferentes archivos de configuracion. Tenemos un fichero dedicado a los comandos, a los template y a cada uno de los host. En ese sentido, este script genera cada uno de los ficheros necesarios de acuerdo la informacion proporcionada en "basic_tools/script/host_config.txt". La informacion en este fichero debe estar estructurada de la siguiente forma: 

```
# EJEMPLOS DE COMO CONFIGURAR LOS HOSTS
# BASICO:
#ALIAS,#NAME,#TYPEOFSERVICE,#IPADDRESS
Server_Basico,Nodo_uno,Basico,192.168.50.3
# BASICO+TOMCAT:
#ALIAS,#NAME,#TYPEOFSERVICE,#IPADDRESS,#CONTEXT TOMCAT
Server_Tomcat,Nodo_dos,Basico+Tomcat,192.168.50.4,SampleWebApp
# BASICO+POSTGRES:
#ALIAS,#NAME,#TYPEOFSERVICE,#IPADDRESS
Server_Postgres,Nodo_cuatro,Basico+Postgres,192.168.50.7
```

De esta forma, host_config.txt esta estructurado asi:
```
Servidor_Web,Nodo_Tres,Basico+Tomcat,192.168.50.4,SampleWebApp
Servidor_General_2,Nodo_Cuatro,Basico,192.168.50.5
Servidor_General_3,Nodo_Cinco,Basico,192.168.50.6
Servidor_Postgres,Nodo_Seis,Basico+Postgres,192.168.50.7
```

Con esta informacion, el script utiliza unos template de acuerdo al tipo de servicio, llamados: "postgres_template.cfg", "tomcat_template.cfg" y "basic_template.cfg" y los completa con la informacion particular del nodo. De esta forma, genera multiples ficheros utilizando el alias del nodo y los guarda en "basic_tools/script/config_file_generated". Para que Nagios server tome esta informacion quedaria pasarla al servidor en la ubicacion: "/usr/local/nagios/etc/objects/host_monitor/"

Puede usar como referencia los comandos:
```
cd basic_tools/script
docker cp config_file_generated/<<file_name>> nagios_server:/usr/local/nagios/etc/objects/host_monitor/
docker cp config_file_generated/.. ... ... .. 
... ... 
docker exec -it nagios_server /bin/bash
service nagios stop
service nagios start
```

## Servidores monitoreados

Dentro de los nodos a monitorear, se encuentran:
* Servidor General
    * Ubuntu
    * Cantidad de servidores: 3
        * IP: **192.168.50.3** (Ya esta aprovisionado)
        * IP: **192.168.50.5** (Puede ser aprovisionado con ansible)
        * IP: **192.168.50.6** (Puede ser aprovisionado con ansible)
    * script Ansible para instalar:
        * installnagios.yaml
    * Recursos que se monitorean:
        * Uso de CPU desde host remoto: 
        Un aviso de alerta, si la CPU es de 15% por 5 minutos, 10% durante 10 minutos, 5% por 15 minutos. Una alerta crítica, si la CPU es de 30% por 5 minutos, el 25% por 10 minutos, el 20% de 15 minutos.
        Ref: https://www.enmimaquinafunciona.com/pregunta/18701/lo-critico-y-advertencia-valores-a-utilizar-para-check_load 
        * Cantidad de usuarios conectados desde host remoto: 
        Un aviso de alerta, si la cantidad de usuarios es mayor o igual a 5. Una alerta critica si la cantidad de usuarios supera los 10.

        * Cantidad de procesos desde host remoto: 
        Un aviso de alerta, si la cantidad de procesos es mayor o igual a 150. Un alerta critica si la cantidad de procesos supera los 200.

        * Chequeo de conectividad (ping) desde el servidor: 
        Un aviso de alerta, si la conectividad entre servidor y nodo remoto supera los 500ms o si existe una perdidad de paquetes de 20%. Un aviso de alerta critica, si la conectividad entre servidor y nodo remoto supera los 900ms y tiene una perdidad de paquetes superior a 60%.

* Servidor Tomcat
    * Ubuntu
    * Cantidad de servidores: 1
        * IP: **192.168.50.4** (Puede ser aprovisionado con ansible)
    * Script ansible para instalar:
        * installnagios.yaml
        * installpluginsTomcat.yaml
    * Usuario de servidor tomcat: tomcat
    * Password de servidor tomcat: s3cre3t
    * Aplicacion de servidor tomcat: SampleWebApp
        * Referencia: https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war
    * Se monitorean los mismos recursos que "Servidor General".
    * Se monitorean los recursos adicionales:
        * Estado general de la aplicacion
        * Estado de la memoria consumida por la aplicacion:
        Una alerta de aviso, si la memoria de la aplicacion supera el 15% de la memoria total del servidor. Una alerta critica si la aplicacion consume una memoria mayor al 30%.
        * Estado de los thread de la aplicacion:
        Una alerta de aviso, si la cantidad de thread alcanza un valor igual o mayor a 100. Una alerta critica, si la cantidad de thread alcanza un valor equivalente a 250.
* Servidor Postgres
    * Ubuntu
    * Cantidad de servidores: 1
        * IP: **192.168.50.7** (Puede ser aprovisionado con ansible)
    * Script ansible para instalar:
        * installnagios.yaml
        * installpluginsPostgres.yaml
    * Usuario de base de datos: postgres
    * Password del usuario de base de datos: s3cr3t0P0stgr3s
    * Base de datos que se monitorea: postgres
    * Se monitorean los mismos recursos que "Servidor General".
    * Se monitorean los recursos adicionales:
        * Conexiones a base de datos.
        * Tamaño de base de datos. Una alerta critica, si el tamaño de la base de datos supera el valor de 2048MB.
        * Cantidad de bloqueos en base de datos.
        * Chequeo de backend.
        * Chequeo de consultas lentas. Una alerta critica, si el tiempo de ejecucion de una consulta supera los 5s.
        * Chequeo del tamaño de los indices de las tablas. Una alerta critica, si los indices superan un valor de 1024MB.

**¿Como modificamos los parametros del monitoreo?** Debe ingresar en el nodo particular donde desea realizar los cambios y modificar parte de los comandos NRPE definidos. Para modificar el fichero de configuracion de NRPE en los nodos remotos ejecute:
```
vim /usr/local/nagios/etc/nrpe.cfg
```
No se olvide de reiniciar el servicio de NRPE para que se apliquen los cambios
```
/tmp/nrpe-nrpe-4.0.3/startup/default-init restart
```
## Comandos para levantar todo el laboratorio:

1. Levantar estructura dockerizada:
```
docker-compose up -d
```
2. Generacion de claves ssh y configuracion ssh de todos los nodos.
```
cd basic_tools/ansible
./install
```
3. Ejecutar los playbook necesarios desde el servidor Nagios.
```
docker exec -it nagios_server /bin/bash
cd /root/ansible_scripts
ansible-playbook -i hosts.txt installnagios.yaml --private-key /root/keys/id_rsa
ansible-playbook -i hosts.txt installpluginsTomcat.yaml --private-key /root/keys/id_rsa
ansible-playbook -i hosts.txt installpluginsPostgresql.yaml --private-key /root/keys/id_rsa
```
Si tiene problemas con los fingerprint de acceso ssh ejecute estos comandos antes de ansible-playbook:
```
ssh root@192.168.50.4 -i /root/keys/id_rsa
ssh root@192.168.50.5 -i /root/keys/id_rsa
ssh root@192.168.50.6 -i /root/keys/id_rsa
ssh root@192.168.50.7 -i /root/keys/id_rsa
```
4. Generacion de ficheros de configuracion de Nagios.
```
cd basic_tools/script
python3 config-generator.py
docker cp config_file_generated/Servidor_General_2.cfg nagios_server:/usr/local/nagios/etc/objects/host_monitor
docker cp config_file_generated/Servidor_General_3.cfg nagios_server:/usr/local/nagios/etc/objects/host_monitor
docker cp config_file_generated/Servidor_Postgres.cfg nagios_server:/usr/local/nagios/etc/objects/host_monitor
docker cp config_file_generated/Servidor_Web.cfg nagios_server:/usr/local/nagios/etc/objects/host_monitor
docker exec -it nagios_server  /bin/bash
service nagios stop
service nagios start
```
5. Acceder a Nagios:
* URL:  http://localhost:9090/nagios
* Usuario: nagiosadmin
* Password: nagiosadmin