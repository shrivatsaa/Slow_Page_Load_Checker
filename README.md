# Slow Page Load Checker

Purpose of the script is to help generate thread dumps for intermittent slow loads of any jira page. It helps avoid the manual process of loading the page from the GUI and switching to run the script from the terminal and missing on some of the timeperiod of issue. This script simulates loading of certain urls by curling it and then generate thread dump at customizable interval if the url load lasts beyond customizable timeperiod in seconds. Additionally it can curl url with variable issuekeys if the url contains a issue key. The different issue keys have to be populated in the data.txt file

## Getting Started

Clone the repository and download the following set of files
1. curlfile.sh
2. collectthreads.sh
3. data.txt
4. flag.props

The readme.txt file has information on what each file can be utilized for

### Prerequisites

The instance should have bash available.

### Installing

git clone https://github.com/shrivatsaa/Slow_Page_Load_Checker

Then run the script as 

```
./curlfile.sh <method> <url> <data>(optional for PUT or POST)
```

Sample Output 1

```
$ ./curlfile.sh GET "http://localhost:8080/browse/SCRUM-1"

curling urls with different issuekeys : http://localhost:8080/browse/$line

Data file is present. Iterating over the keys provided in the data.txt file

curling url : http://localhost:8080/browse/SCRUM-1
sleeping for 2 second to see if the request is still run, before collecting threads

key : SCRUM-1 
http_code: 200 
time_connect:  0.001341s 
time_appconnect:  0.000000s 
Time_Total : 1.455955s

curling url : http://localhost:8080/browse/SCRUM-2
key : SCRUM-2 
http_code: 200 
time_connect:  0.001185s 
time_appconnect:  0.000000s 
Time_Total : 0.139869s

script run completed and thread collection stopped. Exited
```

Sample Output 2

```
$ ./curlfile.sh POST "http://localhost:8080/rest/api/2/issue/SCRUM-1/comment" '{"body": "This is a comment regarding the quality of the response."}'

curling urls with different issuekeys : http://localhost:8080/rest/api/2/issue/$line/comment

Data file is present. Iterating over the keys provided in the data.txt file

curling url : http://localhost:8080/rest/api/2/issue/SCRUM-1/comment
sleeping for 2 second to see if the request is still run, before collecting threads

key : SCRUM-1 
http_code: 201 
time_connect:  0.001174s 
time_appconnect:  0.000000s 
Time_Total : 0.804962s

curling url : http://localhost:8080/rest/api/2/issue/SCRUM-2/comment
key : SCRUM-2 
http_code: 201 
time_connect:  0.001025s 
time_appconnect:  0.000000s 
Time_Total : 0.130156s

script run completed and thread collection stopped. Exited
```