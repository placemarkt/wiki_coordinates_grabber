#!/usr/bin/bash
# select(.labels.en != null) |

bzip2 -d wikidata-20200817-all.json.bz2 \ 
	| jq -r '[.labels.en.value, .claims.P625[0].mainsnak.datavalue.value.latitude, .claims.P625[0].mainsnak.datavalue.value.longitude]'
