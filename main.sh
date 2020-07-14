#!/usr/bin/bash

function write_coords() {
  coordinates=$(xmlstarlet sel -t -m "//page[id=$1]" -v "*" -n temp.xml | ack -wi "\{\{coord.*display=(?!.*inline)")
  if [ -z "$coordinates" ]; then
    return;
  else
    formatted_coordinates=$(echo $coordinates | xargs -I{} ./compiled {} | GeoConvert)
    echo "$1|$2|$formatted_coordinates" >> coords.csv
  fi
}

export -f write_coords
function get_location_articles() {
  declare i
  declare j
  declare idarr
  declare titlearr

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

        parallel --will-cite --link --jobs 0 write_coords ::: "${idarr[@]}" ::: "${titlearr[@]}"

        i=""
        j=""
        idarr=("")
        titlearr=("")
      fi
    fi
  done < enwiki-20200220-pages-articles-multistream-index.txt
}

get_location_articles
