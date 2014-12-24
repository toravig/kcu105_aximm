if [ $(getconf LONG_BIT) == "64" ]
then
echo "***** Driver Compiled 64*****"
sudo java -Djava.library.path=./gui/jnilib/64 -jar gui/UltraScaleGUI.jar 1>/dev/null 2>&1
else
echo "***** Driver Compiled 32*****"
sudo java -Djava.library.path=./gui/jnilib/32 -jar gui/UltraScaleGUI.jar
fi

