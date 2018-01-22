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
# Setup CMSSW area and variables
#-------------------------------------
RELEASE=CMSSW_9_2_6
RELEASE_DIR=/afs/cern.ch/work/a/anoolkar/private/
TEST_DIR=$PWD
LOG_DIR=${TEST_DIR}/log
LOGFILE=${LOG_DIR}/FillInfoTriggerO2O.log
DATEFILE=${LOG_DIR}/FillInfoTriggerO2ODate.log
DATE=`date --utc`
D=`date +"%m-%d-%Y-%T" --utc`

#-------------------------------------
# Fetch fill number from previous run.
#-------------------------------------
interval=3
firstfill=$(grep -n firstFill FillInfoPopConAnalyzer.py | cut -d: -f1)
firstfill=$(awk 'NR == '"$firstfill"' {print $4}' ${TEST_DIR}/FillInfoPopConAnalyzer.py)
lastfill=$(grep -n lastFill FillInfoPopConAnalyzer.py | cut -d: -f1)
lastfill=$(awk 'NR == '"$lastfill"' {print $4}' ${TEST_DIR}/FillInfoPopConAnalyzer.py)
sed -i '35s/'"$firstfill"'/'`expr $lastfill + 1`'/' ${TEST_DIR}/FillInfoPopConAnalyzer.py
sed -i '36s/'"$lastfill"'/'`expr $lastfill + $interval`'/' ${TEST_DIR}/FillInfoPopConAnalyzer.py
let "firstfill=lastfill+1"
let "lastfill=lastfill+interval"

#-------------------------------------
# Setup CMSSW log files
#-------------------------------------
OUTFILE="${TEST_DIR}/log/fill_"$D"_"$firstfill"-"$lastfill".log"
pushd $RELEASE_DIR/$RELEASE/src/
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh` 

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

pushd $LOG_DIR

echo  "We are in: $PWD" | tee -a $LOGFILE

echo "*** Checking the CMSSW environment for the job ***" | tee -a $LOGFILE
set | tee -a $LOGFILE

#- sdg: These cfg were in $RELEASE_DIR/$RELEASE/src/CondTools/Ecal/python
#       but we keep them in this area in order to avoid issues with the release.

submit cmsRun ${TEST_DIR}/FillInfoPopConAnalyzer.py       

# END OF CHANGES
log "-----------------------------------------------------------------------"
log DONE
exit 0
