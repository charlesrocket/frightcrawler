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
      parser.separator(message = "Supported formats:")
      parser.separator(message = "brawl, commander, duel, future, gladiator, historic, legacy, modern, oldschool, pauper, penny, pioneer, premodern, standard, vintage")
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
      if foil_status == "1" || foil_status == "foil"
        foil = "▲".colorize(:light_gray)
      elsif foil_status == "etchedFoil"
        foil = "◭".colorize(:light_gray)
      else
        foil = "△".colorize(:dark_gray)
      end
      scry_api = HTTP::Client.get("#{scry_id}")
      api_response = scry_api.body
      if api_response.includes? %("#{game_format}":"not_legal")
        puts "  ▓▒░░░  Not legal  #{foil}  #{card_name}  ◄ #{set_name} ►"
      elsif api_response.includes? %("#{game_format}":"legal")
        puts "  ▓▒░░░    Legal    #{foil}  #{card_name}  ◄ #{set_name} ►"
      else
        puts parser
        exit(1)
      end
      sleep 0.1 # API rate limit
    end
  end
end
