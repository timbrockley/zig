## zig sqlite library

### /www/zig/libs/database/sqlite

To compile "libsqlite.zig", it is required to link "sqlite3" using build system.

```
sudo apt install -y libsqlite3-dev

# build library
zig build-lib libsqlite.zig -femit-bin=libsqlite.so -dynamic -L. -lsqlite3 -fPIC -O ReleaseSmall -target native -mcpu=baseline

# update SONAME
patchelf --set-soname libsqlite.so libsqlite.so

# build main and link library
zig build-exe main-sqlite.zig -femit-bin=main -dynamic -lc -fstrip -L. -lsqlite -O ReleaseSmall -target native -mcpu=baseline
```

### /www/zig/libs/database

"database-sqlite.zig" dynamically calls "libsqlite.so" and can be used with other zig code directly. This means that it is not necessary to directly link the shared library.

```
# build main (no need to link library)
zig build-exe main.zig -femit-bin=main -lc -O ReleaseSmall -target native -mcpu=baseline
```
