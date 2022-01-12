# frightcrawler
[![Tests](https://github.com/charlesrocket/frightcrawler/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/charlesrocket/frightcrawler/actions/workflows/tests.yml)
[![codecov](https://codecov.io/gh/charlesrocket/frightcrawler/branch/master/graph/badge.svg)](https://codecov.io/gh/charlesrocket/frightcrawler)
[![Docs](https://img.shields.io/badge/docs-available-9cf.svg?logo=crystal)](https://charlesrocket.github.io/frightcrawler)

```
▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀
```

### MtG deck validator

#### Compilation

```shell
shards install
crystal build src/frightcrawler.cr --release
```

#### Usage

```shell
frightcrawler -h
frightcrawler -g modern -f PATH/TO/FILE
```
