#!/bin/sh

#wip >>> -q||-C @ autoscripted@luci||sysinfo.sh >>> -q = exitstatusonly -C=printlatestversion&&||-Lprintashtmlwlink?
#-R = restorepackages
#-v = verbose ( 1(normal) -> 2 )
#wip -Q = quick@verbose=z||0 ( 1(normal) -> 2 )
#-D = debug









ALLPARAMS=${*}
VERBOSE=1
RCSLEEP=0
#DEBUG=1


fails() {
    echo "$1" && exit 1
}



usage() {
cat <<EOG

    $0 [-R] [stable|current|testing|20.1] [downgrade/force|check] [-v] [dlonly]

	check   =   report 'upgradable' ( 'flavour' is newer )

        stable  =   long term image with minimal testing code
        current =   medium term image with some code + latest packages ( medium chance of bugs some new features )
        testing =   short term image with latest testing code / features / packages ( no opkg repos - removed anytime )


	NOTE: 'variants' @ extra||std are not yet supported -> all functionality is based on extra...
	      std is build / uploaded at the same time as extra so you can still use these checks
	      to know when builds are available


        (-D dbg)
        (-Q quick)
        (-q quiet exit status only @ check only) (possible if ! 'docmd' then)

EOG
}







################################################################### non-echo@-qetc... START
ecmd="echo "; i=$(basename $0); if [ -x /etc/custom/custfunc.sh  ]; then . /etc/custom/custfunc.sh; ecmd="echm ${i} "; fi
if [ -f /root/wrt.ini  ]; then . /root/wrt.ini; fi
if [ -z "$ffD"  ]; then ffD="/root"; fi
########################################3
#UPGRADEsFLAVOUR="current"
########################################3
#iM="$i" #iM="$(basename $0)"
iL="/$i.log"
LOGCHECKS=1 #???fromoldfunction-testdirname?
























echL() { SL=$(date +%Y%m%d%H%M%S)



### all cases except * had log anyway move above
[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL



case "${2}" in
	log) :; ;; #MOVEDABOVE [ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL; return 0

	msg) #[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL
		$ecmd "$1"
	;;

	console) #[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL
		echo "$1" > /dev/console
	;;

	logger) #[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL
		logger -p info -t $i "${*}"
	;;

	*) $ecmd "$1"; ;;


esac
}


#*) $ecmd "$1"; ;;
################################################################### non-echo@-qetc... END











WGETBIN=$(readlink -f $(type -p wget))
CURLBIN=$(readlink -f $(type -p curl))

WGETv="wget --no-parent -q -nd -l1 -nv --show-progress "
WGETs="wget --no-parent -q -nd -l1 -nv "




#case "$(cat /tmp/sysinfo/board_name)" in '4-model-b')
MODELf=$(cat /tmp/sysinfo/board_name)
Gbase="https://raw.github.com/wulfy23/rpi4/master"
SUMSname="sha256sums"


#WIP->multimodelsupport
#case "$(cat /tmp/sysinfo/board_name)" in
#esac




while [ "$#" -gt 0 ]; do
    case "${1}" in
    "-h"|"--help"|help) usage; shift 1; exit 0; ;;
    "-D") DEBUG=1; shift 1; ;;
    "-v") VERBOSE=2; shift 1; ;;
    "-Q") VERBOSE=0; shift 1; ;;

    stable) FLAVOUR="stable"; shift 1; ;;
    current) FLAVOUR="current"; shift 1; ;;
    testing) FLAVOUR="testing"; shift 1; ;;
    "20.1"*) FLAVOUR="${1}"; shift 1; ;; #20.1) FLAVOUR="20.1"

    check) DOCHECK="check"; shift 1; ;;
    downgrade) DOWNGRADE="downgrade"; shift 1; ;;
    force) FORCE="force"; shift 1; ;;
    "-R") RESTOREPACKAGES="-R"; shift 1; ;;


    dlonly) DLONLY=1; shift 1; ;;

    *)
        echo "$0 [stable|current|check] ?:$1"; exit 0 #NOPE echo "$0 [stable|current|check] ?:$1"; usage: exit 0
    ;;
    esac #if [ -f
done






if [ ! -z "$DEBUG" ]; then RCSLEEP=2; fi #@@@ similar||alsomod@VERBOSE
if [ ! -z "$DEBUG" ]; then VERBOSE=2; fi #@@@ && [ "$VERSBOSE" -lt 2]; then


#echo "debugnoflavourgiven"
#set -x




################################################################################3 POPULATE VARS from INI if NOTGIVEN
#FLAVOUR="${FLAVOUR:-UPGRADEsFLAVOUR}"

############################################################## FLAVOUR
if [ -z "${FLAVOUR}" ] && [ ! -z "${UPGRADEsFLAVOUR}" ]; then

    #@@@if [ ! -z "$DEBUG" ] #|| VERSBOS
    if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
        echo "no-flavour-given@ini> FLAVOUR=${UPGRADEsFLAVOUR}"; sleep 1
    fi
    FLAVOUR="${UPGRADEsFLAVOUR}"

elif [ -z "${FLAVOUR}" ] && [ -z "${UPGRADEsFLAVOUR}" ]; then
    echo "err> you must specify build flavour: [stable|current|testing|20.1]"
    echo "or UPGRADEsFLAVOUR=[stable|current|testing|20.1] in wrt.ini"
    #UPGRADEsFLAVOUR="current"
    exit 0

else
    if [ ! -z "$DEBUG" ]; then
        echo "flavour@cmdline> FLAVOUR=${FLAVOUR}"; sleep ${RCSLEEP:0}
    fi
fi












#set +x



    #################################### flavour paths set > phase2 moved lower due to ini < ifzFLAVOUR
    case "${FLAVOUR}" in
    stable)
        #Fsub="builds/rpi-4_snapshot_2.3.637-2_r15199_extra"
        #Bname="rpi4.64-snapshot-25063-2.3.637-2-r15199-ext4-sys.img.gz"

        Fsub="builds/rpi-4_snapshot_2.3.656-15_r15323_extra"
        Bname="rpi4.64-snapshot-25135-2.3.656-15-r15323-ext4-sys.img.gz"

        #echo "no stable build available"; exit 0
    ;;
    current)
        #Fsub="builds/rpi-4_snapshot_2.3.637-2_r15199_extra"
        #Bname="rpi4.64-snapshot-25063-2.3.637-2-r15199-ext4-sys.img.gz"

        Fsub="builds/rpi-4_snapshot_2.3.656-15_r15323_extra"
        Bname="rpi4.64-snapshot-25135-2.3.656-15-r15323-ext4-sys.img.gz"

        #echo "no current build available"; exit 0
    ;;

    testing)
        #Fsub="builds/rpi-4_snapshot_1.15.17-72_r14571_testing"
        #Bname="rpi4.64-snapshot-23902-1.15.17-72-r14571-ext4-sys.img.gz"

	echo "no testing build available"; exit 0
    ;;

    "20.1"*) #echo ""; echo "version: 20.1 has not been released yet"; usage; exit 0
        echo "version: ${FLAVOUR} has not been released yet no build available"; exit 0 #usage; exit 0
    ;;

    *) echo "unknown flavour ${FLAVOUR} no build available"; usage; exit 0; ;;
    esac

























updatednsmasq() {


cat <<'LLL' > /tmp/distfeeds.conf
src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base
LLL
cat <<'LLL' > /tmp/customfeeds.conf
#
LLL

mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf
mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf



#MASQDEBUG=1
#MASQvariant=


if [ -n "$MASQDEBUG" ] && [ -z "$MASQvariant" ]; then
	MASQmsg="$MASQmsg dnsmasq is not installed"
	NOVARIANT=1
elif [ -n "$MASQDEBUG" ]; then
	echo "Checking for newer version for $MASQvariant $MASQver $onsysVERSION"
fi


#if [ -z "$MASQvariant" ]; then MASQmsg="$MASQmsg dnsmasq is not installed"




if [ -n "$MASQDEBUG" ]; then #if [ -n "$MASQDEBUG" ] && [ ! -z "$MASQvariant" ]; then
	#echo "opkg update 1>/dev/null 2>/dev/null" #opkg update
	if ! opkg update 1>/dev/null 2>/dev/null; then
		MASQmsg="$MASQmsg opkgupdatefailed"
		OPKGUPDfail=1
	fi
else #elif [ ! -z "$MASQvariant" ]; then
	if ! opkg update 1>/dev/null 2>/dev/null; then
		MASQmsg="$MASQmsg opkgupdatefailed"
		OPKGUPDfail=1
	fi
fi
#opkg update 1>/dev/null 2>/dev/null #|| return 1
#echo "opkg list-upgradable"; opkg list-upgradable
#if [ -z "$OPKGUPDfail" ] && opkg list-upgradable | grep -q 'dnsmasq'; then #@@@propervariant
#if [ -z "$MASQvariant" ]; then
#	MASQmsg="$MASQmsg dnsmasq is not installed"





#echo "#########sbg opkg list-upgradable | grep \"^$MASQvariant$\""
#opkg list-upgradable | grep "^$MASQvariant$"
#opkg list-upgradable | grep "^$MASQvariant\$"





if [ -z "$OPKGUPDfail" ] && [ -z "$NOVARIANT" ] && opkg list-upgradable | \
	cut -d' ' -f1 | grep -q "^$MASQvariant$"; then #@@@propervariant


	VERFOUND=$(opkg list-upgradable | grep 'dnsmasq')

	[ -n "$MASQDEBUG" ] && echo "VERFOUND: $(opkg list-upgradable | grep 'dnsmasq')"


	if [ ! -z "$(pidof dnsmasq)" ]; then MASQRUNNING=1 ; fi


	[ -n "$MASQDEBUG" ] && echo "opkg upgrade $MASQvariant" #opkg upgrade $MASQvariant || return 1 #@return 0touch /root/.dnsmasq.patched
	#opkg upgrade $MASQvariant && MASQUPDATED=1
	#opkg upgrade $MASQvariant 1>/dev/null 2>/dev/null && MASQUPDATED=1
	


	if [ -n "$MASQDEBUG" ]; then

		if opkg upgrade $MASQvariant; then
			MASQUPDATED=1

		else
			MASQmsg="${MASQmsg} opkgupgradecmdfailed"
		fi
	
	else
		if opkg upgrade $MASQvariant 1>/dev/null 2>/dev/null; then
			MASQUPDATED=1

		else
			MASQmsg="${MASQmsg} opkgupgradecmdfailed"
		fi
	
	fi


else
	#echo "src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base"
	#echo "Z opkg list-upgradable | grep -'dnsmasq'"
	[ -n "$MASQDEBUG" ] && opkg list-upgradable
	MASQmsg="${MASQmsg} no-update-${MASQvariant}-${MASQver}"
fi


while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
	#echo "umount $(mount | grep feeds | cut -d' ' -f3 | head -n1)"
	umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
	#sleep 1
done; rm /tmp/distfeeds.conf 2>/dev/null; rm /tmp/customfeeds.conf 2>/dev/null


#mount | grep feeds


if [ ! -z "$MASQUPDATED" ]; then
	logger -t vulfix "dnsmasq patched: $MASQvariant $MASQmsg"
	if [ ! -z "$MASQRUNNING" ]; then
		[ -n "$MASQDEBUG" ] && echo "/etc/init.d/dnsmasq restart"
		#sleep 3
		#/etc/init.d/dnsmasq restart 1>/dev/null 2>/dev/null
		/etc/init.d/dnsmasq stop 1>/dev/null 2>/dev/null
		sleep 3
		/etc/init.d/dnsmasq start 1>/dev/null 2>/dev/null
		#/etc/init.d/dnsmasq restart 1>/dev/null 2>/dev/null
	fi
	return 0
fi


logger -t vulfix "dnsmasq patch failed: $MASQvariant $MASQmsg"
return 1

}





#MASQDEBUG=1



MASQver=$(opkg list-installed | grep dnsmasq | cut -d' ' -f3)
MASQvariant=$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')

#MASQnewIPK="dnsmasq_2.82-10_aarch64_cortex-a72.ipk"
#MASQnewipkURL="https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base/$MASQnewIPK"
##############base/dnsmasq_2.82-10_aarch64_cortex-a72.ipk #/usr/sbin/dnsmasq

onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")
#echo "localversion: $onsysVERSION"






#if [ ! -f /root/.dnsmasq.patched ]; then



if [ -z "$MASQver" ] || [ -z "$MASQvariant" ]; then #DBG MASQvariant=
	logger -t vulfix "masq update due to known vulnerabilities: $MASQvariant $MASQver [not-installed]"
else

case "$onsysVERSION" in #"2.3"*|"2.5"*)
	"2.5"*) touch /root/.dnsmasq.patched; ;; #next build should not have issue
	"2.3"*)




		case "$MASQver" in #"2.82"*) : ;; #"2.83"*) : ;;
			"2.82"*)
			
			rm /root/.dnsmasq.patched 2>/dev/null
			if [ ! -f /root/.dnsmasq.patched ]; then
				updatednsmasq
				#updatednsmasq 2>/dev/null 1>/dev/null #ONNEXTRUN@newver && touch /root/.dnsmasq.patched
			fi
			;;
			"2.83"*)
				logger -t vulfix "masq version is ok: $MASQvariant $MASQmsg"
				touch /root/.dnsmasq.patched
			;;
			esac
		;;

	*)
		logger -t vulfix "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg"
	;;
esac



fi #end -z ver or variant



#fi #end ! -f patched





































































#############################################################################MODEL/ENVspecificSANITYCHECKS
######if ! grep -q '4-model-b' /tmp/sysinfo/board_name; then echo "only: raspberrypi,4-model-b [issupported]" && exit 0; fi
if [ "$(blkid | grep '^/dev/mmcblk0p2' | grep ext4 | wc -l)" -ne 1 ]; then echo "ext4 sysupgrade only" && exit 0; fi





if [ -z "$DOCHECK" ]; then if [ -z "$Bname" ]; then echo "no> $0 stable|current|check@@@" && exit 0; fi; fi
if [ -z "$Bname" ]; then echo "no> $0 stable|current|check@@@" && exit 0; fi ###paranoid/checksforgitextrapathsetvars


oSYSURL="$Gbase/$Fsub/$Bname"
SYSout="/tmp/${Bname}" #SYSout="/tmp/rpisysup.sh"

#echo "$oSYSURL"





#@@@prereqwget||curlcheckmods
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 2 ]; then
    WGET="$WGETv"
elif [ -z "$DOCHECK" ]; then
    WGET="$WGETs"
else
    WGET="$WGETs"
    #WGET="$WGETv"
fi



rm ${SYSout} 2>/dev/null; rm /tmp/sha256sums 2>/dev/null; rm /tmp/ibbuildinformation.txt 2>/dev/null; sync




if [ ! -z "$DEBUG" ]; then
    echo "# $0 ${ALLPARAMS}"
    echo "    git-repo: $Gbase"
    echo "######################################################"
    echo "      modelf: $MODELf"
    echo "     flavour: $FLAVOUR"
    echo "######################################################"
    sleep ${RCSLEEP:-0}; sleep ${RCSLEEP:-0}; sleep ${RCSLEEP:-0}
fi




if [ ! -z "$DEBUG" ]; then echo "${Gbase}/${Fsub}/ibbuildinformation.txt"; sleep ${RCSLEEP:-0}; fi
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then echo "Downloading ibbuildinformation.txt..."; sleep 1; fi
$WGET -O /tmp/ibbuildinformation.txt "${Gbase}/${Fsub}/ibbuildinformation.txt" || fails "buildinfo-dlprob"


#forupdatecheck.sh to show hyperlink
#WRONG HAS RAW echo "${Gbase}/${Fsub}" > /tmp/.updateurl
echo "${oSYSURL}" > /tmp/.updateurl #OLD-addflavourforfaster-safer-use
echo "${oSYSURL}" > /tmp/.updateurl.$FLAVOUR



onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")
onsysVERSIONn=$(echo $onsysVERSION | sed 's/\.//g' | sed "s/\-//g")
onsysVERSION_M=$(echo $onsysVERSION | cut -d'.' -f1)
onsysVERSION_m=$(echo $onsysVERSION | cut -d'.' -f2)
onsysVERSION_s=$(echo $onsysVERSION | cut -d'.' -f3 | sed 's/\-.*$//g') #onsysVERSION_s=$(echo $onsysVERSION | cut -d'.' -f3)
if echo $onsysVERSION | grep -q '\-'; then onsysVERSION_r=$(echo $onsysVERSION | cut -d'-' -f2); else onsysVERSION_r=0; fi
onsysVERSION_c="${onsysVERSION_M}${onsysVERSION_m}${onsysVERSION_s}${onsysVERSION_r}"
onlineVERSION=$(cat /tmp/ibbuildinformation.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")

#onlineVERSION="1.15.17-53" #dummyolder
#onlineVERSION="2.15.17-53" #dummyolder
#onlineVERSION="0.15.17-53" #dummyolder

onlineVERSIONn=$(echo $onlineVERSION | sed 's/\.//g' | sed "s/\-//g")
onlineVERSION_M=$(echo $onlineVERSION | cut -d'.' -f1)
onlineVERSION_m=$(echo $onlineVERSION | cut -d'.' -f2)
onlineVERSION_s=$(echo $onlineVERSION | cut -d'.' -f3 | sed 's/\-.*$//g') #onlineVERSION_s=$(echo $onlineVERSION | cut -d'.' -f3)
if echo $onlineVERSION | grep -q '\-'; then onlineVERSION_r=$(echo $onlineVERSION | cut -d'-' -f2); else onlineVERSION_r=0; fi
onlineVERSION_c="${onlineVERSION_M}${onlineVERSION_m}${onlineVERSION_s}${onlineVERSION_r}"



##############################################################################################################3
#echo "    onsysVERSION: $onsysVERSION"
#####echo "   onsysVERSIONn: $onsysVERSIONn"
#####echo "$onsysVERSION_M $onsysVERSION_m $onsysVERSION_s $onsysVERSION_r"
#echo "   onlineVERSION: $onlineVERSION"
#####echo "  onlineVERSIONn: $onlineVERSIONn"
#####echo "$onlineVERSION_M $onlineVERSION_m $onlineVERSION_s $onlineVERSION_r "
#####echo "$onsysVERSIONn -lt $onlineVERSIONn"; sleep 2
#####if [ "$onsysVERSIONn" -lt "$onlineVERSIONn" ]; then echo "newer"; else echo "notnewer"; fi #&& exit 0
#####echo "${onsysVERSION_c} -lt ${onlineVERSION_c}"; sleep 3
#####if [ "$onsysVERSION_c" -lt "$onlineVERSION_c" ]; then echo "newer"; else echo "notnewer"; fi #&& exit 0
##############################################################################################################3

########rewrite while-zNEWER:
#exit 0
#set -x


if [ "${onsysVERSION_M}" -lt "${onlineVERSION_M}" ]; then
    M_newer=1
    NEWER=1
fi
if [ -z "$M_newer" ] && [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ]; then
    if [ "${onsysVERSION_m}" -lt "${onlineVERSION_m}" ]; then m_newer=1; fi
    if [ "${onsysVERSION_m}" -lt "${onlineVERSION_m}" ]; then m_newer=$((${onlineVERSION_m} - ${onsysVERSION_m})); fi
fi
if [ -z "$m_newer" ]; then
    if [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ] && [ "${onsysVERSION_m}" -eq "${onlineVERSION_m}" ]; then
        #if [ "${onsysVERSION_s}" -lt "${onlineVERSION_s}" ]; then s_newer=1; fi
        if [ "${onsysVERSION_s}" -lt "${onlineVERSION_s}" ]; then s_newer=$((${onlineVERSION_s} - ${onsysVERSION_s})); fi
    fi
fi
if [ -z "$s_newer" ]; then
    if [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ] && [ "${onsysVERSION_m}" -eq "${onlineVERSION_m}" ] && \
        [ "${onsysVERSION_s}" -eq "${onlineVERSION_s}" ]; then
            #if [ "${onsysVERSION_r}" -lt "${onlineVERSION_r}" ]; then r_newer=1; fi
            if [ "${onsysVERSION_r}" -lt "${onlineVERSION_r}" ]; then r_newer=$((${onlineVERSION_r} - ${onsysVERSION_r})); fi
        fi
fi
#if [ -z "$r_newer" ]; then OLDER=1; fi
if [ -z "$r_newer" ] && [ -z "$M_newer" ] && [ -z "$m_newer" ] && [ -z "$s_newer" ]; then
    #if [ -z "$M_newer" ] && [ -z "$m_newer" ] && [ -z "$s_newer" ]; then
        OLDER=1
    #fi
#else
fi




###################################
if [ ! -z "$DEBUG" ]; then echo "OLDER: $OLDER M_newer: $M_newer m_newer: $m_newer s_newer: $s_newer r_newer: $r_newer"; fi
###sleep 3; #exit 0
###################################






if [ "$onlineVERSION" = "$onsysVERSION" ]; then
    echo "   online:$onlineVERSION = onsys:$onsysVERSION"; #sleep 1
    if [ ! -z "$FORCE" ] || [ ! -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
		echo "force:$FORCE/downgrade:$DOWNGRADE given flash(continue) anyway (unless check given)"
        DOWNGRADE=1
    else

		if ([ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]) || [ ! -z "$DEBUG" ]; then
			echo "force:$FORCE/downgrade:$DOWNGRADE notgiven-sameversion -> exit"
        fi

		exit 0 #if [ -z "$FORCE" ]; then #|| [ -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
    fi

####fi ################################### TESTEXACTLYTHESAME #@TESTING elif if [ ! -z "$OLDER" ]; then
elif [ ! -z "$OLDER" ]; then
    #checkfor'downgrade' || DOCHECK return etc...
    #echo "   onlineVERSION: [${FLAVOUR}-older:$onlineVERSION] $onsysVERSION ${DOWNGRADE}"; #sleep 2
    echo "   flavour:${FLAVOUR} online:$onlineVERSION[older] onsys:$onsysVERSION ${DOWNGRADE}"; #sleep 2
else
    #echo "   onlineVERSION: ${FLAVOUR}-${onlineVERSION} [newer:$onsysVERSION]"; #sleep 2
    echo "   flavour:${FLAVOUR} online:${onlineVERSION}[newer] onsys:$onsysVERSION"; #sleep 2
fi
#sleep 1



    if [ ! -z "$DOCHECK" ]; then exit 0; fi #echo "checkonly... " && exit 0; fi

    if [ ! -z "$OLDER" ] && [ -z "$DOWNGRADE" ]; then
            echo "use> 'downgrade'"; sleep 1; exit 0 #echo "use> $0 'downgrade'"; sleep 1; exit 0
    elif [ ! -z "$OLDER" ] && [ ! -z "$DOWNGRADE" ]; then
            : #echo "downgrading..."; sleep 1 ######echo "downgrading...: ${DOWNGRADE}"; sleep 1
    fi



    #if [ -z "$DOWNGRADE" ]; then echo "DOWNempty"; fi
    #if [ ! -z "$OLDER" ] && [ -z "$DOWNGRADE" ]; then


    #echo "MUNG"; exit 0

#if ! -z m_newer && m_newer -gt 30 && RESTOREPACKAGES...
    #echo "use force"
    #TAINTSverSPAN=1
#fi


#echo "RUMMY"; exit 1







if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 1 ]; then
    echo "Downloading... $FLAVOUR"; sleep 1 #echo "Download: wulfy23/rpi4 $FLAVOUT"; sleep 1 #FLAVOUT?
elif [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
    echo "Download: wulfy23/rpi4 $FLAVOUR $Bname ($oSYSURL)"; sleep 1
fi
$WGET -O ${SYSout} "${oSYSURL}" || fails "dl-img-prob"




#if [ ! -z "$VERBOSE" ]; then echo "/tmp/sha256sums"; sleep 1; fi
#if [ ! -z "$VERBOSE" ]; then
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
    echo "Download: sha256sums"; sleep 1
fi
$WGET -O /tmp/sha256sums "${Gbase}/${Fsub}/sha256sums" || fails "dl-shasum-prob"





if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then echo "sha256sum check"; sleep 1; fi
CDIR="${PWD}"; cd /tmp; sha256sum -c sha256sums 2>/dev/null|grep OK || fails "shasum-chk-issue"; cd $CDIR
#echo "cd /tmp; sha256sum -c sha256sums 2>/dev/null|grep OK; cd $CDIR" #sha256sum -c /tmp/sha256sums 2>/dev/null|grep OK





if [ ! -z "$RESTOREPACKAGES" ]; then #prep-dootherstuffhere
    :
else
    :
fi









#@@@new@20201212
if [ ! -z "$DLONLY" ]; then
	echo "DLONLY img @ ${SYSout}"
	exit 0
fi





#if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 1 ]; then echo "run> sysupgrade $RESTOREPACKAGES ${SYSout}"; sleep 2; fi

if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
    echo "sysupgrade -v $RESTOREPACKAGES ${SYSout}"; sleep 2
    sysupgrade -v $RESTOREPACKAGES ${SYSout}
else
    #echo "runthiscommand> sysupgrade $RESTOREPACKAGES ${SYSout}"
    sysupgrade $RESTOREPACKAGES ${SYSout}
fi



exit 0














COMPARISONclunky1() {
if [ "$onlineVERSION" = "$onsysVERSION" ]; then
    echo "   online:$onlineVERSION = onsys:$onsysVERSION"; sleep 1
    if [ ! -z "$FORCE" ] || [ ! -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
		echo "force:$FORCE/downgrade:$DOWNGRADE given flash(continue) anyway (unless check given)"
        DOWNGRADE=1
    else
        exit 0 #if [ -z "$FORCE" ]; then #|| [ -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
    fi

####fi ################################### TESTEXACTLYTHESAME #@TESTING elif if [ ! -z "$OLDER" ]; then
elif [ ! -z "$OLDER" ]; then
    #checkfor'downgrade' || DOCHECK return etc...
    echo "   onlineVERSION: [${FLAVOUR}-older:$onlineVERSION] $onsysVERSION ${DOWNGRADE}"; #sleep 2
else
    echo "   onlineVERSION: ${FLAVOUR}-${onlineVERSION} [newer:$onsysVERSION]"; #sleep 2
fi
sleep 2
}









exit 0

gtarurl="https://github.com/wulfy23/rpi4/raw/master/utilities/putty/putty.tar.gz"
gtarfname=$(basename $gtarurl)
WGET="wget --no-parent -q -nd -l1 -nv --show-progress "
POSTRUN="/boot/rpi-multiboot-setup.sh"

fail() {
    echo "$@" && exit 1
}


if [ -f /$gtarfname ]; then
    #echo "Removing previous /$gtarfname"; sleep 1
    rm /"${gtarfname:-0}"
fi

#echo "Downloading: $gtarfname"; sleep 1
(cd / && $WGET $gtarurl) || fail "Download issues: /$gtarurl" #) && (cd / && tar -xvzf /$gtarfname)

if file /$gtarfname | grep -q "gzip compressed data"; then echo "gzipok"; else echo "gzipnope" && fail "oops"; fi
(cd / && tar -xvzf $gtarfname 2>/dev/null) || fail "Extract issues: /$gtarfname"
if [ -f "$POSTRUN" ]; then
    echo "Running setupscr: $POSTRUN"
    sh $POSTRUN
else
    echo "setupscr: $POSTRUN [missing]" && fail "oops"
fi


exit 0




#####################################################################################################################
#echo "Download: wulfy23/rpi4-multiboot/master/multiboot/setup/rpi-multiboot.sh > /bin"
#$WGET -O /bin/rpi-multiboot.sh https://raw.github.com/wulfy23/rpi4-multiboot/master/multiboot/setup/rpi-multiboot.sh || fails "dlprob"
#####echo "ok > /bin/rpi-multiboot.sh init"
#chmod +x /bin/rpi-multiboot.sh
#####################################################################################################################
#echo "Downloading: $gtarfname"; sleep 1; (cd / && $WGET $gtarurl) && (cd / && tar -xvzf /$gtarfname)
#gtarurl="https://raw.githubusercontent.com/wulfy23/rpi4/master/builds/special.bin"
#https://github.com/wulfy23/rpi4/raw/master/utilities/putty/putty.tar.gz
#BEST gittarurl="https://raw.githubusercontent.com/wulfy23/rpi4/master/builds/special.bin"
#https://raw.githubusercontent.com/wulfy23/rpi4/master/builds/README
#NEEDS -O gittarurl="https://github.com/wulfy23/rpi4/blob/master/builds/special.bin?raw=true"
#NOPEgittarurl="https://github.com/wulfy23/rpi4/blob/master/builds/special.bin"
#####################################################################################################################
#WGET="wget --no-parent -nd -N -l1 -nv --show-progress "
#WGET="wget --no-parent -nd -N -l1 -r -nv --show-progress "
#WGET="wget --no-parent -nd -l1 -nv --show-progress "
#####################################################################################################################
#sed -i -e "/special/d" $FOLDr/sha256sums






















############################ V1
############################ V1
############################ V1
############################ V1
############################ V1
############################ V1
############################ V1
############################ V1
updatednsmasqV1() {
cat <<'LLL' > /tmp/distfeeds.conf
src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base
LLL
cat <<'LLL' > /tmp/customfeeds.conf
#
LLL

mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf
mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf

#echo "opkg update 1>/dev/null 2>/dev/null || return 1"
#opkg update
opkg update 1>/dev/null 2>/dev/null #|| return 1


#echo "opkg list-upgradable"; opkg list-upgradable
if opkg list-upgradable | grep -q 'dnsmasq'; then

	echo "VERFOUND: $(opkg list-upgradable | grep 'dnsmasq')"


	if [ ! -z "$(pidof dnsmasq)" ]; then MASQRUNNING=1 ; fi


	echo "opkg upgrade $MASQvariant" #opkg upgrade $MASQvariant || return 1 #@return 0touch /root/.dnsmasq.patched
	#opkg upgrade $MASQvariant && MASQUPDATED=1

else
	#echo "src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base"
	#echo "Z opkg list-upgradable | grep -'dnsmasq'"
	opkg list-upgradable
fi



while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
	#echo "umount $(mount | grep feeds | cut -d' ' -f3 | head -n1)"
	umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
	#sleep 1
done; rm /tmp/distfeeds.conf 2>/dev/null; rm /tmp/customfeeds.conf 2>/dev/null


#mount | grep feeds




if [ ! -z "$MASQUPDATED" ]; then
	if [ ! -z "$MASQRUNNING" ]; then
		echo "/etc/init.d/dnsmasq restart"
		/etc/init.d/dnsmasq restart 1>/dev/null 2>/dev/null
	fi
	return 0
fi

return 1



}









if [ ! -f /root/.dnsmasq.patched ]; then


MASQver=$(opkg list-installed | grep dnsmasq | cut -d' ' -f3)
MASQvariant=$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')

#MASQnewIPK="dnsmasq_2.82-10_aarch64_cortex-a72.ipk"
#MASQnewipkURL="https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base/$MASQnewIPK"
##############base/dnsmasq_2.82-10_aarch64_cortex-a72.ipk #/usr/sbin/dnsmasq

onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")
#echo "localversion: $onsysVERSION"

case "$onsysVERSION" in
	"2.3"*)

		case "$MASQver" in #"2.82"*) : ;; #"2.83"*) : ;;
			"2.82"*)
			if [ ! -f /root/.dnsmasq.patched ]; then
				updatednsmasq
				#updatednsmasq 2>/dev/null 1>/dev/null #ONNEXTRUN@newver && touch /root/.dnsmasq.patched
			fi
			;;
			"2.83"*)
				touch /root/.dnsmasq.patched
			;;
			esac

		;;

esac


fi
############################ V1
############################ V1
############################ V1
############################ V1
############################ V1
############################ V1
############################ V1









########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2


updatednsmasqV2() {

cat <<'LLL' > /tmp/distfeeds.conf
src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base
LLL
cat <<'LLL' > /tmp/customfeeds.conf
#
LLL

mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf
mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf

#echo "opkg update 1>/dev/null 2>/dev/null || return 1" #opkg update
#opkg update 1>/dev/null 2>/dev/null #|| return 1
if ! opkg update 1>/dev/null 2>/dev/null; then
	MASQmsg="$MASQmsg opkgupdatefailed"
	OPKGUPDfail=1
fi




#MASQDEBUG=1

#echo "opkg list-upgradable"; opkg list-upgradable
if [ -z "$OPKGUPDfail" ] && opkg list-upgradable | grep -q 'dnsmasq'; then #@@@propervariant

	[ -n "$MASQDEBUG" ] && echo "VERFOUND: $(opkg list-upgradable | grep 'dnsmasq')"

	if [ ! -z "$(pidof dnsmasq)" ]; then MASQRUNNING=1 ; fi


	[ -n "$MASQDEBUG" ] && echo "opkg upgrade $MASQvariant" #opkg upgrade $MASQvariant || return 1 #@return 0touch /root/.dnsmasq.patched
	#opkg upgrade $MASQvariant && MASQUPDATED=1
	#opkg upgrade $MASQvariant 1>/dev/null 2>/dev/null && MASQUPDATED=1
	


	if [ -n "$MASQDEBUG" ]; then

		if opkg upgrade $MASQvariant; then
			MASQUPDATED=1

		else
			MASQmsg="${MASQmsg} opkgupgradecmdfailed"
		fi
	
	else
		if opkg upgrade $MASQvariant 1>/dev/null 2>/dev/null; then
			MASQUPDATED=1

		else
			MASQmsg="${MASQmsg} opkgupgradecmdfailed"
		fi
	
	fi



else
	#echo "src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base"
	#echo "Z opkg list-upgradable | grep -'dnsmasq'"
	[ -n "$MASQDEBUG" ] && opkg list-upgradable
	MASQmsg="${MASQmsg} no-update"
fi


while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
	#echo "umount $(mount | grep feeds | cut -d' ' -f3 | head -n1)"
	umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
	#sleep 1
done; rm /tmp/distfeeds.conf 2>/dev/null; rm /tmp/customfeeds.conf 2>/dev/null


#mount | grep feeds


if [ ! -z "$MASQUPDATED" ]; then
	logger -t vulfix "dnsmasq patched: $MASQvariant $MASQmsg"
	if [ ! -z "$MASQRUNNING" ]; then
		[ -n "$MASQDEBUG" ] && echo "/etc/init.d/dnsmasq restart"
		/etc/init.d/dnsmasq restart 1>/dev/null 2>/dev/null
	fi
	return 0
fi

logger -t vulfix "dnsmasq patch failed: $MASQvariant $MASQmsg"
return 1

}


#MASQDEBUG=1

if [ ! -f /root/.dnsmasq.patched ]; then


MASQver=$(opkg list-installed | grep dnsmasq | cut -d' ' -f3)
MASQvariant=$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')

#MASQnewIPK="dnsmasq_2.82-10_aarch64_cortex-a72.ipk"
#MASQnewipkURL="https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base/$MASQnewIPK"
##############base/dnsmasq_2.82-10_aarch64_cortex-a72.ipk #/usr/sbin/dnsmasq

onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")
#echo "localversion: $onsysVERSION"

case "$onsysVERSION" in #"2.3"*|"2.5"*)
	"2.5"*) touch /root/.dnsmasq.patched; ;; #next build should not have issue
	"2.3"*)

		case "$MASQver" in #"2.82"*) : ;; #"2.83"*) : ;;
			"2.82"*)
			if [ ! -f /root/.dnsmasq.patched ]; then
				updatednsmasq
				#updatednsmasq 2>/dev/null 1>/dev/null #ONNEXTRUN@newver && touch /root/.dnsmasq.patched
			fi
			;;
			"2.83"*)
				touch /root/.dnsmasq.patched
			;;
			esac
		;;

	*)
		logger -t vulfix "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg"
	;;
esac


fi

########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2
########################### V2







#echo "WARRANT"; exit 0
#opkg update; opkg upgrade $(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')
#echo "opkg update; opkg upgrade \$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')"
######################################################################################################
#WGETs="wget --no-parent -q -nd -l1 -nv "
#echo "$WGETs -O /tmp/dnsmasq.ipk $MASQnewipkURL"
#echo "opkg --autoremove dnsmasq-full"
#echo "opkg install /tmp/dnsmasq.ipk"
#######################################################################################################
#dnsmasq-full_2.82-10_aarch64_cortex-a72.ipk	177.2 KB	Tue Jan 19 04:12:03 2021













