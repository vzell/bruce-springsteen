#!/bin/bash

#result_entity_type=release-group
#result_entity_type=release
#result_entity_type=work
#result_entity_type=recording
#result_entity_type=event

result_entity_type=$1

# /<RESULT_ENTITY_TYPE>?<BROWSING_ENTITY_TYPE>=<MBID>&limit=<LIMIT>&offset=<OFFSET>&inc=<INC>

user_agent="BruceSpringsteenRelated/0.9.0 ( info@volkerzell.de )"
bruce_mbid=70248960-cb53-4ea4-943a-edb18f7d336f
api_root_url=https://musicbrainz.org/ws/2
browsing_entity_type=artist
mbid=${bruce_mbid}
limit=100
offset=0
page_number=1
lines=0

result_entity_type_file=~/bruce/$(date "+%Y-%m-%d_%H-%M-%S")-${result_entity_type}
result_entity_type_file_title=${result_entity_type_file}_title

case "${result_entity_type}" in
    event) entity_name=name ;;
        *) entity_name=title ;;
esac

entity_xpath="/metadata/${result_entity_type}-list/${result_entity_type}/${entity_name}"


echo '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">' \
     > ${result_entity_type_file}

page=$(curl \
           -s \
           -A "${user_agent}" \
           "${api_root_url}/${result_entity_type}?${browsing_entity_type}=${mbid}")

lines_total=$(echo ${page} | sed -e "s/xmlns/ignore/" | xmllint --xpath "string(/metadata/${result_entity_type}-list/@count)" -)
echo "Total line count: ${lines_total}"

while [ ${lines} -lt ${lines_total} ]; do
    page=$(curl \
               -s \
               -A "${user_agent}" \
               "${api_root_url}/${result_entity_type}?${browsing_entity_type}=${mbid}&limit=${limit}&offset=${offset}")
    echo ${page} \
        | xmllint --format - \
	| tail -n +3 \
	| head -n -1 \
         >> ${result_entity_type_file}

    lines_in_page=$(echo ${page} \
                      | sed -e "s/xmlns/ignore/" \
                      | xmllint --xpath "count(${entity_xpath})" -)

    # TODO: replace &amp;
    echo $page \
        | sed -e "s/xmlns/ignore/" \
        | xmllint --xpath "${entity_xpath}/text()" - \
        | sed -e "s/\&amp;/\&/" \
        | tee -a ${result_entity_type_file_title}

    lines=$(($lines + $lines_in_page))
    echo "${lines_in_page} lines in page ${page_number} - Total lines ${lines} out of ${lines_total}"
    page_number=$(($page_number + 1))
    offset=$lines

    sleep 1
done

echo '</metadata>' \
     >> ${result_entity_type_file}

# sorting

sort -u ${result_entity_type_file_title} > ${result_entity_type_file_title}.unique
