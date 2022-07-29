#!/bin/bash

event_type="live|rehearsal|soundcheck|audition"

WORK="${1}"

WORK_URL=https://musicbrainz.org/work/$(grep \
  "${WORK}" \
  /home/vzell/.emacs.d/straight/repos/vz-bruce/vz-bruce.el \
  | awk '{ print $1 }' \
  | awk -F'"' '{ print $2 }')

echo "Work URL: ${WORK_URL}"

PAGE=$(wget -O - ${WORK_URL})

echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  > ${HOME}/bruce/works/"${WORK}".work.$(date +"%Y-%d-%m-%H_%M_%S")

echo "==========================================================================================================================="
echo "==========================================================================================================================="
echo "Work: ${WORK}"

echo "==========================================================================================================================="
echo "Checking for wrong title:"
echo "  Bruce:"

echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v "${WORK}" \
  | grep "Bruce Springsteen"

echo "  Others:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v "${WORK}" \
  | grep -v "Bruce Springsteen"

echo "==========================================================================================================================="
echo "Checking for wrong cover information:"

echo "  Bruce with cover information"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep "cover" \
  | grep "Bruce Springsteen"

echo "  Missing cover from Others:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v "Bruce Springsteen" \
  | grep -v "cover"

echo "==========================================================================================================================="
echo "Checking for non-live:"

echo "  Bruce:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v "(live" \
  | grep "Bruce Springsteen"

echo "  Others:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v "(live" \
  | grep -v "Bruce Springsteen"

echo "==========================================================================================================================="
echo "Checking for events with wrong syntax:"

# US, Canada, UK
# live, yyyy-mm-dd: place, city, state, country

# non US, Canada
# live, yyyy-mm-dd: place, city, country

echo "  Bruce:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | grep -v -E "([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})[[:space:]]+${WORK} \((${event_type}), \1: (.*), (.*), (.*)(, (.*))?" \
  | grep "Bruce Springsteen"

echo "  Others:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | grep -v -E "([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})[[:space:]]+${WORK} \((${event_type}), \1: (.*), (.*), (.*)(, (.*))?" \
  | grep -v "Bruce Springsteen"


echo "==========================================================================================================================="
echo "Checking for mismatch in first date column and date spec in disambiguation:"

echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | grep -v -E "([[:digit:]]{4}(-[[:digit:]]{2})?(-[[:digit:]]{2})?).* \((${event_type}), \1:" \
  | grep -E "^[[:digit:]]" \
  | grep -v "(version "


echo "==========================================================================================================================="
echo "Checking for mismatch in live attribut:"

echo "  Bruce:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v -E "${WORK} \((${event_type}).* \1" \
  | grep "Bruce Springsteen"

echo "  Others:"
echo ${PAGE} \
  | w3m -dump -cols 500 -T text/html \
  | awk '/^Recordings/{flag=1;next}/^Work information/{flag=0}flag' \
  | tail -n +4 \
  | grep -v -E "${WORK} \((${event_type}).* \1" \
  | grep -v "Bruce Springsteen"

