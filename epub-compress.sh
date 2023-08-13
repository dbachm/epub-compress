#! /bin/sh
# params
EBOOK_ROOT_FOLDER=/Volumes/Daten\ HD/Google\ Drive/EBook/
# start script with -v to enable verbose mode
verbose="$1"

# helper fn for error handling
check_error()
{
  msg=$1
  retVal=$2
  if [ $retVal -ne 0 ] ; then
    echo "ERROR: $msg (returned $retVal)"
    exit $retVal
  fi
}


#temporarily disable internal field separator
IFS=$'\n'; set -f
spath=`pwd`

# look for each ebook in ebook root folder
# params: -size +3M -> larger than 3MB

for fpath in $(find $EBOOK_ROOT_FOLDER -type f -size +3M -name '*.epub');
do
  dir=`dirname "$fpath"`
  if [ -f $dir/.epub_compressed ]; then
    continue
  fi
  if [ -f $dir/.epub_compression_skipped ]; then
    continue
  fi
  file=`basename "$fpath"` 
  echo $file
  cd "$spath"
  mkdir -p source
  cp $fpath $spath/source
  rm -rf "tmp/$fpath"
  mkdir -p "tmp/$fpath"
  par=-qX
  if [ "$verbose" = "-v" ] ; then
    par=-X
  fi
  unzip $par "$fpath" -d "tmp/$fpath"
  check_error "unzip" $?
  pngcount=`find "tmp/$fpath" -type f -name '*.png' |wc -l`
  par=
  if [ "$verbose" = "-v" ] ; then
    par=-verbose
  fi
  if [ $pngcount -ne 0 ]; then
    echo "start converting pngs to jpgs (todo: $pngcount) ..."
    find "tmp/$fpath" -type f -name '*.png' -execdir sh -c "mogrify $par -format jpg {}" \;
    check_error "find #1" $?
    find "tmp/$fpath" -type f -name '*.png' -delete
    check_error "find #2" $?
  fi
  find "tmp/$fpath" -type f -name '*.jpg' -execdir sh -c "mogrify $par -quality 50 {}" \;
  check_error "find #3" $?
  
  echo "(1) img compression done"
  if [ $pngcount -ne 0 ] ; then
    find "tmp/$fpath" -type f -name '*.opf' -exec sed -i '' 's/\.png/\.jpg/g;s/image\/png/image\/jpeg/g' {} \;
    check_error "sed #0" $?
    find "tmp/$fpath" -type f -name '*.xhtml' -exec sed -i '' 's/\.png/\.jpg/g;s/image\/png/image\/jpeg/g' {} \;
    check_error "sed #1" $?
    echo "(2) rename png-links in epub done"
  fi 
  if [ -r tmp/$fpath/mimetype ]; then
    echo "mimetype exists and is readable"
  else
    echo "not sure why mimetype has no permission, need to update chmod"
    sudo chmod +r tmp/$fpath/mimetype
  fi
 
  par=-qX
  if [ "$verbose" = "-v" ] ; then
    par=-X
  fi
  zip $par "target/$file" tmp/$fpath/mimetype
  check_error "zip #0" $?
  par=-rq
  if [ "$verbose" = "-v" ] ; then
    par=-r
  fi
  zip $par "target/$file" tmp/$fpath -x \*.DS_Store -x \*mimetype
  check_error "zip #1" $?

  ssize=`stat -f%z "source/$file"`
  ssize_h=`du -h "source/$file"`
  tsize=`stat -f%z "target/$file"`
  tsize_h=`du -h "target/$file"`
  ratio=`bc <<<"100*$tsize/$ssize"`
  echo "(3) zipping done"
  if [ $tsize \< $ssize ]; then
    mv "target/$file" "$fpath"
    echo "updated book"
    echo "$ssize_h -> "
    echo "$tsize_h (calculated compression ratio: $ratio %)"
    touch "$dir/.epub_compressed"
  else
    echo "skipping book, because manipulated epub is larger than the source epub (bad compression ratio: $ratio %)"
    rm "target/$file"
    touch "$dir/.epub_compression_skipped"
  fi
  rm -rf "$spath/tmp"
done
unset IFS; set +f


