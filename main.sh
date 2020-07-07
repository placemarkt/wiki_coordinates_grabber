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
#done < enwiki-20200220-pages-articles-multistream-index.txt

while IFS=: read -r si ei
  do
  rm -f temp.bz2
  rm -f temp.xml
  ccount=`expr si - ei`
  dd if=enwiki-20200220-pages-articles-multistream.xml.bz2 iflag=skip_bytes,count_bytes skip=$si count=$ccount of=temp.bz2
  ( echo "<content>" ; bunzip2 -c temp.bz2 ; echo "</content>" ) >> temp.xml

  while IFS=: read -r col1 col2 col3
  do
    if [ "$si" == "$col1" ]; then
      coordinates=$(xmlstarlet sel -t -m "//page[id=$col2]" -v "*" -n temp.xml | grep "{{Coord")
      if [ -z "$coordinates" ]; then
        continue
      else
        echo "$col2:$col3:$coordinates"
      fi
    else
      break 
    fi
  done < enwiki-20200220-pages-articles-multistream-index.txt
done < index-formatted.txt
