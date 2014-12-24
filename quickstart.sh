#!/bin/sh

cd software/linux_driver_app 

sudo find . -name "*.sh"|xargs chmod +x
sudo sh rungui.sh
