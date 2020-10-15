#!/usr/bin/bash
# select(.labels.en != null) |

# gunzip wikidata-20200817-all.json.bz2 \ 
# 	| jq -r '[.labels.en.value, .claims.P625[0].mainsnak.datavalue.value.latitude, .claims.P625[0].mainsnak.datavalue.value.longitude]'


zcat latest-all.json.gz | jq -cn --stream 'fromstream(1|truncate_stream(inputs))' \
	| jq -c 'select((.labels.en != null) and (.claims.P625 != null)) | jq -cr [.labels.en.value, .claims.P625[0].mainsnak.datavalue.value.latitude, .claims.P625[0].mainsnak.datavalue.value.longitude]'
