#! /bin/sh
#Script to get statistics related to specific criteria

echo 'This script extracts timestamp'
echo ''

#Read the input data to process the script further
read -p "Please enter start time in yyyy-mm-dd format: " startDate

startDateLength=${#startDate}

if [ $startDateLength != 10 ]; then
	echo 'Invalid start date. Force exit..'
	exit 1;
fi

read -p "Please enter end time in yyyy-mm-dd format: " endDate

endDateLength=${#endDate}

if [ $endDateLength != 10 ]; then
	echo 'Invalid end date. Force exit..'
	exit 1;
fi

startDateSuffix="T00:00:00.000000Z"
startDateTime=$startDate$startDateSuffix
echo ''

endDateSuffix="T23:59:59.999999Z"
startDateTime=$endDate$endDateSuffix
echo ''

timestamp=`date +"%Y%m%d%H%M%S"`

exportFilePath="/opt/export/"
tempExportFileSuffix=$startDate'_'$endDate'_'$timestamp.csv.in_progress
exportFileSuffix=$startDate'_'$endDate'_'$timestamp.csv
tempExportFile=$exportFilePath$tempExportFileSuffix
exportFile=$exportFilePath$exportFileSuffix

echo -e 'Export file path: '$exportFilePath
echo -e 'Export file name: '$exportFileSuffix

logFilePath="/opt/sample.log"


#Use awk command to extract the statistics from the log file
awk 'substr($0,9,36)>="'$startDateTime'" && substr($0,9,36)<="'$endDateTime'" && /\ Login application/ {print substr($2,1,19)}' $logFilePath > $tempExportFile

echo ''
echo 'Generating CSV file..'

cd $exportFilePath
lookupTempFile=`find . -type f -name "$tempExportFileSuffix"`

if [ "$lookupTempFile" = ""]; then
	echo 'Unable to find temp CSV file. Exiting..'
	exit 1;
else
	#Execute awk command again to replace the occurrences of 'T' & ':' delimiter with a delimiter ;
	awk '{gsub("T|:", ";", $0); print}' $tempExportFile > $exportFile
	lookupFile=`find . -type f -name "$exportFileSuffix"`
	if [ "$lookupFile" = ""]; then	
		echo 'Unable to find CSV file. Exiting..'
		exit 1;
	else
		echo 'Adding headers to CSV file..'
		
		headerFile=$exportFilePath/header.tmp
		echo 'Date;Hour;Minute;Second' > $headerFile
		
		cat $lookupFile >> $headerFile
		cat $headerFile > $lookupFile
		
		rm -f $headerFile
		rm -f $tempExportFile
		
		echo 'CSV file generation successful..'
	fi
fi
