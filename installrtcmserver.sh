#!/bin/bash

echo ""

echo "compiling please wait"
sudo cp rtcmadd1008.py /usr/local/bin/


make

sudo systemctl stop startntripserver.service

sudo cp ntripserver /usr/local/bin/
echo ""
echo ""


echo "Please enter your mountpoint:"
echo "Format: AT-BL-BE-Mountpoint"
echo "zb: AUT-ST-ADDHOME"
echo "means: Austria-Styria-Graz and addhome as name"
echo ""
echo ""
read -p "press ENTER to start" ee

echo ""

read -p "Mountpoint:" nMOUNT

echo ""

read -p "User:" nUSER

echo ""

read -p "PASSWORD: " nPASSWORD


echo ""


echo "write startntripserver.service"

echo "[Unit]" > startntripserver.service
echo "Description=ntripserver for rtk4you" >> startntripserver.service
echo "After=network.target" >> startntripserver.service
echo "" >> startntripserver.service
echo "[Service]" >> startntripserver.service
echo "Type=simple" >> startntripserver.service
echo "Restart=always" >> startntripserver.service
echo "RestartSec=10" >> startntripserver.service

echo "RTCM 1008 inject? y/n"
read ANTWORT
if [ "$ANTWORT" == "y" ]
    then
    echo "ExecStart=/bin/bash -c \" /usr/bin/socat -u TCP:localhost:2102 - | /usr/bin/python3 /usr/local/bin/rtcmadd1008.py |/usr/local/bin/ntripserver -M 3 -O 1 -n $nUSER -c $nPASSWORD -a  gps.rtk4u.com  -p 2101 -m $nMOUNT\"" >> startntripserver.service
    else
    echo "ExecStart=/usr/local/bin/ntripserver -M 2 -H 127.0.0.1 -P 2102 -O 1 -n $nUSER -c $nPASSWORD -a gps.rtk4u.com -p 2101 -m $nMOUNT" >> startntripserver.service
       
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

echo "Enable Monitoring system zabbix"
echo "download zabbix agent"
sudo apt-get install zabbix-agent

echo "update and configure zabbix-agent"


rtk="-rtkbase"

sed -i -e 150c"Hostname=$nMOUNT$rtk" zabbix_agentd.conf

nSip="gps.rtk4u.com"

sed -i -e 140c"ServerActive=$nSip" zabbix_agentd.conf
sed -i -e 98c"Server=$nSip" zabbix_agentd.conf


sudo cp zabbix_agentd.conf /etc/zabbix/

sudo systemctl enable zabbix-agent
sudo systemctl start zabbix-agent




echo ""
echo "System running"
echo "Have fun with RTK4U"
echo "Please restart raspberry"
echo "using sudo reboot now"

