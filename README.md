sysstat_graph README
====================

General Description
-------------------

This simple bash script graphs the statistics from sar files using hash signs "#".
The information is extracted using the "sar" command and using grep to get the "Average" output line.

Right now it graphs:

* CPU usage (Daily average - this calculated as 100 - Idle CPU percentage)
* Load average (Daily 1 min load average average)
* Actual RAM usage (Daily average of the actual RAM usage - minus buffers and cache)

Usage
-----

You can simply run it on a server where sysstat is installed and gathering statistics. The script has some basic environment variables that tune its behaviour:

SARDIR="/var/log/sa/"	: the location of the sysstat files
SAR="/usr/bin/sar"	: the location of the "sar" executable            
DAYS="30"		: how many days (files essentially) will the script attempt to grab from the sysstat directory

Example Output
--------------

	NOTE: Showing stats for up to 30 days
	
	** Printing the CPU usage daily average **
	
	2013-12-24 : (51%)  ###################################################
	2013-12-25 : (47%)  ###############################################
	2013-12-26 : (53%)  #####################################################
	2013-12-27 : (55%)  #######################################################
	2013-12-28 : (49%)  #################################################
	2013-12-29 : (47%)  ###############################################
	2013-12-30 : (56%)  ########################################################
	2013-12-31 : (54%)  ######################################################
	2014-01-01 : (48%)  ################################################
	2014-01-02 : (57%)  #########################################################
	2014-01-03 : (56%)  ########################################################
	2014-01-04 : (48%)  ################################################
	
	** Printing the 1 min load daily average (CPU core count: 12) **
	
	2013-12-24 : (9)   #########
	2013-12-25 : (9)   #########
	2013-12-26 : (10)  ##########
	2013-12-27 : (11)  ###########
	2013-12-28 : (8)   ########
	2013-12-29 : (8)   ########
	2013-12-30 : (12)  ############
	2013-12-31 : (11)  ###########
	2014-01-01 : (9)   #########
	2014-01-02 : (13)  #############
	2014-01-03 : (12)  ############
	2014-01-04 : (8)   ########
	
	** Printing RAM actual usage daily average (memotal: 36135 MB) **
	
	2013-12-24 : (48%)  ################################################
	2013-12-25 : (49%)  #################################################
	2013-12-26 : (50%)  ##################################################
	2013-12-27 : (50%)  ##################################################
	2013-12-28 : (47%)  ###############################################
	2013-12-29 : (47%)  ###############################################
	2013-12-30 : (49%)  #################################################
	2013-12-31 : (48%)  ################################################
	2014-01-01 : (48%)  ################################################
	2014-01-02 : (49%)  #################################################
	2014-01-03 : (48%)  ################################################
	2014-01-04 : (47%)  ###############################################
		
Author
------

Kostas Georgakopoulos (kostas.georgakopoulos@gmail.com)

When was this originaly created
-------------------------------

* 14/12/2013
