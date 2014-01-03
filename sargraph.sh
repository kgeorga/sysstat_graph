#!/bin/bash

SARDIR="/var/log/sa/"
SAR="/usr/bin/sar"
DAYS="30"

#Get a list of files
FILES=$(ls -tr $SARDIR|grep -e "sa[0-9][0-9]$"|tail -$DAYS)

function print_cpu {

echo "** Printing the CPU usage daily average **"
echo

for i in $FILES;do

	#get the date the file was last modified
        DATE=$(stat $SARDIR$i | grep "Modify" | awk '{print $2}')

	#Get the average value of the "idle" column
        TMPAVG=$($SAR -f $SARDIR$i 2>/dev/null 1>&2 ; RES=$? ; if [ "$RES" == "0" ]; then $SAR -f $SARDIR$i 2>/dev/null | grep "Average" | tail -1 | awk '{print $8}' ;else echo "0";fi)

	#Remove decimal points
        AVG=${TMPAVG/.*}

	#Check if this is actually a number and if so subtract it from 100 to get the actual usage
        if [ "$AVG" -eq "$AVG" ]; then 
                PRINT=$((100-$AVG))
        else
                PRINT=0
        fi

        echo -n $DATE " : "

        for j in $(seq 1 $PRINT);do echo -n "#";done
        echo -n " ($PRINT %)"

        echo

done

}

function print_load {

	#Get number of cores
	CORES=$(cat /sys/devices/system/cpu/cpu[0-9]*/topology/*_id | awk 'ORS=NR%2?",":"\n"' | sort | uniq | wc -l)

	echo "** Printing the 1 min load daily average (CPU core count: $CORES) **"
	echo

	for i in $FILES;do

		#Get the date
	        DATE=$(stat $SARDIR$i | grep "Modify" | awk '{print $2}')

		#Get the daily average value of the 1 minute load average
	        TMPAVG=$($SAR -q -f $SARDIR$i 2>/dev/null 1>&2 ; RES=$? ; if [ "$RES" == "0" ]; then $SAR -q -f $SARDIR$i 2>/dev/null | grep "Average" | tail -1 | awk '{print $4}' ;else echo "0";fi)

		#Remove decimal points
	        AVG=${TMPAVG/.*}
        
		#If this is not a number set it to 0
	        if [ "$AVG" -ne "$AVG" ]; then AVG=0 ; fi

        	echo -n $DATE " : "
	        for j in $(seq 1 $AVG);do echo -n "#";done
	        echo -n " ($AVG)"
        	echo

	done
}

function print_ram {

	#Get memory installed
	MEMTOTAL=$(cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')

	echo "** Printing RAM actual usage daily average (memotal: $(($MEMTOTAL/1024)) MB) **"
	echo

	for i in $FILES;do

		#Get the date
        	DATE=$(stat $SARDIR$i | grep "Modify" | awk '{print $2}')

		#Get the actual RAM - this is minus buffers and cache
	        TMPAVG=$($SAR -r -f $SARDIR$i 2>/dev/null 1>&2 ; RES=$? ; if [ "$RES" == "0" ]; then $SAR -r -f $SARDIR$i 2>/dev/null | grep "Average" | tail -1 | awk '{print $3-$5-$6}' ; else echo "0";fi)

		#If this is not a number set it to 0
        	if [ "$TMPAVG" -ne "$TMPAVG" ]; then 
			TMPAVG=0
			AVG=0
		else
			#Calculate the percentage of the used memory over the total memory installed - remove decimal points
		        AVG=$(echo "($TMPAVG/$MEMTOTAL)*100" | bc -l)
        		AVG=${AVG/.*}

			#If this is not a number or if it is blank set it to 0
			if [ "$AVG" == "" ]; then AVG=0 ; fi
			if [ "$AVG" -ne "$AVG" ]; then AVG=0 ; fi
		fi

	        echo -n $DATE " : "
        	for j in $(seq 1 $AVG);do echo -n "#";done
	        echo -n " ($AVG %)"
        	echo
	done

}

echo "Showing graphs for up to $DAYS days ago"
echo
print_load
echo
print_cpu
echo
print_ram
