#!/bin/sh
compilation_error=1
module_insertion_error=2
compilation_clean_error=3

echo "About to invoke remove modules script"
/bin/sh remove_modules.sh
cd util
echo "Installing VLC player, this may take some time"
/bin/sh install_vlc_32.sh
cd ../
cd driver
echo "Entered driver folder after calling remove modules"
make DRIVER_MODE=VIDEO TEST_MODE=VIDEOACC clean
if [ "$?" != "0" ]; then
	echo "Error in cleaning Video Driver"
	exit $compilation_clean_error;
fi
echo "Cleaning of Video driver done"
make DRIVER_MODE=VIDEO TEST_MODE=VIDEOACC 1>/dev/null 2>&1 
if [ "$?" != "0" ]; then
	echo "Error in compiling Video Driver"
	exit $compilation_error;
fi
echo "Compilation of Video driver done"
sudo make DRIVER_MODE=VIDEO TEST_MODE=VIDEOACC insert 
if [ "$?" != "0" ]; then
	echo "Error in inserting Video Driver"
	exit $module_insertion_error;
fi
echo "Insertion of Video driver done"
cd ../
