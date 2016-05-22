#!/bin/bash
PATCHLEVEL="`cat torvalds/Makefile | grep "PATCHLEVEL =" | cut -d '=' -f 2`"
SUBLEVEL="`cat torvalds/Makefile | grep "SUBLEVEL =" | cut -d '=' -f 2`"
EXTRAVERSION="`cat torvalds/Makefile | grep "EXTRAVERSION ="| cut -d '=' -f 2`"
NAME="`cat torvalds/Makefile | grep "NAME =" | cut -d '=' -f 2`"
ver="kernel build script by ksrt12 v3.0.1"
N="\033[0m"
B="\033[1;34m"; b="\033[34m"
C="\033[1;36m"; c="\033[36m"
G="\033[1;32m"; g="\033[32m"
M="\033[1;35m"; m="\033[35m"
R="\033[1;31m"; r="\033[31m"
Y="\033[1;33m"; y="\033[33m"
echo -e $M"Kernel version 4"$(echo ".$PATCHLEVEL.$SUBLEVEL$EXTRAVERSION" | sed -e 's/ //g')$NAME$N
jobs=-j$(cat /proc/cpuinfo | grep -e "^processor" | wc -l)
MAKE="schedtool -B -n 1 -e ionice -n 1 make $jobs -C `pwd`/torvalds O=`pwd`/out"
start_time=$(date +"%s")
if [ ! -d out ]; then mkdir out; fi
if [ "$1" != "r" ]; then
if [ ! -e linux-repo/apply ]; then cd torvalds; git am -3 ../linux-repo/*.patch; cd .. ; touch linux-repo/apply; fi
if [ ! -e out/.config ]; then $MAKE aspire5102AWLMi_defconfig; fi; fi
case $1 in
  r) if [ "$2" == "t" ]; then $ec repo --trace sync -l
                else $ec repo sync $jobs --force-sync;fi; rm -rf linux-repo/apply;exit 0 ;;
  i|install) sudo $MAKE modules_install install ;;
  c|clean) $MAKE clean ;;
  d|distclean) $MAKE distclean ;;
  m|mrproper) $MAKE mrproper ;;
  -v|v|-V|V|-version|version|ver) echo -e $B"$ver"; noprint=1 ;;
  -h|h|--help|-help|help)
  cat <<EOF
$ver

Поддерживаемые команды:
r            - синхронизация исходников (repo sync)
 r t         - repo --trace sync -l
i|install    - установка ядра в систему
c|clean      - удаление сгенерированных файлов с сохранением конфигурации(.config), достаточной для сборки внешних модулей
m|mrproper   - удаление всех созданных файлов + конфигураций + различных резервных копии файлов
d|distclean  - mrproper + удаление резервных редакторов и патч-файлов

EOF
exit 2
;;
  *) $MAKE $@;;
esac
ret=$?
end_time=$(date +"%s")
tdiff=$(($end_time-$start_time))
hours=$(($tdiff / 3600 ))
mins=$((($tdiff % 3600) / 60))
secs=$(($tdiff % 60))
echo
if [ "$noprint" != "1" ]; then
if [ $ret -eq 0 ] ; then echo -e -n $C"#### сборка успешно завершена "
else echo -n -e $R"#### некоторые цели сборки не былы достигнуты "; fi
if [ $hours -gt 0 ] ; then
 echo -n "($hours:$mins:$secs (чч:мм:сс))"
elif [ $mins -gt 0 ] ; then
 echo -n "($mins:$secs (мм:сс))"
elif [ $secs -gt 0 ] ; then
offd=$(($secs-$secs/10*10))
if [ "$offd" == "1" ]; then 
if [ "$secs" != "11" ] ; then of=а;fi
elif [ "$offd" == "2" ] || [ "$offd" == "3" ] || [ "$offd" == "4" ]; then 
if [ "$secs" != "12" ] && [ "$secs" != "13" ] && [ "$secs" != "14" ]; then of=ы; fi
fi
 echo -n "($secs секунд$of)"
fi
echo -e " ####\n"$N
if [ $ret -eq 0 ] ; then continie=1; else exit 5;fi; fi
