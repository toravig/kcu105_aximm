#!/bin/sh
if [ -f "vlc.log" ]
then
	echo "Already VLC packages exist"
else
	echo "Installing VLC packges" > vlc.log
cd vlc_32
sudo yum -y erase vlc vlc-core
sudo yum localinstall -y vlc-2.1.5-1.fc20.i686.rpm vlc-core-2.1.5-1.fc20.i686.rpm vlc-debuginfo-2.1.5-1.fc20.i686.rpm vlc-devel-2.1.5-1.fc20.i686.rpm vlc-extras-2.1.5-1.fc20.i686.rpm vlc-plugin-jack-2.1.5-1.fc20.i686.rpm
cd ../
fi
