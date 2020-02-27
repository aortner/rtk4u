#!/bin/bash

sudo apt-get update

sudo apt-get upgrade

sudo apt-get install git nano socat

git clone https://github.com/aortner/rtcmserver.git

cd rtcmserver

make


sudo ./update.sh

sudo systemctl enable baseProxy@115200.service

sudo systemctl start baseProxy@115200.service

sudo systemctl enable startntripserver.service

sudo systemctl start startntripserver.service

