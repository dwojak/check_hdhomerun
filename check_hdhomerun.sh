#!/bin/bash
#
# Simple HDhomerun Check.
# Copyright (C) 2017 Rafal Dwojak
#
#Set script name
SCRIPT=`basename ${BASH_SOURCE[0]}`
#Set default values
tunerCode=0
tunerNumber=0
errorCode=0

# help function
function printHelp {
  echo -e "Nagios check for HDHomeRun device v1.0"
  echo -e "Help for $SCRIPT"
  echo -e "Basic usage: $SCRIPT -p {protocol}"
  echo -e "-c Sets device number, you can get it using command 'hdhomerun_config discover'"
  echo -e "-t tuner number"
  echo -e "Example: $SCRIPT -c 105C3B45 -t 1"
  echo -e "Author: Rafal Dwojak, rafal@dwojak.com"
  echo -e "Github: https://github.com/dwojak/check_hdhomerun"
  exit 1
}

while getopts :c:t:h FLAG; do
  case $FLAG in
    c)
      tunerCode=$OPTARG
      ;;
    t)
      tunerNumber=$OPTARG
      ;;
    h)
      printHelp
      ;;
    \?)
      echo -e "Option -$OPTARG not allowed.\\n"
      printHelp
      exit 2
      ;;
  esac
done

output=$(hdhomerun_config $tunerCode get /tuner$tunerNumber/debug | tr '\n' ' ' | awk '{ print $4 " " $5 " " $6 " " $9 " " $10 " " $11 " " $14 " " $15 " " $17 " " $18 " " $19}')
signalStrength=$(echo $output | awk '{ print $1}')
netError=$(echo $output | awk '{ print $10}')

if [ "$signalStrength" == "ss=100" ] && [ "$netError" == "err=0" ]; then
echo "OK: Tuner metrics: $output | $output"
errorCode=0
else
        if [ -z "$output" ]; then
        echo "CRITICAL: Verify if device is up | ss= snq= seq= bps= resync= overflow= te= crc= pps= err= stop="
        errorCode=2
        else
        echo "WARNING: Verify tuner metricsi: $output | $output"
        errorCode=1
        fi
fi

exit $errorCode
