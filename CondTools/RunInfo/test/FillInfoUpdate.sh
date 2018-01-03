
# Basic setup at lxplus using acron
# Ref: http://information-technology.web.cern.ch/services/fe/afs/howto/authenticate-processes
# (a) kinit
# (b) acrontab -e

# The acrontab acript will look like:
# */1 * * * * lxplus049 $PATH/FillInfoUpdate.sh > $PATH/cron_log.txt
# Ref: https://raw.githubusercontent.com/cms-sw/cmssw/09c3fce6626f70fd04223e7dacebf0b485f73f54/RecoVertex/BeamSpotProducer/scripts/READMEMegascript.txt


#####################################
# SHELL SCRIPT TO BE RUN BY ACRON
# Ref: https://github.com/cms-sw/cmssw/blob/09c3fce6626f70fd04223e7dacebf0b485f73f54/CondTools/Ecal/python/updateO2O.sh
#####################################

#-------------------------------------
# Setup CMSSW area and log files
#-------------------------------------
RELEASE=CMSSW_9_2_6
RELEASE_DIR=/afs/cern.ch/work/a/anoolkar/private/
DIR=/afs/cern.ch/work/a/anoolkar/private/CMSSW_9_2_6/src/CondTools/RunInfo/test
LOGFILE=${DIR}/FillInfoTriggerO2O.log
DATEFILE=${DIR}/FillInfoTriggerO2ODate.log
DATE=`date --utc`
OUTFILE="/afs/cern.ch/work/a/anoolkar/private/CMSSW_9_2_6/src/CondTools/RunInfo/test/o2oUpdate_$$.txt"
pushd $RELEASE_DIR/$RELEASE/src/
#@R#export SCRAM_ARCH=slc6_amd64_gcc493
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh` 

#echo "*** Checking the environment for the job ***" | tee -a $LOGFILE
#set | tee -a $LOGFILE
#echo "*** Checking the environment for the job ***" | tee -a $LOGFILE
#set | tee -a $LOGFILE

#-------------------------------------
# Define various functions
#-------------------------------------
function log() {
    echo "[`date`] : $@ " | tee -a $OUTFILE
}

function submit() {
    log $@
     $@ | tee -a -a $OUTFILE
}


#@R#JCPORT=9999
#@R#while getopts ":t:r:p:k" options; do
#@R#   case $options in
#@R#       t ) TPG_KEY=$OPTARG;;
#@R#       r ) RUN_NUMBER=$OPTARG;;
#@R#       p ) JCPORT=$OPTARG;;
#@R#       k ) KILLSWITCH=1;;
#@R#   esac
#@R#done

#@R#log "-----------------------------------------------------------------------"
#@R#log "${DIR}/updateO2O.sh"
#@R#log "PID $$"
#@R#log "HOSTNAME $HOSTNAME"
#@R#log "JCPORT $JCPORT"
#@R#log "TPG_KEY $TPG_KEY"
#@R#log "RUN_NUMBER $RUN_NUMBER"
#@R#log "date `date`"
#@R#log "-----------------------------------------------------------------------"


#######     ------  popcon  beginning   --------  #######################

echo " " | tee -a $LOGFILE
echo "--------: FillInfo O2O was triggered at :-------- " | tee -a $LOGFILE
echo "$DATE" | tee -a $LOGFILE

#######     ----     getting the previous cron date ############### 
#######     parsing the last line from PopCon DATE log file###### 
LOGDATE=`cat $DATEFILE | awk 'NR ==1 {print $0}'`
TMSLOGDATE=`date --utc -d "$LOGDATE" +%s`
echo "timestamp for the log (last log)" $TMSLOGDATE "corresponding to date" | tee -a $LOGFILE
echo $LOGDATE | tee -a $LOGFILE
rm -f $DATEFILE
echo $DATE > $DATEFILE



pushd $DIR

echo  "We are in: $PWD" | tee -a $LOGFILE

echo "*** Checking the CMSSW environment for the job ***" | tee -a $LOGFILE
set | tee -a $LOGFILE

#- sdg: These cfg were in $RELEASE_DIR/$RELEASE/src/CondTools/Ecal/python
#       but we keep them in this area in order to avoid issues with the release.
submit cmsRun FillInfoPopConAnalyzer.py       


# END OF CHANGES
log "-----------------------------------------------------------------------"
if [ -n "$KILLSWITCH" ]; then
    log "Killswitch activated"
ADDR="http://$HOSTNAME:$JCPORT/urn:xdaq-application:service=jobcontrol/ProcKill?kill=$$"

KILLCMD="curl $ADDR"

log $KILLCMD
$KILLCMD > /dev/null

fi

log DONE


exit 0
