PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin
FRIGHTCRAWLER_SYSTEM=$(INSTALL_DIR)/frightcrawler

OUT_DIR=$(CURDIR)/bin
FRIGHTCRAWLER=$(OUT_DIR)/frightcrawler
FRIGHTCRAWLER_SOURCES=$(shell find src/ -type f -name '*.cr')
WEBMOCK=$(CURDIR)/lib/webmock

all: build

build: lib $(FRIGHTCRAWLER)

lib:
				@shards install --production

$(FRIGHTCRAWLER): $(FRIGHTCRAWLER_SOURCES) | $(OUT_DIR)
				@crystal build src/frightcrawler.cr -p -s -o $@ --release --no-debug

$(OUT_DIR) $(INSTALL_DIR):
				@mkdir -p $@

$(WEBMOCK):
				@shards install

spec: $(WEBMOCK)
				@crystal spec -s -p -v -D extended --order=random --error-on-warnings

run:
				$(FRIGHTCRAWLER)

install: build | $(INSTALL_DIR)
				@rm -f $(FRIGHTCRAWLER_SYSTEM)
				cp $(FRIGHTCRAWLER) $(FRIGHTCRAWLER_SYSTEM)

clean:
				rm -f $(FRIGHTCRAWLER)

distclean:
				rm -rf bin lib

.PHONY: spec