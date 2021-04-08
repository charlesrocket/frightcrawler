#!/usr/bin/env python3

import argparse
import time
import requests
import json
import csv
from dictor import dictor

parser = argparse.ArgumentParser()
parser.add_argument(dest='format',
                    choices=['brawl','commander', 'duel', 'future', 'gladiator',
                    'historic', 'legacy', 'modern', 'oldschool', 'pauper', 'penny',
                    'pioneer', 'premodern', 'standard', 'vintage'])

args = parser.parse_args()
args.brawl = (args.format == 'brawl')
args.commander = (args.format == 'commander')
args.duel = (args.format == 'duel')
args.future = (args.format == 'future')
args.gladiator = (args.format == 'gladiator')
args.historic = (args.format == 'historic')
args.legacy = (args.format == 'legacy')
args.modern = (args.format == 'modern')
args.oldschool = (args.format == 'oldschool')
args.pauper = (args.format == 'pauper')
args.penny = (args.format == 'penny')
args.pioneer = (args.format == 'pioneer')
args.premodern = (args.format == 'premodern')
args.standard = (args.format == 'standard')
args.vintage = (args.format == 'vintage')

with open('helvault.csv') as helvaultdb:
    readHVDB = csv.reader(helvaultdb, delimiter=',')
    for row in readHVDB:
        scryId = 'https://api.scryfall.com/cards/' + row[6]
        scryAPI = requests.get(scryId)
        scryJSON = scryAPI.json()
        cardName = row[3]
        ###
        if args.brawl:
            cardStatus = dictor(scryJSON, 'legalities', search='brawl')
        if args.commander:
            cardStatus = dictor(scryJSON, 'legalities', search='commander')
        if args.duel:
            cardStatus = dictor(scryJSON, 'legalities', search='duel')
        if args.future:
            cardStatus = dictor(scryJSON, 'legalities', search='future')
        if args.gladiator:
            cardStatus = dictor(scryJSON, 'legalities', search='gladiator')
        if args.historic:
            cardStatus = dictor(scryJSON, 'legalities', search='historic')
        if args.legacy:
            cardStatus = dictor(scryJSON, 'legalities', search='legacy')
        if args.modern:
            cardStatus = dictor(scryJSON, 'legalities', search='modern')
        if args.oldschool:
            cardStatus = dictor(scryJSON, 'legalities', search='oldschool')
        if args.pauper:
            cardStatus = dictor(scryJSON, 'legalities', search='pauper')
        if args.penny:
            cardStatus = dictor(scryJSON, 'legalities', search='penny')
        if args.pioneer:
            cardStatus = dictor(scryJSON, 'legalities', search='pioneer')
        if args.premodern:
            cardStatus = dictor(scryJSON, 'legalities', search='premodern')
        if args.standard:
            cardStatus = dictor(scryJSON, 'legalities', search='standard')
        if args.vintage:
            cardStatus = dictor(scryJSON, 'legalities', search='vintage')
        ###
        print(cardStatus, cardName)
        time.sleep(.1) #respect API rate limits
