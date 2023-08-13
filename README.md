# epub-compress
compresses epubs (replaces pngs with jpgs, replaces png-links in text and compresses all jpgs)

Note: only tested in terminal on macOS (v10.14).
Use at your own risk!

# How the script works
Loops trough epub library and tries to compress each epub.
If the compressed epub is smaller than the original, overwrite the source file,
else skip it.
When done, write a hidden file next to the epub:
```
.epub_compressed (if the epub was compressed)

```
or
```
.epub_compression_skipped (if the epub was skipped)

```

On errors, the script will exit (and tmp folder is not removed to help debugging),
also see [Known errors](#known-errors).
A copy of the original epub is always stored in the folder:
```
<script_path>/source/

```

# Preparations before first run 
Edit path of the epub root folder (e.g. your calibre library), e.g.
```
EBOOK_ROOT_FOLDER=/Volumes/My\ Drive/EBooks/

```

# Config
You can change the minimal compression ratio (%), everything above will be skipped.
```
MIN_COMPRESSION_RATIO=91

```
100 means the compressed file has the same size as the original,
50 means the compressed file has half the size as the original.


# How to run
```
sh epub-compress.sh
```
or
```
sh epub-compress.sh -v (for verbose output)
```

# Known errors
```
ERROR: unzip (returned 9)
```
or
```
ERROR: unzip (returned 2)
```
Check epub with calibre (edit Book), fix errors there and save book, try again (which fixed it for me).

Note: if calibre throws errors opening the (source) book, maybe the epub is not correctly zipped,
rezipping it manually sometimes helps, epub has to be in the following structure (mimetype needs to be first file in archive and uncompressed):
```
Archive:     <epub-name>.epub
 extracting: mimetype                
   creating: META-INF/
  inflating: META-INF/container.xml  
   creating: OEBPS/
   creating: OEBPS/xhtml/
...
```


sometimes it can be fixed manually be zipping it with fixed folder structures:
Archive:  test.zip
 extracting: mimetype                
   creating: META-INF/
  inflating: META-INF/container.xml  
   creating: OEBPS/
   creating: OEBPS/xhtml/
