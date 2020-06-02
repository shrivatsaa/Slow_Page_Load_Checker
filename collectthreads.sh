#!/bin/bash

while true
do
  flag1=$(grep "Flag" flag.props | cut -d "=" -f 2);
  if [ "$flag1" = 1 ] ; then
  { 
  	# sleep for a second to read the Flag again to see if it has been unset or not and if the request is for same key
    tdumpdelay=$(grep "delaytostarttdump" flag.props | cut -d "=" -f 2);
    echo "sleeping for $tdumpdelay second to see if the request is still run, before collecting threads\n"
    key1=$(grep "key" flag.props | cut -d "=" -f 2);
  	sleep $tdumpdelay;

    #Read the flag and key again
    flag2=$(grep "Flag" flag.props | cut -d "=" -f 2);
    key2=$(grep "key" flag.props | cut -d "=" -f 2);

    # If the flag has not been unset after a second, trigger jstack to capture the thread dump at 1 second interval
    if [ "$flag2" = 1 ] && [ ${key1} = ${key2} ]; then
    {  
  	    echo "generating thread dump since the delay is more than a second for the curl for key : ${key2}"
        # Delay between each thread dump as read from data.txt
        delay=$(grep "delay" flag.props | cut -d "=" -f 2);
        # Generate thread dump with jstack or kill
        tdumpmethod=$(grep "tdumpmethod" flag.props | cut -d "=" -f 2);
        # Get the process ID
        JIRA_PID=$(ps aux | grep -i jira | grep -i java | awk  -F '[ ]*' '{print $2}');
        if [ "$tdumpmethod" = 'kill' ]; then
        {
          for i in $(seq 6); do kill -3 $JIRA_PID; sleep $delay; done 
          echo "Generated thread dumps are available in the catalina.out file"
        }  
        else
        { 
          for i in $(seq 6); do jstack -l $JIRA_PID > jira_threads_$key2.`date +%s`.txt; sleep $delay; done
        }
        fi  
    }
    else
    {
        echo "moving on since the delay is less than 2 seconds\n" 
    }  
    fi
  }
  fi
done
