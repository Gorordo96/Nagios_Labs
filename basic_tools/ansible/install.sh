#!/bin/bash

# =============================== DATOS PARA EJECUTAR SCRIPT ====================================
# Ejecutar desde la carpeta proyect_Nagios/basic_tools/ansible
# =============================== SSH - VERIFICACION DE CREDECIALES =============================

echo ""
echo "$(date) - proceso de verificacion de claves SSH "
echo ""

if [ ! -f "$(pwd)/id_rsa" ] || [ ! -f "$(pwd)/id_rsa.pub"  ]; then
    echo "$(date) - Se detectaron problemas con las credenciales SSH en este directorio ..."
    rm "$(pwd)/id_rsa" || echo "$(date) - No se puede eliminar: $(pwd)/id_rsa"
    rm "$(pwd)/id_rsa.pub" || echo "$(date) - No se puede eliminar: $(pwd)/id_rsa.pub"
    echo "$(date) - Creacion de claves SSH ..."
    ssh-keygen -t rsa -N '' -f "$(pwd)/id_rsa" <<< y
else
    echo ""
    echo "$(date) - No se detectaron problemas con las claves SSH ..."
    echo ""
fi

# =============================== SSH - COPIAR A SERVER Y NODOS ================================

echo ""
echo "$(date) - Preparacion de los nodos para usar ansible"
echo ""

# COPIAR PRIVATE-SSH A NAGIOS_SERVER
if [ "$( docker container inspect -f '{{.State.Status}}' nagios_server )" == "running" ]; then
    echo "$(date) - Copiar Clave privada al contenedor nagios_server ... "
    docker exec nagios_server /bin/bash -c "mkdir -p /root/keys"
    docker cp "$(pwd)/id_rsa" nagios_server:/root/keys/id_rsa
    docker exec nagios_server /bin/bash -c "chmod 600 /root/keys/id_rsa"
else
    echo "$(date) - No se encuentra el contenedor nagios_server activo. Asegurese de ejecutar previamente docker-compose up -d"
    exit 1
fi
# COPIAR PUBLIC-SSH A NAGIOS_NODETWO
if [ "$( docker container inspect -f '{{.State.Status}}' nagios_nodetwo )" == "running" ]; then
    echo "$(date) - Copiar Clave publica al contenedor nagios_nodetwo ... "
    docker cp "$(pwd)/id_rsa.pub" nagios_nodetwo:/tmp/id_rsa.pub
    docker exec nagios_nodetwo /bin/bash -c "mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && service ssh start"
else
    echo "$(date) - No se encuentra el contenedor nagios_nodetwo activo. Asegurese de ejecutar previamente docker-compose up -d"
    exit 1
fi

# COPIAR PUBLIC-SSH A NAGIOS_NODETHREE
if [ "$( docker container inspect -f '{{.State.Status}}' nagios_nodethree )" == "running" ]; then
    echo "$(date) - Copiar Clave publica al contenedor nagios_nodethree ... "
    docker cp "$(pwd)/id_rsa.pub" nagios_nodethree:/tmp/id_rsa.pub
    docker exec nagios_nodethree /bin/bash -c "mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && service ssh start"
else
    echo "$(date) - No se encuentra el contenedor nagios_nodethree activo. Asegurese de ejecutar previamente docker-compose up -d"
    exit 1
fi

# COPIAR PUBLIC-SSH A NAGIOS_NODETHREE2
if [ "$( docker container inspect -f '{{.State.Status}}' nagios_nodethree2 )" == "running" ]; then
    echo "$(date) - Copiar Clave publica al contenedor nagios_nodethree2 ... "
    docker cp "$(pwd)/id_rsa.pub" nagios_nodethree2:/tmp/id_rsa.pub
    docker exec nagios_nodethree2 /bin/bash -c "mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && service ssh start"
else
    echo "$(date) - No se encuentra el contenedor nagios_nodethree2 activo. Asegurese de ejecutar previamente docker-compose up -d"
    exit 1
fi

# COPIAR PUBLIC-SSH A NAGIOS_NODEFOUR
if [ "$( docker container inspect -f '{{.State.Status}}' nagios_nodefour )" == "running" ]; then
    echo "$(date) - Copiar Clave publica al contenedor nagios_nodefour ... "
    docker cp "$(pwd)/id_rsa.pub" nagios_nodefour:/tmp/id_rsa.pub
    docker exec nagios_nodefour /bin/bash -c "mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && service ssh start"
else
    echo "$(date) - No se encuentra el contenedor nagios_nodefour activo. Asegurese de ejecutar previamente docker-compose up -d"
    exit 1
fi

# COMANDOS SUGERIDOS
echo ""
echo "$(date) - Comando para acceder a nagios_server: docker exec -it nagios_server /bin/bash"
echo "$(date) - Comando para acceder via ssh a nagios_nodetwo: ssh root@192.168.50.4 -i /root/keys/id_rsa"
echo ""
# =============================== ANSIBLE SCRIPT ============================================
# PLAYBOOK TO INSTALL NAGIOS NODE...
echo ""
echo "$(date) - Copiar script de ansible a nagios_server"
echo ""
echo "$(date) - Creando directorio de ansible en nagios_server"
docker exec nagios_server /bin/bash -c "mkdir -p /root/ansible_scripts"
docker cp installnagios.yaml nagios_server:/root/ansible_scripts/installnagios.yaml
docker cp hosts.txt nagios_server:/root/ansible_scripts/hosts.txt
echo "$(date) - en el directorio /root/ansible_scripts del contenedor nagios_server ahora puedes instalar agentes nagios en el resto de nodos."
echo "$(date) - Ejemplo: "
echo "$(date) - 1. Modifica el archivo hosts.txt para asignar los hosts a aprovisionar:"
echo "$(date) - [nagiosclient]"
echo "$(date) - <<IP cliente>> user=<<user_to_connect_ssh>>"
echo ""
echo "$(date) - [nagiosclient]"
echo "$(date) - 192.168.50.4 user=root"
echo ""
echo "$(date) - [tomcatnodes]"
echo "$(date) - <<IP cliente>> user=<<user_to_connect_ssh>>"
echo ""
echo "$(date) - [tomcatnodes]"
echo "$(date) - 192.168.50.4 user=root"
echo ""
echo "$(date) - [postgresnodes]"
echo "$(date) - <<IP cliente>> user=<<user_to_connect_ssh>>"
echo ""
echo "$(date) - [postgresnodes]"
echo "$(date) - 192.168.50.7 user=root"
echo ""
echo "$(date) - Debe agregar todos los nodos a [nagiosclient] y luego puede aprovisionar servicios particulares a [postgresnodes] y [tomcatnodes]" 
echo "$(date) - Define ansible_sudo_pass=<<password_to_connect_ssh>> en caso de que el usuario de acceso necesite contraseña para acceder a comandos sudo" 
echo "$(date) - 2. Ejecuta el playbook:"
echo "$(date) - ansible-playbook -i hosts.txt installnagios.yaml --private-key /root/keys/id_rsa"
echo "$(date) - ansible-playbook -i hosts.txt installpluginsTomcat.yaml --private-key /root/keys/id_rsa"

# PLAYBOOK TO INSTALL PLUGINS TOMCAT...
docker cp installpluginsTomcat.yaml nagios_server:/root/ansible_scripts/installpluginsTomcat.yaml
docker cp ../custom_plugins/check_tomcat.py-2.2.tar.gz nagios_server:/root/ansible_scripts/check_tomcat.py-2.2.tar.gz
# PLAYBOOK TO INSTALL PLUGINS POSTGRES...
docker cp installpluginsPostgresql.yaml nagios_server:/root/ansible_scripts/installpluginsPostgresql.yaml
docker cp ../custom_plugins/check_postgres-2.24.0.tar.gz nagios_server:/root/ansible_scripts/check_postgres-2.24.0.tar.gz