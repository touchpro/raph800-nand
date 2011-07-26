DIRECTORY=$(cd `dirname $0` && pwd)
cd $DIRECTORY

TARGET=raph800

if [ ! -d "$DIRECTORY/xip" ]; then
mkdir xip
fi

if [  -e xip/"$TARGET" ]; then
rm xip/$TARGET
echo Deleting old $TARGET
fi

#Set the toolchain path
export PATH=$PATH:/usr/local/arm-eabi-4.4.0/bin
echo "Compile the tinboot/xip for $TARGET....."

arm-eabi-as  $DIRECTORY/tinboot/tinboot2.S -o tinboot.o --defsym $TARGET=1 --defsym MTYPE=2039
arm-eabi-objcopy tinboot.o -O binary tinbootxip

mv tinbootxip xip/$TARGET

rm tinboot.o
if [ ! -e "$DIRECTORY/xip/$TARGET" ]; then 
echo Model does not exist.
exit
fi

cp $DIRECTORY/tools/raph_payload os.nb.payload

echo Inserting tinboot into payload
cat xip/$TARGET >> os.nb.payload

echo Inserting blank imgfs into payload
wine tools/ImgfsToNb.exe  tools/imgfs.bin os.nb.payload os-new.nb.payload >> $DIRECTORY/tools/log_ImgfsToNb.txt
echo Creating os.nb portion of nbh
tools/nbmerge < os-new.nb.payload > os-new.nb
echo Creating NBH
wine tools/yang.exe -F ruu_signed.NBH -f os-new.nb -t 0x400 -s 64 -d RAPH800 -c 11111111 -v RaphaelLinux -l WWE >> $DIRECTORY/tools/log_yang.txt

rm os.nb.payload
rm os-new.nb.payload
rm os-new.nb

mv ruu_signed.NBH RAPHIMG.NBH
