# magick: set the correct path to libMagickCore.dylib 
install_name_tool -change \
    /ImageMagick-7.0.10/lib/libMagickCore-7.Q16HDRI.8.dylib \
    @executable_path/../lib/libMagickCore-7.Q16HDRI.8.dylib \
    /Users/dba/tools/ImageMagick-7.0.10/bin/magick

# magick: set the correct path to libMagickWand.dylib 
install_name_tool -change \
    /ImageMagick-7.0.10/lib/libMagickWand-7.Q16HDRI.8.dylib \
    @executable_path/../lib/libMagickWand-7.Q16HDRI.8.dylib \
    /Users/dba/tools/ImageMagick-7.0.10/bin/magick

# libMagickWand.dylib: set the correct ID
install_name_tool -id \
    @executable_path/../lib/libMagickWand-7.Q16HDRI.8.dylib \
    /Users/dba/tools/ImageMagick-7.0.10/lib/libMagickWand-7.Q16HDRI.8.dylib

# libMagickWand.dylib: set the correct path
install_name_tool -change \
    /ImageMagick-7.0.10/lib/libMagickCore-7.Q16HDRI.8.dylib \
    @executable_path/../lib/libMagickCore-7.Q16HDRI.8.dylib \
    /Users/dba/tools/ImageMagick-7.0.10/lib/libMagickWand-7.Q16HDRI.8.dylib

# libMagickCore.dylib: set the correct ID
install_name_tool -id \
    @executable_path/../lib/libMagickCore-7.Q16HDRI.8.dylib \
    /Users/dba/tools/ImageMagick-7.0.10/lib/libMagickCore-7.Q16HDRI.8.dylib
