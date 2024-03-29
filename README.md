# frightcrawler
[![Tests](https://github.com/charlesrocket/frightcrawler/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/charlesrocket/frightcrawler/actions/workflows/tests.yml)
[![codecov](https://codecov.io/gh/charlesrocket/frightcrawler/branch/master/graph/badge.svg)](https://codecov.io/gh/charlesrocket/frightcrawler)

[MtG](https://magic.wizards.com) deck legality validator for [Helvault](https://apps.apple.com/us/app/helvault-mtg-card-scanner/id1466963201)/[AetherHub](https://aetherhub.com) CSVs

### Dependencies
* `crystal`
* `sqlite3`

### Compilation

```shell
make
sudo make install
```

### Usage

```
frightcrawler -h
▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀
0.3.5
Usage: frightcrawler -g modern -f PATH/TO/FILE
    -f CSV_FILE                      Path to CSV file
    -g GAME_FORMAT                   Set game format
    -p SPEED                         Set speed [slow/normal/fast]
    -i SCRYFALL_ID                   Get card info
    -s, --sync                       Sync DB
    -d, --force-sync                 Force sync DB
    -h, --help                       Print documentation
Supported CSV layouts: Helvault, Helvault Pro, AetherHub.
Supported formats: "standard", "future", "historic", "gladiator", "pioneer", "explorer", "modern", "legacy", "pauper", "vintage", "penny", "commander", "brawl", "historicbrawl", "alchemy", "paupercommander", "duel", "oldschool", "premodern"
```
