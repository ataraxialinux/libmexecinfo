CFLAGS     = -O2 -Wall -Wextra -Wformat -Werror -Wno-unused-parameter -Wno-unused-function
LDFLAGS    =
SHARED     = 0
PREFIX     = /usr/local

ifeq ($(LIBELF),1)
CFLAGS_E   = $(CFLAGS) -DLIBELF
LDFLAGS_E  = $(LDFLAGS) -lelf
SHARED     =  1
endif

CC         = $(CROSS_COMPILE)cc
AR         = $(CROSS_COMPILE)ar
RANLIB     = $(CROSS_COMPILE)ranlib
STRIP      = $(CROSS_COMPILE)strip -x -R .note -R .comment
INSTALL    = install
LN         = ln -sf
RM         = rm -f

HEADERS   := execinfo.h
SOURCES   := backtrace.c symtab.c unwind.c
OBJECTS   := $(patsubst %.c,%.o,$(SOURCES))
OBJECTS_E := $(patsubst %.c,%.lelfo,$(SOURCES))

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

%.lelfo: %.c
	$(CC) $(CFLAGS_E) -c $^ -o $@

all: libexecinfo.a libexecinfo.so

libexecinfo.a: $(OBJECTS)
	$(AR) rcs libexecinfo.a $^
	$(RANLIB) libexecinfo.a

libexecinfo.so: $(OBJECTS_E)
ifeq ($(LIBELF),1)
	$(CC) $(LDFLAGS_E) -shared -Wl,-soname=libexecinfo.so -o libexecinfo.so $^
	$(STRIP) libexecinfo.so
endif

install:
	$(INSTALL) -d -m 755  $(DESTDIR)$(PREFIX)/lib
	$(INSTALL) -d -m 755  $(DESTDIR)$(PREFIX)/include
	$(INSTALL) -m 644 $(HEADERS) $(DESTDIR)$(PREFIX)/include
	$(INSTALL) -m 644 libexecinfo.a $(DESTDIR)$(PREFIX)/lib
ifeq ($(LIBELF),1)
	$(INSTALL) -m 755 libexecinfo.so $(DESTDIR)$(PREFIX)/lib
endif

clean: libexecinfo.a libexecinfo.so
	rm $(OBJECTS) $(OBJECTS_E) libexecinfo.a libexecinfo.so

.PHONY: all clean install
