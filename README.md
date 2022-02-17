# frightcrawler
[![Tests](https://github.com/charlesrocket/frightcrawler/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/charlesrocket/frightcrawler/actions/workflows/tests.yml)
[![codecov](https://codecov.io/gh/charlesrocket/frightcrawler/branch/master/graph/badge.svg)](https://codecov.io/gh/charlesrocket/frightcrawler)
[![Docs](https://img.shields.io/badge/docs-available-9cf.svg?logo=crystal)](https://charlesrocket.github.io/frightcrawler)

[MtG](https://magic.wizards.com) deck legality validator for [Helvault](https://apps.apple.com/us/app/helvault-mtg-card-scanner/id1466963201)/[AetherHub](https://aetherhub.com) CSVs

#### Compilation

```shell
shards install
crystal build src/frightcrawler.cr --release
```

#### Usage

```
frightcrawler -h
▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀
0.3.1
Usage: frightcrawler -g modern -f PATH/TO/FILE
    -f CSV_FILE                      Path to CSV file
    -g GAME_FORMAT                   Set game format
    -p SPEED                         Set speed [slow/normal/fast]
    -i SCRYFALL_ID                   Get card info
    -s, --sync                       Sync DB
    -h, --help                       Print documentation
Supported CSV layouts: Helvault, Helvault Pro, AetherHub.
Supported formats: "standard", "future", "historic", "gladiator", "pioneer", "modern", "legacy", "pauper", "vintage", "penny", "commander", "brawl", "historicbrawl", "paupercommander", "duel", "oldschool", "premodern"
```
