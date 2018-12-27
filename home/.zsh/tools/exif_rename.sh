#!/bin/bash
# 
# Rename images according to their exit ate tags
#
[ -e "sorted" ] && echo "the direcory 'sorted' does already exists. exiting" && exit 1

mkdir sorted

# Collect images
find . -iname "*.jpg" -exec mv {} sorted \;

cd sorted

# Rotate images
jhead -autorot *.jpg

# Rename images according to exif-tag
exiftool -r "-FileName<CreateDate" -d "%Y-%m-%d/%Y_%m_%d_%H_%M_%S.%%e" .

# Movies?
for file in *.MOV; do mv "$file" "${file/.MOV}".mov; done
ls *.m* > /dev/null
if [[ "$?" == 0 ]]; then
  for file in *.mov *.mp4; do 
    creation_date=$(~/Dropbox/Software/ffmpeg/ffmpeg -i "$file" 2>&1 | grep creation_time | head -n 1 | cut -d ":" -f 2,3,4 | sed 's/^//g')
    date=$(echo $creation_date | cut -d " " -f 1 | sed 's/-/_/g')
    dateforfolder=$(echo $creation_date | cut -d " " -f 1)
    time=$(echo $creation_date | cut -d " " -f 2 | sed 's/:/_/g')
    filename="${date}_${time}.mov"
    mkdir $dateforfolder
    echo "mv '$file' $dateforfolder/$filename"
    mv "$file" $dateforfolder/$filename
  done
  #cp -R -v $1/* /Users/Shared/Canon-Fotosync/
fi
