CHAINPREFIX=/opt/rs97-toolchain

TARGET=rs97

CROSS_COMPILE=$(CHAINPREFIX)/usr/bin/mipsel-linux-

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
STRIP = $(CROSS_COMPILE)strip

SYSROOT     := $(CHAINPREFIX)/usr/mipsel-buildroot-linux-uclibc/sysroot
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

CFLAGS = -ggdb -DTARGET_RS97 -DTARGET=$(TARGET) -DLOG_LEVEL=3 -g3 $(SDL_CFLAGS) -I$(CHAINPREFIX)/usr/include/ -I$(SYSROOT)/usr/include/  -I$(SYSROOT)/usr/include/SDL/  
CXXFLAGS = $(CFLAGS)
LDFLAGS = $(SDL_LIBS) -lfreetype -lSDL_image -lSDL_ttf -lSDL_gfx -lSDL -lpthread

OBJDIR = objs/$(TARGET)
DISTDIR = dist/$(TARGET)/gmenu2x
APPNAME = $(OBJDIR)/gmenu2x

SOURCES := $(wildcard src/*.cpp)
OBJS := $(patsubst src/%.cpp, $(OBJDIR)/src/%.o, $(SOURCES))

# File types rules
$(OBJDIR)/src/%.o: src/%.cpp src/%.h
	$(CXX) $(CFLAGS) -o $@ -c $<

all: dir shared

dir:
	@if [ ! -d $(OBJDIR)/src ]; then mkdir -p $(OBJDIR)/src; fi

debug: $(OBJS)
	@echo "Linking gmenu2x-debug..."
	$(CXX) -o $(APPNAME)-debug $(LDFLAGS) $(OBJS)

shared: debug
	$(STRIP) $(APPNAME)-debug -o $(APPNAME)

clean:
	rm -rf $(OBJDIR) $(DISTDIR) *.gcda *.gcno $(APPNAME)

dist: dir shared
	install -m755 -D $(APPNAME) $(DISTDIR)/gmenu2x
	install -m644 assets/$(TARGET)/input.conf $(DISTDIR)
	# install -m755 -d $(DISTDIR)/sections/applications $(DISTDIR)/sections/emulators $(DISTDIR)/sections/games $(DISTDIR)/sections/settings
	install -m644 -D README.md $(DISTDIR)/README.txt
	install -m644 -D COPYING $(DISTDIR)/COPYING
	# install -m644 -D ChangeLog $(DISTDIR)/ChangeLog
	install -m644 -D about.txt $(DISTDIR)/about.txt
	cp -RH assets/skins assets/translations $(DISTDIR)
	# cp -RH assets/$(TARGET)/BlackJeans.png $(DISTDIR)/skins/Default/wallpapers
	# cp -RH assets/$(TARGET)/skin.conf $(DISTDIR)/skins/Default
	# cp -RH assets/$(TARGET)/font.ttf $(DISTDIR)/skins/Default
	# cp -RH assets/$(TARGET)/gmenu2x.conf $(DISTDIR)
	cp -RH assets/$(TARGET)/icons/* $(DISTDIR)/skins/Default/icons/
	# cp -RH assets/$(TARGET)/emulators/* $(DISTDIR)/sections/emulators/
	# cp -RH assets/$(TARGET)/games/* $(DISTDIR)/sections/games/
	# cp -RH assets/$(TARGET)/applications/* $(DISTDIR)/sections/applications/
	cd $(DISTDIR)/ && zip -FSr ../GMenuNext.zip .

-include $(patsubst src/%.cpp, $(OBJDIR)/src/%.d, $(SOURCES))

$(OBJDIR)/src/%.d: src/%.cpp
	@if [ ! -d $(OBJDIR)/src ]; then mkdir -p $(OBJDIR)/src; fi
	$(CXX) -M $(CXXFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

