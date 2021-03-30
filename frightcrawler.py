#!/usr/bin/env python3

import csv
import json

def jsonpull():
    url = 'https://c2.scryfall.com/file/scryfall-bulk/all-cards/all-cards-20210330091425.json'
    output_file = 'scryfall-db.csv'
