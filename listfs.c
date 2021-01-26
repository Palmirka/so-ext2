#define _XOPEN_SOURCE 500
#define _GNU_SOURCE
#include <ftw.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdnoreturn.h>
#include <limits.h>
#include <unistd.h>

#include "md5.h"

static noreturn void die(const char *reason) {
  perror(reason);
  exit(EXIT_FAILURE);
}

static int showfile(const char *fpath, const struct stat *sb, int tflag,
                    struct FTW *ftwbuf) {
  (void)tflag;
  (void)ftwbuf;

  printf("path=%s ino=%ld mode=%o nlink=%ld uid=%d gid=%d "
         "size=%ld atime=%ld mtime=%ld ctime=%ld",
         fpath, sb->st_ino, sb->st_mode, sb->st_nlink, sb->st_uid, sb->st_gid,
         sb->st_size, sb->st_atime, sb->st_mtime, sb->st_ctime);

  switch (sb->st_mode & S_IFMT) {
    case S_IFREG: {
      char *md5sum = MD5File(fpath, NULL);
      printf(" md5=%s", md5sum);
      free(md5sum);
      break;
    }
    case S_IFLNK: {
      char symlink[PATH_MAX + 1] = "?";
      ssize_t size;
      if ((size = readlink(fpath, symlink, PATH_MAX)) > 0)
        symlink[size] = '\0';
      printf(" target=%s", symlink);
      break;
    }
    default:
      break;
  }
  putchar('\n');

  return 0;
}

int main(int argc, char *argv[]) {
  if (argc == 2) {
    if (chdir(argv[1]))
      die("chdir");
  }

  if (nftw(".", showfile, 40, FTW_CONTINUE | FTW_PHYS | FTW_DEPTH))
    die("nftw");

  exit(EXIT_SUCCESS);
}
