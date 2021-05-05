require "./bulk"
require "option_parser"
require "http/client"
require "colorize"
require "json"
require "csv"

VERSION = "0.1.1"
intro = "
▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀"
puts intro
bulk = false
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
pull_bulk
File.open("#{csv_file}") do |file|
  cardlist = CSV.new(file, header = true)
  csv_header = cardlist.headers
  puts
  puts "  Processing CSV file for #{game_format} format"
  puts
  bulk_file = File.read("bulk-data.json")
  bulk_json = JSON.parse("#{bulk_file}")
  cardlist.each do |entry|
    row = entry.row.to_a
    if csv_header.includes? %(AetherHub Card Id)
      scry_id = row[13]
      card_name = row[12]
      foil_status = row[7]
      set_name = row[14].upcase.colorize.mode(:underline)
    else
      scry_id = row[6]
      card_name = row[3]
      foil_status = row[1]
      set_name = row[7].upcase.colorize.mode(:underline)
    end
    i = 0
    until bulk_json[i]["id"] == "#{scry_id}"
      i += 1
    end
    case
    when foil_status == "1", foil_status == "foil"
      foil_layout = "▲".colorize(:light_gray)
    when foil_status == "etchedFoil"
      foil_layout = "◭".colorize(:light_gray)
    else
      foil_layout = "△".colorize(:dark_gray)
    end
    scry_json = bulk_json[i]
    if scry_json["legalities"]["#{game_format}"] == "legal"
      legalities = "  Legal   "
    elsif scry_json["legalities"]["#{game_format}"] == "not_legal"
      legalities = "Not legal "
    else
      puts parser
      exit(1)
    end
    if scry_json["rarity"] == "common"
      rarity_symbol = "C".colorize(:white)
    elsif scry_json["rarity"] == "uncommon"
      rarity_symbol = "U".colorize(:cyan)
    elsif scry_json["rarity"] == "rare"
      rarity_symbol = "R".colorize(:light_yellow)
    elsif scry_json["rarity"] == "mythic"
      rarity_symbol = "M".colorize(:magenta)
    elsif scry_json["rarity"] == "special"
      rarity_symbol = "S".colorize(:light_blue)
    elsif scry_json["rarity"] == "land"
      rarity_symbol = "L".colorize(:light_gray)
    else
      puts parser
      exit(1)
    end
    puts "  ▓▒░░░  #{legalities} #{foil_layout} #{rarity_symbol} #{card_name}  ◄ #{set_name} ►"
    sleep 0.1 # API rate limit
  end
end
