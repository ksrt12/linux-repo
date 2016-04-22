#!/bin/bash
version="ksrt12 ROMs build script v2.0"
jobs=-j$(cat /proc/cpuinfo | grep -e "^processor" | wc -l)
MAKE="schedtool -B -n 1 -e ionice -n 1 make $jobs -C `pwd`/torvalds O=`pwd`/out"
if [ ! -d out ]; then mkdir out; fi
if [ ! -e linux-repo/apply ]; then cd torvalds; git am -3 ../linux-repo/*.patch; cd .. ; touch linux-repo/apply; fi
if [ ! -e out/.config ]; then $MAKE aspire5102AWLMi_defconfig; fi
case $1 in
  r|repo|sync) if [ "$2" == "t" ]; then $ec repo --trace sync -l
                else $ec repo sync $jobs --force-sync;fi; rm -rf linux-repo/apply;exit 0 ;;
  i|install) sudo $MAKE modules_install install ;;
  c|clean) $MAKE clean ;;
  d|distclean) $MAKE distclean ;;
  m|mrproper) $MAKE mrproper ;;
  *) $MAKE ;;

esac



if [ "$SHOW_LOG" == "1" ]; then
echo $ECHTOLOG2 >> $LOGFILE
echo $ECHTOLOG >> $LOGFILE
date >> $LOGFILE
fi

