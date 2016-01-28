T-Engine is distributed with the following software implementation of OpenAL:
OpenAL Soft: http://kcat.strangesoft.net/openal.html

  If you would like to use your system's OpenAL implementation instead, simply
delete or rename the OpenAL32.dll file in your T-Engine directory.  If T-Engine
refuses to run after renaming or deleting this file, your system does not
provide an OpenAL implementation and you must use the OpenAL32.dll provided
in the T-Engine distribution.

Build info:
--------------------------
Cross-built using i686-w64-mingw32-gcc (GCC) 4.9.1

library       rev       linking
SDL2          hg-8038   S
SDL2_image    hg-435    S
SDL2_ttf      hg-260    S
zlib          1.2.8     S
libpng        1.6.20    S
freetype      2.6.2     S
libogg        1.3.2     S
libvorbis     1.3.5     S
OpenAL Soft   1.15.1    D
