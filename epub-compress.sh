#! /bin/sh
# params
# ebook root folder
EBOOK_ROOT_FOLDER=/Volumes/Daten\ HD/Google\ Drive/EBook/
# min compression ratio (%), everything above will be skipped
MIN_COMPRESSION_RATIO=91
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
#statistics
stat_c=0
stat_s=0

# look for each ebook in ebook root folder
# params: -size +3M -> larger than 3MB

for fpath in $(find $EBOOK_ROOT_FOLDER -type f -size +3M -name '*.epub');
do
  cd "$spath"
  dir=`dirname "$fpath"`
  file=`basename "$fpath"` 
  if [ -f $dir/.epub_compression_skipped ]; then
    stat_s=$((stat_s+1))
    if [ "$verbose" = "-v" ] ; then
      echo "skipping $file (epub already handled=skipped before)"
    fi
    continue
  fi
  if [ -f $dir/.epub_compressed ]; then
    stat_c=$((stat_c+1))
    if [ "$verbose" = "-v" ] ; then
      echo "skipping $file (epub already handled=compressed before)"
    fi
    continue
  fi
  echo "START: reading epub $file"
  if [ "$verbose" = "-v" ] ; then
    echo "Source: $fpath"
  fi
  mkdir -p source
  cp $fpath $spath/source
  check_error "cp" $?
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
    if [ "$verbose" = "-v" ] ; then
      echo "start converting pngs to jpgs (todo: $pngcount) ..."
    fi
    find "tmp/$fpath" -type f -name '*.png' -execdir sh -c "mogrify $par -format jpg {}" \;
    check_error "find #1" $?
    find "tmp/$fpath" -type f -name '*.png' -delete
    check_error "find #2" $?
  fi
  find "tmp/$fpath" -type f -name '*.jpg' -execdir sh -c "mogrify $par -quality 50 {}" \;
  check_error "find #3" $?
  
  if [ "$verbose" = "-v" ] ; then
    echo "(1) img compression done"
  fi
  if [ $pngcount -ne 0 ] ; then
    find "tmp/$fpath" -type f -name '*.opf' -exec sed -i '' 's/\.png/\.jpg/g;s/image\/png/image\/jpeg/g' {} \;
    check_error "sed #0" $?
    find "tmp/$fpath" -type f -name '*.xhtml' -exec sed -i '' 's/\.png/\.jpg/g;s/image\/png/image\/jpeg/g' {} \;
    check_error "sed #1" $?
    if [ "$verbose" = "-v" ] ; then
      echo "(2) rename png-links in epub done"
    fi
  fi 
  if [ -r tmp/$fpath/mimetype ]; then
    if [ "$verbose" = "-v" ] ; then
      echo "mimetype exists and is readable"
    fi
  else
    echo "mimetype in epub has no read permission, need to sudo password to give read access"
    sudo chmod +r tmp/$fpath/mimetype
    sudo chmod -R +r tmp/$fpath
  fi
 
  par=-qX
  if [ "$verbose" = "-v" ] ; then
    par=-X
  fi
  cd tmp/$fpath
  mkdir -p "$spath/target"
  zip $par "$spath/target/$file" mimetype
  check_error "zip #0" $?
  par=-rq
  if [ "$verbose" = "-v" ] ; then
    par=-r
  fi
  zip $par "$spath/target/$file" . -x \*.DS_Store -x \*mimetype
  check_error "zip #1" $?
  cd $spath
  ssize=`stat -f%z "source/$file"`
  ssize_h=`du -h "source/$file"`
  tsize=`stat -f%z "target/$file"`
  tsize_h=`du -h "target/$file"`
  ratio=`bc <<<"100*$tsize/$ssize"`
  if [ "$verbose" = "-v" ] ; then
    echo "(3) zipping done"
  fi
  if [ $ratio -lt $MIN_COMPRESSION_RATIO ]; then
    mv "target/$file" "$fpath"
    echo "$ssize_h -> "
    echo "$tsize_h (compressed epub with compression ratio: $ratio %)"
    touch "$dir/.epub_compressed"
    stat_c=$((stat_c+1))
  else
    echo "skipping book, because compressed epub is larger than the source epub (bad compression ratio: $ratio %)"
    if [ "$verbose" = "-v" ] ; then
      echo "$ssize_h -> "
      echo "$tsize_h (compressed epub with compression ratio: $ratio %)"
    fi
    rm "target/$file"
    touch "$dir/.epub_compression_skipped"
    stat_s=$((stat_s+1))
  fi
  rm -rf "$spath/tmp"
done
echo "Summary: no of skipped epubs    $stat_s"
echo "         no of compressed epubs $stat_c"

unset IFS; set +f

