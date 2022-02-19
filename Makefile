PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin
FRIGHTCRAWLER_SYSTEM=$(INSTALL_DIR)/frightcrawler

OUT_DIR=$(CURDIR)/bin
FRIGHTCRAWLER=$(OUT_DIR)/frightcrawler
FRIGHTCRAWLER_SOURCES=$(shell find src/ -type f -name '*.cr')

all: build

build: lib $(FRIGHTCRAWLER)

lib:
				@shards install --production

$(FRIGHTCRAWLER): $(FRIGHTCRAWLER_SOURCES) | $(OUT_DIR)
				@crystal build src/frightcrawler.cr -p -s -o $@ --release --no-debug

$(OUT_DIR) $(INSTALL_DIR):
				@mkdir -p $@

run:
				$(FRIGHTCRAWLER)

install: build | $(INSTALL_DIR)
				@rm -f $(FRIGHTCRAWLER_SYSTEM)
				cp $(FRIGHTCRAWLER) $(FRIGHTCRAWLER_SYSTEM)

clean:
				rm -rf $(FRIGHTCRAWLER)

distclean:
				rm -rf bin lib
