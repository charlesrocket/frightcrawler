require "./bulk"
require "log"
require "option_parser"
require "colorize"
require "json"
require "csv"

VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
backend = Log::IOBackend.new(File.new("./frightcrawler.log", "a+"))
Log.setup(:info, backend)
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
total_count = 0
parser = OptionParser.new do |parser|
  parser.on("-g GAME_FORMAT", "Set game format") { |_game_format| game_format = _game_format }
  parser.on("-f CSV_FILE", "Path to CSV file") { |_csv_file| csv_file = _csv_file }
  parser.on("-h", "--help", "Print documentation") do
    parser.banner = "Usage: frightcrawler -g modern -f PATH/TO/FILE"
    parser.separator(message = "Supported CSV layouts: Helvault Pro, AetherHub")
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
puts "\n  Using #{game_format} format list"
pull_bulk
File.open("#{csv_file}") do |file|
  cardlist = CSV.new(file, header = true)
  csv_header = cardlist.headers
  if csv_header.includes? %(collector_number)
    csvHelvaultPro = true
    puts "\n  Helvault Pro CSV file loaded"
  elsif csv_header.includes? %(AetherHub Card Id)
    csvAetherHub = true
    puts "\n  AetherHub CSV file loaded"
  else
    raise "Unsupported CSV layout"
  end
  puts "\n  Loading bulk data ..."
  bulk_file = File.read("bulk-data.json")
  bulk_json = JSON.parse("#{bulk_file}")
  puts "\n  Bulk data loaded"
  puts "\n  Reading CSV file ...", "\n"
  cardlist.each do |entry|
    row = entry.row.to_a
    x = 0
    if csvHelvaultPro == true
      scry_id = row[7]
      card_name = row[4]
      foil_status = row[2]
      set_code = row[8].upcase.colorize.mode(:underline)
    elsif csvAetherHub == true
      scry_id = row[13]
      card_name = row[12]
      foil_status = row[7]
      set_code = row[14].upcase.colorize.mode(:underline)
    end
    until bulk_json[x]["id"] == "#{scry_id}"
      x += 1
    end
    case
    when foil_status == "1", foil_status == "foil"
      foil_layout = :▲.colorize(:light_gray)
    when foil_status == "etchedFoil"
      foil_layout = :◭.colorize(:light_gray)
    else
      foil_layout = :△.colorize(:dark_gray)
    end
    scry_json = bulk_json[x]
    set_name = scry_json["set_name"]
    if scry_json["legalities"]["#{game_format}"] == "legal"
      legalities = "  Legal   "
    elsif scry_json["legalities"]["#{game_format}"] == "not_legal"
      legalities = "Not legal "
    elsif scry_json["legalities"]["#{game_format}"] == "banned"
      legalities = "   BAN    "
    else
      exit(1)
    end
    if scry_json["rarity"] == "common"
      rarity_symbol = :C.colorize(:white)
    elsif scry_json["rarity"] == "uncommon"
      rarity_symbol = :U.colorize(:cyan)
    elsif scry_json["rarity"] == "rare"
      rarity_symbol = :R.colorize(:light_yellow)
    elsif scry_json["rarity"] == "special"
      rarity_symbol = :S.colorize(:yellow)
    elsif scry_json["rarity"] == "mythic"
      rarity_symbol = :M.colorize(:magenta)
    elsif scry_json["rarity"] == "bonus"
      rarity_symbol = :B.colorize(:light_blue)
    else
      exit(1)
    end
    total_count += 1
    STDOUT.puts "▓▒░░░  #{legalities} #{foil_layout} #{rarity_symbol} #{card_name} ⬡ #{set_name} ◄ #{set_code} ►"
    Log.info { "#{game_format}: #{legalities} #{card_name} ◄ #{set_name} ►" }
  end
end
puts "\n  DONE"
puts "  Total processed: #{total_count}"
