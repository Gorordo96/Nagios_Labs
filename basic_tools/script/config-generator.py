#!/usr/bin/python3
#______________________________________________________________________
#-------------------------- VARIABLES INICIALES -----------------------
import os

aliaserver = list()
nameserver = list()
typeofserver = list()
ipservers = list()
tomcat_context = list ()


print("______________________________________________________________________")
print("-.-.-.-.-.-.-.-. GENERADOR DE CONFIGURACIONES DE HOST .-.-.-.-.--.-.-.")
print("______________________________________________________________________")
print(" ")
# VERIFICACION DE EXISTENCIA DE FICHERO DE CONFIGURACION.
if (os.path.exists("host_config.txt") == False):
    print("ERROR: No se encontro el fichero de configuracion de host")
    print("ERROR: Cree el fichero host_config.txt para la proxima ejecucion")
    quit()
# VERIFICACION DE CARPETA CON CONFIGURACIONES GENERADAS.
if (os.path.exists("config_file_generated") == False):
    print("INFO: Creando directorio de configuraciones")
    os.system('mkdir config_file_generated')
else:
    print("WARNING: Directorio de configuraciones ya existe")
    print("WARNING: Eliminando su contenido")
    os.system('rm -r config_file_generated/*')
    

# PROCESANDO FICHERO DE CONFIGURACION
file = open("host_config.txt", "r")
for host in file:
    text_process = host.split(",")
    aliaserver.append(text_process[0])
    nameserver.append(text_process[1])
    typeofserver.append(text_process[2])
    ipservers.append(text_process[3].strip('\n'))
    if (text_process[2] == "Basico+Tomcat"):
        tomcat_context.append(text_process[4])
file.close()

# RESUMIENDO CONFIGURACIONES
print(" ")
print("______________________________________________________________________")
print("-.-.-.-.-.-.-.-.-.-.-.- LISTADOS DE HOST -.-.-.-.-.-.-.-.-.-.-.-.-.-.-")
print("______________________________________________________________________")

tomcat_host=0
for x in range(len(aliaserver)):
    print(" ")
    print(" ")
    print("ALIAS: " , aliaserver[x])
    print("NAME:" , nameserver[x])
    print("TYPE:" , typeofserver[x])
    print("HOST:", ipservers[x])
    if (typeofserver[x] == "Basico+Tomcat"):
        print("CONTEXT TOMCAT:" , tomcat_context[tomcat_host])
        tomcat_host += 1
        print(" ")
        print("PARAMETROS TOMCAT")
        print("- user: tomcat")
        print("- password: s3cret")
        print("- check mem: warning -> 15 critical -> 30")
        print("- check thread: warning -> 100 critical -> 250")
    elif (typeofserver[x] == "Basico+Postgres" ):
        print(" ")
        print("PARAMETROS POSTGRES")
        print("- user: postgres")
        print("- host: localhost")
        print("- port: 5432")
        print("- password: s3cr3t0P0stgr3s")
        print("- nombre base de datos: postgres")
        print("- database size: critical -> 2048MB")
        print("- query time: critical -> 5s")
        print("- indexes size: critical -> 1024MB")
    print(" ")
    print("PARAMETROS BASICOS:")
    print("- check user: warning -> 5 critical -> 10")
    print("- check load: warning -> .15 (5min) .10 (10min) .05 (15min) critical -> .30 (5min) .25 (15min) .20(min) ")
    print("- check ping: warning -> 500.0 (delay) 20% (loss) critical -> 900.0 (delay) 60% (loss) ")
    print("- check process: warning -> 150 critical -> 200 ")
    
# CONSTRUYENDO FICHEROS DE CONFIGURACION
tomcat_host=0
for x in range(len(aliaserver)):
    if (typeofserver[x] == "Basico+Tomcat"):
        file_template = open("tomcat_template.cfg","r")
        tomcat_host =+ 1
    elif (typeofserver[x] == "Basico+Postgres"):
        file_template = open("postgres_template.cfg","r")
    else:
        file_template = open("basic_template.cfg","r")

    file_name = "./config_file_generated/" + str(aliaserver[x]) + ".cfg"
    file_config = open(file_name,"w")
    for line in file_template:
        if (line.find("_ALIAS_") != -1):
            new_line = line.replace('_ALIAS_',aliaserver[x])
        elif (line.find("_NAME_") != -1):
            new_line = line.replace('_NAME_',nameserver[x])
        elif (line.find("_IP-ADDRESS_") != -1):
            new_line = line.replace('_IP-ADDRESS_',ipservers[x])
        else:
            new_line=line
        file_config.write(new_line)
    file_config.close()
    file_template.close()
print(" ")
print(" ")
print("______________________________________________________________________")
print("-.-.-.-.-.-.-.-.-.-.-.- ACLARACIONES IMPORTANTES -.-.-.-.-.-.-.-.-.-.-")
print("______________________________________________________________________")
print(" ")
print("- Este script genera configuraciones con parametros fijos. Tanto para basicos como para basicos+tomcat ó basicos+postgres")
print("- El context tomcat esta fijo en: SampleWebApp por mas que se carge en: host_config.txt")
print("- Para modificar los parametros y adaptarlos a cada host, es necesario revisar los ficheros.")
print("- Servidores monitoreados: /usr/local/nagios/etc/nrpe.cfg")
print("- Servidor monitor: /usr/local/nagios/etc/objects/commands.cfg ")
print("- Servidor monitor: /usr/local/nagios/etc/objects/host_monitor ")
print("- Servidor monitor: /usr/local/nagios/etc/nagios.cfg")