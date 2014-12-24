#!/bin/sh
cd vlc
sudo yum -y erase vlc vlc-core
sudo yum localinstall -y gamin-0.1.10-15.fc20.x86_64.rpm gvfs-1.18.3-3.fc20.x86_64.rpm libgoom2-0-3.fc19.x86_64.rpm vlc-2.1.5-1.fc20.x86_64.rpm gnome-vfs2-2.24.4-14.fc20.x86_64.rpm vlc-core-2.1.5-1.fc20.x86_64.rpm
cd ../
