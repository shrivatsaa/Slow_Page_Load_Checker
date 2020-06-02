Purpose of the script is to help generate thread dumps for intermittent slow loads of any jira page. It helps avoid the manual process of loading the page from the GUI and switching to run the script from the terminal and missing on some of the timeperiod of issue. This script simulates loading of certain urls by curling it and then generate thread dump at customizable interval if the url load lasts beyond customizable timeperiod in seconds. Additionally it can curl url with variable issuekeys if the url contains a issue key. The different issue keys have to be populated in the data.txt file.

1. Usage : ./curlfile.sh <method> '<url>'  Ex. sh curlfile.sh GET 'http://localhost:8080/browse/SCRUM-1
   Usage : ./curlfile.sh <method> '<url>' 'data' when using put or post method Ex. sh curlfile.sh PUT 'rest/api/2/issue/{issuekey}/comment' '{"body": "This is a comment"}
   Provide the url within quotes so that urls with & in them can be parsed successfully.

2. For curling a url containing issue key with variable issue keys, data.txt needs to be filled in with list of keys. Use a excel sheet to fill in the first issuekey. Then generate a number of them by dragging the cell and copy the generated issue keys to the data.txt file. It can also be manually filled with a set of keys.
3. In case data.txt file is not present or empty or the url does not contain any issue key, the script simply curls the provided url five times and generates thread dumps if there is any delay during any of the loads.
4. flag.props file is a properties file which can be edited for custom sleep interval between thread dumps and usercredentials in the format user:pass and other variables.
