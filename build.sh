#! /bin/bash

xfbuild +xcore +xstd +xetc \
+full +redeps \
-gc -debug \
-L-lespeak \
$@ dspeak.d \
+o=dspeak.a
