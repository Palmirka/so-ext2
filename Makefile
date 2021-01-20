CC = gcc -fsanitize=address -g
CFLAGS = -Og -Wall -Wextra -Werror

all: ext2fuse ext2test

ext2fs.o: ext2fs.c ext2fs.h ext2fs_defs.h

ext2fuse: ext2fuse.o ext2fs.o
ext2fuse: LDLIBS += $(shell pkg-config --libs fuse)
ext2fuse.o: ext2fuse.c ext2fs.h ext2fs_defs.h
ext2fuse.o: CFLAGS += $(shell pkg-config --cflags fuse)

ext2test: ext2test.o ext2fs.o
ext2test: LDLIBS += -lreadline
ext2test.o: ext2test.c ext2fs.h ext2fs_defs.h

grade:
	./grade.sh

format:
	clang-format -i *.c *.h

clean:
	rm -f *~ *.o ext2fuse ext2test

# vim: ts=8 sw=8 noet
