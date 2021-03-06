#!/bin/sh

#@@@ -v outofrange bug

ALLPARAMS="${*}"
Gbase="https://raw.github.com/wulfy23/rpi4/master/utilities"
Bname="rpisysup.sh"

WGETv="wget --no-parent -q -nd -l1 -nv --show-progress " #<NOTv> WGET="wget --no-parent -nd -l1 --show-progress "
WGETs="wget --no-parent -q -nd -l1 -nv "



fails() {
    echo "$1" && exit 1
}
usage() {
cat <<EOG

    $0 [-R] [stable|current|testing|20.1] [check|downgrade|force] [-v] [dlonly]

        stable  =   long term image with minimal testing code
        current =   medium term image with some code ( medium chance of bugs some new features )
        testing =   short term image with latest testing code / features ( no opkg repos - removed anytime )

    NOTE: /root/wrt.ini -> UPGRADEsFLAVOUR="current" ( stable || testing ) no need to specify...

    i.e.

    $0 stable check
    $0 -R stable

EOG
}




while [ "$#" -gt 0 ]; do
case "${1}" in
    help|-h|--help) usage; exit 0; ;;
    current|stable|testing) FLAVOUR="${1}"; shift 1; ;; #@ifzFLAV
    #"20."*) FLAVOUR="${1}"; shift 1; ;; #@ifzFLAV
    check) DOCHECK="check"; shift 1; ;;
    force) FORCE="force"; shift 1; ;;
    downgrade) DG="downgrade"; shift 1; ;;
    "-R") Rpkg="-R"; shift 1; ;;
    "-v") VERBOSE="-v"; shift 1; ;;

    #20201212 testing
    dlonly) DLONLY="dlonly"; shift 1; ;;

    *)
        #DOCHECK="check"
        echo "unknown-parameter: $1"; usage; shift 1; sleep 1; exit 0; ;;
esac #if [ -f
done
#@!a+b-c





if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 2 ]; then
    WGET="$WGETv"
elif [ -z "$DOCHECK" ]; then
    WGET="$WGETs"
else
    WGET="$WGETs" #WGET="$WGETv"
fi



rm /tmp/rpisysup.sh 2>/dev/null; sync #gitwgetdontgetlatest@WGET #rm /tmp/${}

if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 0 ]; then
    echo "Download: wulfy23/rpi4 $Bname"; sleep 1
fi
$WGET -O /tmp/rpisysup.sh "${Gbase}/${Bname}" || fails "dlprob"
sync
chmod +x /tmp/rpisysup.sh


if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 0 ]; then
    echo "/bin/sh /tmp/rpisysup.sh $Rpkg ${FLAVOUR} ${DOCHECK} ${FORCE} ${DG} ${VERBOSE} ${DLONLY}"; sleep 1
fi
/bin/sh /tmp/rpisysup.sh $Rpkg ${FLAVOUR} ${DOCHECK} ${FORCE} ${DG} ${VERBOSE} ${DLONLY}

exit 0







#current|stable|testing) FLAVOUR="${1}"; shift 1; ;; #@ifzFLAV
#curl -O https://downloads.openwrt.org/snapshots/targets/ath79/generic/openwrt-imagebuilder-ath79-generic.Linux-x86_64.tar.xz
#############################################################################################################
#curl -sSL "https://raw.github.com/wulfy23/rpi4/master/utilities/rpi-sysup-online.sh" > /bin/rpi-sysup-online.sh; sync; chmod +x /bin/rpi-sysup-online.sh; /bin/rpi-sysup-online.sh -R current
#############################################################################################################
#echo "$WGET -O - \"${Gbase}/${Bname}\" | sh stable -R"
#echo "#################################################################3"
#echo "wget -O - \"${Gbase}/${Bname}\" | sh ${FLAVOUR} $Rpkg $DOCHECK"
#echo "#################################################################3"
#sleep 3
#############################################################################################################
#echo "shasum check"; sleep 2; CDIR="${PWD}"; cd $FOLDr; sha256sum -c sha256sums 2>/dev/null|grep OK; cd $CDIR
#############################################################################################################


#wget --no-parent -nd -l1 -O /tmp/rpisysup.sh https://raw.github.com/wulfy23/rpi4/master/utilities/rpisysup.sh







