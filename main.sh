#!/usr/bin/bash

#declare i
#declare j
#while IFS=: read -r col1 col2 col3
#  do
#  if [ -z "$i" ]; then
#    i=$col1
#  else
#    if [ "$i" == "$col1" ]; then
#      continue
#    else
#      j=$col1
#      echo "$i:$j" >> index-formatted.txt
#      i=""
#      j=""
#    fi
#  fi
#done < enwiki-20200701-pages-articles-multistream-index.txt

while IFS=: read -r si ei
  do
  rm -f temp.bz2
  rm -f temp.xml
  ccount=`expr $ei - $si`

  dd if=enwiki-20200701-pages-articles-multistream.xml.bz2 iflag=skip_bytes,count_bytes skip=$si count=$ccount of=temp.bz2
  ( echo "<content>" ; bunzip2 -c temp.bz2 ; echo "</content>" ) >> temp.xml

  readarray -t ids < <(xmlstarlet sel -t -m "//page" -v "id" -n temp.xml)

  for idx in "${!ids[@]}"; do
    id="${ids[$idx]}"
    title=$(xmlstarlet sel -t -m "//page[id=$id]" -v "title" -n temp.xml)
    coordinates=$(xmlstarlet sel -t -m "//page[id=$id]" -v "*" -n temp.xml | ack -i "\{\{coord.*display=(?!.*inline)" | xargs -I{} ./compiled {})
    if [ -z "$coordinates" ]; then
      continue
    else
      formatted_coordinates=$(echo $coordinates | GeoConvert)
      echo "$id|$title|$formatted_coordinates" >> coords.csv
    fi
  done
  
done < index-formatted.txt
