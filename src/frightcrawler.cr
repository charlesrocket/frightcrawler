require "option_parser"
require "colorize"
require "http"
require "json"
require "csv"

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
  game_format = ""
  parser = OptionParser.new do |parser|
    parser.on("-g GAME_FORMAT", "Set game format") { |_game_format| game_format = _game_format }
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
  File.open("helvault.csv") do |file|
    cardlist = CSV.new(file, header = true)
    puts
    puts "  Processing CSV file for #{game_format} format"
    puts
    cardlist.each do |entry|
      row = entry.row.to_a
      scry_id = "https://api.scryfall.com/cards/" + row[6]
      card_name = row[3].colorize.mode(:bright)
      foil_status = row[1]
      set_name = row[8].colorize.mode(:underline)
      if foil_status == '1'
        foil = "◆".colorize(:light_gray)
      elsif foil_status == "foil"
        foil = "◆".colorize(:light_gray)
      else
        foil = "●".colorize(:dark_gray)
      end
      scry_api = HTTP::Client.get("#{scry_id}")
      api_response = scry_api.body
      if api_response.includes? %("#{game_format}":"not_legal")
        puts "  ▓▒░░░  Not legal #{foil} #{card_name}  ◄ #{set_name} ►"
      elsif api_response.includes? %("#{game_format}":"legal")
        puts "  ▓▒░░░    Legal   #{foil} #{card_name}  ◄ #{set_name} ►"
      else
        puts parser
        exit(1)
      end
      sleep 0.1 # API rate limit
    end
  end
end
