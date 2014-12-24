#!/bin/sh
compilation_error=1
module_insertion_error=2
compilation_clean_error=3

cd driver
make DRIVER_MODE=VIDEO clean
if [ "$?" != "0" ]; then
	echo "Error in cleaning Video Driver"
	exit $compilation_clean_error;
fi
make DRIVER_MODE=VIDEO
if [ "$?" != "0" ]; then
	echo "Error in compiling Video Driver"
	exit $compilation_error;
fi
sudo make DRIVER_MODE=VIDEO insert 
if [ "$?" != "0" ]; then
	echo "Error in inserting Video Driver"
	exit $module_insertion_error;
fi
cd ../
cd util
