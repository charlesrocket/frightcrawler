require "option_parser"
require "http/client"
require "colorize"
require "json"
require "csv"

module Frightcrawler
  VERSION = "0.1.1"
  intro = "
  ▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
  ▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
  ▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
  ▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
  ▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
  ▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀"
  puts intro
  game_format = ""
  csv_file = ""
  parser = OptionParser.new do |parser|
    parser.on("-g GAME_FORMAT", "Set game format") { |_game_format| game_format = _game_format }
    parser.on("-f CSV_FILE", "Path to CSV file") { |_csv_file| csv_file = _csv_file }
    parser.on("-h", "--help", "Print documentation") do
      parser.banner = "Usage: frightcrawler -g standard"
      parser.separator(message = "Supported CSV layouts: AetherHub, Helvault")
      parser.separator(message = "Supported formats: brawl, commander, duel, future, gladiator, historic, legacy, modern, oldschool, pauper, penny, pioneer, premodern, standard, vintage")
      puts parser
      exit
    end
    parser.on("-v", "--version", "Version") do
      puts VERSION
      exit
    end
  end
  parser.parse
  File.open("#{csv_file}") do |file|
    cardlist = CSV.new(file, header = true)
    csv_header = cardlist.headers
    puts
    puts "  Processing CSV file for #{game_format} format"
    puts
    cardlist.each do |entry|
      row = entry.row.to_a
      if csv_header.includes? %(AetherHub Card Id)
        scry_id = "https://api.scryfall.com/cards/" + row[13]
        card_name = row[12]
        foil_status = row[7]
        set_name = row[14].upcase.colorize.mode(:underline)
      else
        scry_id = "https://api.scryfall.com/cards/" + row[6]
        card_name = row[3]
        foil_status = row[1]
        set_name = row[7].upcase.colorize.mode(:underline)
      end
      case
      when foil_status == "1", foil_status == "foil"
        foil_layout = "▲".colorize(:light_gray)
      when foil_status == "etchedFoil"
        foil_layout = "◭".colorize(:light_gray)
      else
        foil_layout = "△".colorize(:dark_gray)
      end
      scry_api = HTTP::Client.get("#{scry_id}")
      scry_json = JSON.parse("#{scry_api.body}")
      if scry_json["legalities"]["#{game_format}"] == "legal"
        legalities = "  Legal   "
      elsif scry_json["legalities"]["#{game_format}"] == "not_legal"
        legalities = "Not legal "
      else
        puts parser
        exit(1)
      end
      if scry_json["rarity"] == "common"
        rarity_symbol = "C"
      elsif scry_json["rarity"] == "uncommon"
        rarity_symbol = "U"
      elsif scry_json["rarity"] == "rare"
        rarity_symbol = "R"
      elsif scry_json["rarity"] == "mythic"
        rarity_symbol = "M"
      elsif scry_json["rarity"] == "land"
        rarity_symbol = "L"
      else
        puts parser
        exit(1)
      end
      puts "  ▓▒░░░  #{legalities} #{foil_layout} #{rarity_symbol} #{card_name}  ◄ #{set_name} ►"
      sleep 0.1 # API rate limit
    end
  end
end
