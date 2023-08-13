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

On errors, the script will exit.
A copy of the original epub is always stored in the folder:
```
<script_path>/source

```

# Preparations before first run 
Edit path of the epub root folder (e.g. your calibre library), e.g.
```
EBOOK_ROOT_FOLDER=/Volumes/My\ Drive/EBooks/

```

# How to run
```
sh epub-compress.sh
```
