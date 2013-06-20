#!/bin/sh

if [ $# != 1 ];then
    echo "**********************************************************"
    echo "Usage: sh import_higgs_manager_server.sh servername"
    echo "**********************************************************"
else
    echo "Waiting for importing $1.img file."
    if [ -d /home/img/ ];then
        echo ""
    else
        mkdir /home/img/
    fi
    if [ $1 != 'higgs_application' ];then
        sed -e 's/higgs_application/'$1'/g'  higgs_application.xml > $1.xml
    fi
    \cp HiggsManagerServer.img /home/img/$1.img
    echo "Import $1.img file sucessfully."
    echo "Waiting for define $1."
    virsh define $1.xml
    echo "Define $1 sucessfully."
    echo "Waiting for starting $1"
    virsh start $1
    python start_spice_port.py $1
    echo "Waiting for getting $1 ip address."
    retries=10
    old_size=`stat -c %s /var/run/manageIP`
    sleep 15
    new_size=`stat -c %s /var/run/manageIP`
    while [ "$old_size" == "$new_size" -a $retries -gt 0 ]
    do
        sleep 2
        new_size=`stat -c %s /var/run/manageIP`
        retries=`expr $(($retries-1))`
    done
    if [ "$old_size" != "$new_size" ]; then
        ip=$(tail -n 1 /var/run/manageIP)
        echo "To access console from http://${ip:0:${#ip}-1}:8080"
    else
        echo "wait $1 return ip address timeout!"
    fi
    if [ $1 != 'higgs_application' ];then
        rm $1.xml
    fi
fi

