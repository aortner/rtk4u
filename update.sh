#!/bin/bash


cp *.service  /etc/systemd/system
systemctl daemon-reload

systemctl try-restart startntripserver.service
