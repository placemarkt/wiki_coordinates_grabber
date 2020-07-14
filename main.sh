#!/usr/bin/bash

# performance ideas
#    - cut larger parts of multistream bz2 file
#    - move idx loop inside index-formatting loop to remove reads/writes from disk
#    - don't search in XML for id or title because you already have this information

declare i
declare j
declare idarr
declare titlearr

function write_coords() {
  coordinates=$(xmlstarlet sel -t -m "//page[id=$1]" -v "*" -n temp.xml | ack -i "\{\{coord.*display=(?!.*inline)" | xargs -I{} ./compiled {})
  if [ -z "$coordinates" ]; then
    return;
  else
    formatted_coordinates=$(echo $coordinates | GeoConvert)
    echo "$1|$2|$formatted_coordinates" >> coords.csv
  fi
}

while IFS=: read -r col1 col2 col3
  do
  if [ -z "$i" ]; then
    i=$col1
    idarr=("$col2")
    titlearr=("$col3")
  else
    if [ "$i" == "$col1" ]; then
      idarr=("${idarr[@]}" "$col2")
      titlearr=("${titlearr[@]}" "$col3")

      continue
    else
      j=$col1
      idarr=("${idarr[@]}" "$col2")
      titlearr=("${titlearr[@]}" "$col3")

      rm -f temp.bz2
      rm -f temp.xml       
      ccount=`expr $j - $i`

      dd if=enwiki-20200220-pages-articles-multistream.xml.bz2 iflag=skip_bytes,count_bytes skip=$i count=$ccount of=temp.bz2
      ( echo "<content>" ; bunzip2 -c temp.bz2 ; echo "</content>" ) >> temp.xml

      N=1024
      for idx in "${!idarr[@]}"; do
        ((i=i%N)); ((i++==0)) && wait
        id="${idarr[$idx]}"
        title="${titlearr[$idx]}"
        write_coords $id $title &
      done

      i=""
      j=""
      idarr=("")
      titlearr=("")
    fi
  fi
done < enwiki-20200220-pages-articles-multistream-index.txt
