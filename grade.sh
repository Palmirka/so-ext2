#!/bin/sh

IMAGE=debian9-ext2

if [ -d "/__w" ]; then
  ln -s /$IMAGE.img $IMAGE.img
  ln -s /$IMAGE.kern.log $IMAGE.kern.log
fi

mkdir -p test
(./ext2fuse test || echo "ext2fuse failed!")&
sleep 1 # TODO: how to correctly synchronize with ext2fuse ?
./listfs test | sort > $IMAGE.user.log
diff -U 0 $IMAGE.kern.log $IMAGE.user.log | \
  wdiff -d - | sed -e '1d;/^@@/d' > $IMAGE.log.diff
if [ -s $IMAGE.log.diff ]; then
  echo "First 100 differences:"
  head -n 100 $IMAGE.log.diff
fi
INCORRECT=$(cat $IMAGE.log.diff | wc -l)
ALL=$(cat $IMAGE.kern.log | wc -l)
echo "\nIncorrect files: $INCORRECT/$ALL"
fusermount -u test
