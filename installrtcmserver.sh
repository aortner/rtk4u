#!/bin/bash

echo ""

echo "jetzt wird das programm compiliert - das kann dauern"
sudo cp rtcmadd1008.py /usr/local/bin/


make

sudo systemctl stop startntripserver.service

sudo cp ntripserver /usr/local/bin/
echo ""
echo ""


echo "Geben sie ihren gewuenschten Mountpoint ein:"
echo "Format: BL-BE-Mountpoint"
echo "zb: ST-GR-DAHEIM"
echo "bedeutet: Steiermark , Graz und Daheim als Name"
echo ""
echo ""
read -p "ENTER um zu starten" ee

echo ""

read -p "Mountpoint:" nMOUNT

echo ""

read -p "Benutzer:" nUSER

echo ""

read -p "PASSWORD: " nPASSWORD


echo ""


echo "Schreibe startntripserver.service"

echo "[Unit]" > startntripserver.service
echo "Description=ntripserver for rtk4you" >> startntripserver.service
echo "After=network.target" >> startntripserver.service
echo "" >> startntripserver.service
echo "[Service]" >> startntripserver.service
echo "Type=simple" >> startntripserver.service
echo "Restart=always" >> startntripserver.service
echo "RestartSec=10" >> startntripserver.service

echo "RTCM 1008 einfügen? ja/nein"
read ANTWORT
if [ "$ANTWORT" == "ja" ]
    then
    echo "ExecStart=/bin/bash -c /usr/bin/socat -u TCP:localhost:2102 - | /usr/bin/python3 /usr/local/bin/rtcmadd1008.py |/usr/local/bin/ntripserver -M 3 -O 1 -n $nUSER -c $nPASSWORD -a 185.164.4.143 -p 2101 -m $nMOUNT" >> startntripserver.service
    else
    echo "ExecStart=/usr/local/bin/ntripserver -M 2 -H 127.0.0.1 -P 2102 -O 1 -n $nUSER -c $nPASSWORD -a 185.164.4.143 -p 2101 -m $nMOUNT" >> startntripserver.service
       
fi

echo "" >> startntripserver.service
echo "[Install]" >> startntripserver.service
echo "WantedBy=multi-user.target" >> startntripserver.service

echo ""
echo "Update System"
echo ""


sudo ./update.sh

sudo cp *.service  /etc/systemd/system
sudo systemctl daemon-reload

sudo systemctl enable baseProxy@115200.service

sudo systemctl start baseProxy@115200.service

sudo systemctl enable startntripserver.service

sudo systemctl start startntripserver.service

echo "Richte Monitoring system ein"
echo "lade Agent herunter"
sudo apt-get install zabbix-agent

echo "update und konfiguriere zabbix-agent"


rtk="-rtkbase"

sed -i -e 150c"Hostname=$nMOUNT$rtk" zabbix_agentd.conf

read -p "Server IP von RTK4U ohne Port eingeben " nSip

sed -i -e 140c"ServerActive=$nSip" zabbix_agentd.conf
sed -i -e 98c"Server=$nSip" zabbix_agentd.conf


sudo cp zabbix_agentd.conf /etc/zabbix/

sudo systemctl enable zabbix-agent
sudo systemctl start zabbix-agent




echo ""
echo "System fertig"
echo "Viel Erfolg mit RTK4U"
echo ""
echo ""

