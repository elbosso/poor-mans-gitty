#!/bin/bash

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

remove_quotes()
{
  temp="${1%\"}"
  temp="${temp#\"}"
  echo "${temp}"    # You can either set a return variable (FASTER) 
  REPLY="${temp}"   #+or echo the result (EASIER)... or both... :p
}
usage()
{
    echo "usage: workWithGitlab.sh -h host  -p projectid  -x token -a action [ -n max_number_of_results ] | [-?]"
    echo "valid operations:"
    echo "    - issues"
    echo "    - commits"
    echo "    - branches"
    echo "    - pipelines"
    echo "    - milestones"
    echo "    - merge_requests"
    echo "    - tags"
    echo "    - releases"
    echo "    - commits_since_last_release"
    echo "    - commits_since_last_tag"
}

#http://linuxcommand.org/lc3_wss0120.php
while [ "$1" != "" ]; do
    case $1 in
        -h | --host )           shift
                                HOST="$1"
                                ;;
        -p | --projectid )      shift
                                PROJECTID="$1"
                                ;;
        -x | --token )          shift
                                PRIVATETOKEN="$1"
                                ;;
        -a | --action )         shift
                                ACTION="$1"
                                ;;
        -n | --max_number_of_results )         shift
                                MAX_NUMBER_OF_RESULTS="$1"
                                ;;
        -? | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

CURL_OPTIONS=(-k --silent --location)

REMOTE_ORIGIN_URL=$(git config --get remote.origin.url)
#echo "$REMOTE_ORIGIN_URL"
REMOTE_HOST=$(echo "$REMOTE_ORIGIN_URL"|cut -d '/' -f 3)
#echo "$REMOTE_HOST"
REMOTE_PROJECT=$(echo "$REMOTE_ORIGIN_URL"|cut -d '/' -f 5|cut -d '.' -f 1)
#echo "$REMOTE_PROJECT"

if [ -z "${HOST+x}" ]; then 
if [ -n "${REMOTE_HOST}" ]; then 
HOST=$REMOTE_HOST
else
echo "Error: host is unset" && exit 2; 
fi
fi

if [ -z "${ACTION+x}" ]; then echo "Error: action is unset" && exit 2; fi
if [ -z "${PRIVATETOKEN+x}" ]; then 
if [ -n "${GITLAB_ACCESS_TOKEN+x}" ]; then 
PRIVATETOKEN=$GITLAB_ACCESS_TOKEN
else
echo "Error: token is unset" && exit 2; 
fi
fi

if [ -z "${PROJECTID+x}" ]; then 
if [ -n "${REMOTE_PROJECT}" ]; then 
QUOTED_PROJECTID=$(curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects?search=$REMOTE_PROJECT" | jq '.[] | .id')
#echo "$QUOTED_PROJECTID"
if [ -n "${QUOTED_PROJECTID}" ]; then
PROJECTID=$( remove_quotes "$QUOTED_PROJECTID" )
else
echo "Error: cannot determine projectid" && exit 2;
fi
else
echo "Error: projectid is unset" && exit 2;
fi
fi

#echo "$PROJECTID"

if [ -z "${MAX_NUMBER_OF_RESULTS+x}" ]; then 
MAX_NUMBER_OF_RESULTS=5
fi

case $ACTION in
	issues )
#https://docs.gitlab.com/ee/api/issues.html
#issues |jq '.[] | {id,title, description}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/issues?per_page=$MAX_NUMBER_OF_RESULTS&state=closed&sort=desc&order_by=created_at&scope=all" \
|jq '.[] | {id,title, description}'
;;
	commits )
#https://docs.gitlab.com/ee/api/commits.html
#commits |jq '.[] | {short_id, message, author_name_authored_date, web_url}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/repository/commits?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[] | {short_id, message, author_name_authored_date, web_url}'
;;
	pipelines )
#https://docs.gitlab.com/ee/api/pipelines.html
#pipelines |jq '.[] | {id,status,web_url}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/pipelines?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[] | {id,status,web_url}'
;;
	branches )
#https://docs.gitlab.com/ee/api/branches.html
#branches |jq '.[] | {name,default,merged,web_url}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/repository/branches?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[] | {name,default,merged,web_url}'
;;
	milestones )
#https://docs.gitlab.com/ee/api/milestones.html
#milestones |jq '.[] | {id,title,description,due_date,web_url}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/milestones?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[] | {id,title,description,due_date,web_url}'
;;
	merge_requests )
#https://docs.gitlab.com/ee/api/merge_requests.html
#merge requests |jq '.[] | {id, title, description,state,merge_status,web_url}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/merge_requests?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[] | {id, title, description,state,merge_status,web_url}'
;;
	tags )
#https://docs.gitlab.com/ee/api/tags.html
#tags |jq '.[0] | {name: .name, message: .message, "commit": .commit.id, "date": .commit.created_at}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/repository/tags?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[0] | {name: .name, message: .message, "commit": .commit.id, "date": .commit.created_at}'
;;
	releases )
#https://docs.gitlab.com/ee/api/releases/
#releases |jq '.[0] | {name,description,released_at}'
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/releases?per_page=$MAX_NUMBER_OF_RESULTS" \
|jq '.[0] | {name,description,released_at}'
;;
	commits_since_last_release )
#commits after last release
RELEASE_TIMESTAMP=$(curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/releases?per_page=1"|jq '.[0] | .released_at')
RELEASE_TIMESTAMP=$( remove_quotes "$RELEASE_TIMESTAMP" )
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/repository/commits?per_page=$MAX_NUMBER_OF_RESULTS&since=$RELEASE_TIMESTAMP" \
|jq '.[] | {short_id, message, author_name,authored_date, web_url}'
;;

	commits_since_last_tag )
#commits after last tag
RELEASE_TIMESTAMP=$(curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/repository/tags?per_page=1"|jq '.[0] | .commit.created_at')
RELEASE_TIMESTAMP=$( remove_quotes "$RELEASE_TIMESTAMP" )
curl "${CURL_OPTIONS[@]}" --request GET --header "PRIVATE-TOKEN: $PRIVATETOKEN" "http://$HOST/api/v4/projects/$PROJECTID/repository/commits?per_page=$MAX_NUMBER_OF_RESULTS&since=$RELEASE_TIMESTAMP" \
|jq '.[] | {short_id, message, author_name,authored_date, web_url}'
;;

esac






