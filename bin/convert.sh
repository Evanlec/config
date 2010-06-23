#!/bin/bash
#x=8;

for f in *.* #brooch1.jpg # $(ls | grep \[1-9\]\[0-9\].jpg);

do 
  echo $f
#  ext="${f#*.*}"
#  no_ext="${f%*.*}"

  convert $f -resize 1024 $f

#  thumb_name="${no_ext}-t.$ext";
#  echo "$thumb_name"
#  convert $f -thumbnail 250x250 /home/el/copperbeech/images/$thumb_name

done
exit 0
