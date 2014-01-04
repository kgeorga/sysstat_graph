#!/bin/bash

SARDIR="/var/log/sa/"		#Location of the sysstat files
SAR="/usr/bin/sar"		#Location of the sar executable
DAYS="30"			#Number of days that the script will attempt to generate graphs for

### DON'T CHANGE ANYTHING BELOW THIS LINE ###

function print_error {
	echo
	echo "$1" "$2"
	echo
	exit 1
}

function print_stats {
	#$1 is the message, $2 is the value list, $3 is a flag (0/1) that states if this is a percentage or not

	echo "$1"
	echo

	for i in $2;do
		DATE=$(echo $i|cut -f 1 -d":")
		VALUE=$(echo $i|cut -f 2 -d":")

		PERCENTAGE=$([ "$3" -eq 1 ] 2>/dev/null && echo "%" || PERCENTAGE="")

		echo -n $DATE ":"
	       	echo -n " ($VALUE$PERCENTAGE) "

		[ "$VALUE" -lt 100 ] && echo -n " "
		[ "$VALUE" -lt 10 ] && echo -n " "

	        for j in $(seq 1 $VALUE);do echo -n "#";done
		
		echo
	done
}

#Delete all the non-digit characters from the DAYS string
DAYSFIXED=$(echo $DAYS | tr -d -c [:digit:])

#Make sure that all the configured variables are validated.
[ ! -d "$SARDIR" ] && print_error $SARDIR "does not exists!"											#Make sure the path exists
[ ! -x "$SAR" ] && print_error $SAR "does not exists or it's not executable!"									#Make sure the executable is there
[ "$DAYSFIXED" -eq "$DAYSFIXED" ] 2>/dev/null; [ "$?" -ne 0 ] && print_error $DAYS "is not a number or cannot be converted to a number!"	#The integer equality test will validate if this is an integer

#Get a list of valid sar files
FILES=$(ls -tr $SARDIR|grep -e "sa[0-9][0-9]$"|tail -$DAYSFIXED)

#Initialize the variables that are used to hold the data
CPU_VALUES_LIST="" ; RAM_VALUES_LIST="" ; LOADAVG_VALUES_LIST=""

#Get memory installed
MEMTOTAL=$(cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')

#Get number of cores
CORES=$(cat /sys/devices/system/cpu/cpu[0-9]*/topology/*_id | awk 'ORS=NR%2?",":"\n"' | sort | uniq | wc -l)

for i in $FILES;do

	#Get the date from the file attributes
	DATE=$(stat $SARDIR$i | grep "Modify" | awk '{print $2}')

	#Get all the values into a single line - this also tests if the sar command succeeds. If it doesn't it creates a bogus line with zeros.
	ALLSTATS=$($SAR -f $SARDIR$i 2>/dev/null 1>&2 ; RES=$? ; if [ "$RES" == "0" ]; then $SAR -urq -f $SARDIR$i 2>/dev/null | grep "Average" | tail -3;else echo "Average: all 0 0 0 0 0 0 Average: 0 0 0 0 0 0 0 0 0 Average: 0 0 0 0 0 0";fi)

	#Get the individual values for every metric
	CPU_VALUE=$(echo $ALLSTATS | awk '{ print $8 }')		#Get the "idle" CPU percentage
	RAM_VALUE=$(echo $ALLSTATS | awk '{print $11-$13-$14}')		#Get the actual RAM used (minus buffers and cache)
	LOADAVG_VALUE=$(echo $ALLSTATS | awk '{print $22}')		#Get the 1 min load average

	#CPU usage value checks
	CPU_VALUE=${CPU_VALUE/.*} 											#Remove any decimal points
	[ "$CPU_VALUE" -eq "$CPU_VALUE" ] 2>/dev/null; [ "$?" -eq 0 ] && CPU_VALUE=$((100-$CPU_VALUE)) || CPU_VALUE=0	#Test if it's a number: if so calculate the "used" percentage, else set it to 0

	
	#RAM value checks
	[ "$RAM_VALUE" -eq "$RAM_VALUE" ] 2>/dev/null; [ "$?" -eq 0 ] && RAM_VALUE=$(echo "($RAM_VALUE/$MEMTOTAL)*100" | bc -l);RAM_VALUE=${RAM_VALUE/.*} || RAM_VALUE=0 #Test if it's a number: if so calculate the percentage over the total memory, else set it to 0
	[ "$RAM_VALUE" == "" ] && RAM_VALUE=0	#The last transformation can leave this variable empty so check and set it to 0 if needed.

	#LOADAVG value checks
        LOADAVG_VALUE=${LOADAVG_VALUE/.*}								#Remove any decimal points
	[ "$LOADAVG_VALUE" -eq "$LOADAVG_VALUE" ] 2>/dev/null; [ "$?" -ne 0 ] && LOADAVG_VALUE=0	#Test if it's a number: if not set it to 0

	#Add the new values to each list
	CPU_VALUES_LIST="$CPU_VALUES_LIST $DATE:$CPU_VALUE"
	RAM_VALUES_LIST="$RAM_VALUES_LIST $DATE:$RAM_VALUE"
        LOADAVG_VALUES_LIST="$LOADAVG_VALUES_LIST $DATE:$LOADAVG_VALUE"
	
done

echo
echo "NOTE: Showing stats for up to $DAYSFIXED days"
echo

MSG="** Printing the CPU usage daily average **"
print_stats "$MSG" "$CPU_VALUES_LIST" "1"

echo

MSG="** Printing the 1 min load daily average (CPU core count: $CORES) **"
print_stats "$MSG" "$LOADAVG_VALUES_LIST" "0"

echo

MSG="** Printing RAM actual usage daily average (memotal: $(($MEMTOTAL/1024)) MB) **"
print_stats "$MSG" "$RAM_VALUES_LIST" "1"

exit 0
