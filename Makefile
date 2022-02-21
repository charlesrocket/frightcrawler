PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin
FRIGHTCRAWLER_SYSTEM=$(INSTALL_DIR)/frightcrawler

FRIGHTCRAWLER=bin/frightcrawler
FRIGHTCRAWLER_SOURCES=$(shell find src/ -type f -name '*.cr')

all: build

build: lib $(FRIGHTCRAWLER)

lib:
				@shards install

$(FRIGHTCRAWLER): $(FRIGHTCRAWLER_SOURCES)
				@crystal build src/frightcrawler.cr -p -o bin/frightcrawler --release --no-debug --verbose

test: lib
				@crystal spec -s -p -v -D extended --order=random --error-on-warnings

run:
				$(FRIGHTCRAWLER)

install:
				@rm -f $(FRIGHTCRAWLER_SYSTEM)
				cp $(FRIGHTCRAWLER) $(FRIGHTCRAWLER_SYSTEM)

uninstall:
				rm -f $(FRIGHTCRAWLER_SYSTEM)

clean:
				rm -f $(FRIGHTCRAWLER)

distclean:
				rm -rf bin lib
