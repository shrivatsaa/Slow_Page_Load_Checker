#!/bin/bash

red=$'\e[1;31m'
green=$'\e[1;32m'
blue=$'\e[1;34m'
white=$'\e[0m'
magenta=$'\e[1;35m'
cyan=$'\e[1;36m'

if [[ "$OSTYPE" = "linux-gnu"* ]]; then 
  sedvar='-e'
elif [[ "$OSTYPE" = "darwin"* ]]; then
  sedvar=''
else
  sedvar='-e'
fi

resetflags()
{
  if [[ -f flag.props ]] ; then {
    sed -i "$sedvar" "s/Flag=.*/Flag=0/g" flag.props > /dev/null
    sed -i "$sedvar" "s/key=.*/key={}/g" flag.props > /dev/null
  }
  else {
    echo -e ${red}'Run the script after downloading the flag.props properties file and configuring it'${white}
    exit
  }
  fi
}

removeemptylines()
{
  if [[ -f data.txt ]] ; then {
    sed -i "$sedvar" '/^$/d' data.txt > /dev/null
  }
  fi
}
# verify and reset the properties file
resetflags
removeemptylines

# Validate the method
if [[ $1 != "" ]] && [[ $1 = 'GET' ]] || [[ $1 = 'POST' ]] || [[ $1 = 'DELETE' ]] || [[ $1 = 'PUT' ]]; then {
method=$1
data="{}"
}
else 
{
  echo -e $blue'usage : Run the script as curlfile.sh <method> <url> with the url enclosed in single quotes\n'$white
  echo -e $green'Ex. ./curlfile.sh GET "'http://localhost:8080/browse/SCRUM-1'"\n'$white
  exit
}
fi

#validate the data for POST/PUT methods
if [[ $method = 'PUT' ]] || [[ $method = 'POST' ]]; then {
  if [[ $3 != "" ]]; then {
    data=$3 
  }
else {
  echo -e $red'POST/PUT method requires data input'$white
  echo -e $blue'usage : Run the script as curlfile.sh <method> <url> <data> with the url and also data enclosed in single quotes'$white
  echo -e $green'Ex. ./curlfile.sh PUT "rest/api/2/issue/issuekey/comment" '{\"body\": \"This is a comment regarding the quality of the response.\"}'\n'$white
  exit
  }
  fi
}
fi

# Validate the url
url=$2
if [[ $url != "" ]] && [[ $url = http* ]]; then {
    if [[ $url =~ \/[A-Za-z0-9_]*-[0-9]* ]] || [[ $url =~ \=[A-Za-z0-9_]*-[0-9]* ]] && [[ -f data.txt ]] && [[ -s data.txt ]]; then {
      curlme1=$(echo $url | sed -e "s/&/\'&\'/g" -e 's/[A-Za-z0-9_]*-[0-9]*/$line/g');
      echo -e $magenta"\ncurling urls with different issuekeys : ${curlme1}"$white
    }
    else {
      curlme2=$(echo $url | sed -e "s/&/\'&\'/g");
    }
    fi
  }
  else
    {
  echo -e $blue'usage : Run the script as curlfile.sh <method> <url> with the url enclosed in single quotes\n'$white    
  echo -e $green'Ex. ./curlfile.sh GET "http://localhost:8080/browse/SCRUM-1" \n'$white
  exit
}
fi 

# Get the user credentials
usercred=$(grep "usercred" flag.props | cut -d "=" -f 2);

# Start the thread collection script in the background
/bin/sh collectthreads.sh &       	
# Kill the background thread collection if script abruptly stopped with ctrl+C 
trap "pkill -f collectthreads.sh &" SIGINT

if [[ $curlme1 != "" ]]; then
{
  echo -e $cyan'\nData file is present. Iterating over the keys provided in the data.txt file\n'$white
  while read -r line
  do
    # set the flag to 1 and the issuekey so that curl command for the issue can start	
    sed -i "$sedvar" "s/Flag=.*/Flag=1/g" flag.props > /dev/null
    sed -i "$sedvar" "s/key=.*/key=$line/g" flag.props > /dev/null
    # Run the curl command to load issue after expanding the variable
    curlurl=$(eval echo $curlme1);
    echo -e $green"curling url : $curlurl"$white
    curl -s  -w "key : $line \nhttp_code: %{http_code} \ntime_connect:  %{time_connect}s \ntime_appconnect:  %{time_appconnect}s \nTime_Total : %{time_total}s\n\n" -u $usercred -X $method ${curlurl} --data "$data" -H "Content-Type: application/json" -o /dev/null;
    # Unset the flag to start over for the next issue
    sed -i "$sedvar" "s/Flag=.*/Flag=0/g" flag.props > /dev/null
  done < data.txt
  #unset the key for a new run.
  sed -i "$sedvar" "s/key=.*/key={}/g" flag.props > /dev/null 
}
else
# since there is no issuekey or project key variable from data file we will iterate on the single url for 5 times and collect threads if its slow.
{
  echo -e $cyan'\nNo data in data file is present or url has no variable issuekey. Iterating over the provided single url for 5 times \n'$white
  decimal=$(grep "decimal" flag.props | cut -d "=" -f 2);
  for temp in $(seq $decimal);
  do
    # set the flag to 1 and the issuekey so that curl command for the issue can start 
    sed -i "$sedvar" "s/Flag=.*/Flag=1/g" flag.props > /dev/null
    sed -i "$sedvar" "s/key=.*/key=$temp/g" flag.props > /dev/null
    # Run the curl command to load issue
    echo -e $green"curling url : $curlme2"$white
    curl -s  -w "Iteration : $temp \nhttp_code: %{http_code} \ntime_connect:  %{time_connect}s \ntime_appconnect:  %{time_appconnect}s \nTime_Total : %{time_total}s\n\n" -u $usercred -X $method $curlme2 --data "$data" -H "Content-Type: application/json" -o /dev/null ;
    # Unset the flag to start over for the next issue
    sed -i "$sedvar" "s/Flag=.*/Flag=0/g" flag.props > /dev/null
  done
  #unset the key for a new run.
sed -i "$sedvar" "s/key=.*/key={}/g" flag.props > /dev/null 
}
fi

# Kill the perpetual collect thread script since no more curl is being run
pkill -f collectthreads.sh &
echo -e $green'script run completed and thread collection stopped. Exited\n'$white
