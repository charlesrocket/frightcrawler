require "http"
require "json"
require "csv"

# TODO: Write documentation for `Frightcrawler`
module Frightcrawler
  VERSION = "0.1.0"

  intro = "
  ▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
  ▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
  ▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
  ▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
  ▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
  ▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀"

  puts intro
  outro = "Help text"
  if ARGV.size == 0
    puts outro
    exit
  else
    case ARGV[0]
    when "brawl"
      card_format = "brawl"
    when "commander"
      card_format = "commander"
    when "duel"
      card_format = "duel"
    when "future"
      card_format = "future"
    when "gladiator"
      card_format = "gladiator"
    when "historic"
      card_format = "historic"
    when "legacy"
      card_format = "legacy"
    when "modern"
      card_format = "modern"
    when "oldschool"
      card_format = "oldschool"
    when "pauper"
      card_format = "pauper"
    when "penny"
      card_format = "penny"
    when "pioneer"
      card_format = "pioneer"
    when "premodern"
      card_format = "premodern"
    when "standard"
      card_format = "standard"
    when "vintage"
      card_format = "vintage"
    when "help", "--help", "-h"
      puts "help"
      exit
    when "version", "--version", "-v"
      puts VERSION
      exit
    else
      puts "ERROR"
      exit(1)
    end
  end
  loop_count = 1
  counter = 0
  File.open("helvault.csv") do |infile|
    cardlist = CSV.new(infile, header = true)
    puts "  Processing CSV file for #{card_format} format"
    cardlist.each do |entry|
      row = entry.row.to_a
      scry_id = "https://api.scryfall.com/cards/" + row[6]
      card_name = row[3]
      foil_status = row[1]
      set_name = row[8]
      if foil_status == '1'
        foil = "◆"
      elsif foil_status == "foil"
        foil = "◆"
      else
        foil = "●"
      end
      scry_api = HTTP::Client.get("#{scry_id}")
      api_response = scry_api.body
      if api_response.includes? %("#{card_format}":"not_legal")
        puts "  ▓▒░░░  Not legal  #{foil} #{card_name} ◄ #{set_name} ►"
      elsif api_response.includes? %("#{card_format}":"legal")
        puts "  ▓▒░░░    Legal    #{foil} #{card_name} ◄ #{set_name} ►"
      else
        puts "ERROR"
        exit(1)
      end
      sleep 0.1 # API rate limit
    end
  end
end
