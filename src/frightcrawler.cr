require "./bulk"
require "./counter"
require "http/client"
require "option_parser"
require "colorize"
require "json"
require "csv"
require "log"

class NoData < Exception
end

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
puts intro, VERSION

game_format : String = ""
sf_id : String = ""
csv_file = Nil

OptionParser.parse do |parser|
  parser.on("-g GAME_FORMAT", "Set game format") { |_game_format| game_format = _game_format }
  parser.on("-f CSV_FILE", "Path to CSV file") { |_csv_file| csv_file = _csv_file }
  parser.on("-i SCRYFALL_ID", "Get card info") { |_sf_id| sf_id = _sf_id }
  parser.on("-h", "--help", "Print documentation") do
    parser.banner = "Usage: frightcrawler -g modern -f PATH/TO/FILE"
    parser.separator("Supported CSV layouts: Helvault, Helvault Pro, AetherHub.")
    parser.separator("Supported formats: standard, future, historic, gladiator, pioneer, modern, legacy, pauper,\nvintage, penny, commander, brawl, historicbrawl, paupercommander, duel, oldschool, premodern.")
    puts parser
    exit
  end
end

unless sf_id.empty?
  puts JSON.parse(HTTP::Client.get("https://api.scryfall.com/cards/#{sf_id}").body).to_pretty_json
  exit
end

unless csv_file != Nil
  begin
    raise NoData.new("No CSV file provided")
  rescue no_file : NoData
    Log.error { "No File" }
    puts "Exiting: #{no_file.message}"
    exit
  end
end

t1 = Time.monotonic
puts "\n  * Using #{game_format} format list"
Bulk.pull

struct Crawler
  File.open("#{csv_file}") do |file|
    cardlist = CSV.new(file, headers: true)
    csv_header = cardlist.headers.to_s
    if csv_header.includes? %("extras", "language", "name", "quantity", "scryfall_id")
      csv_helvault = true
      puts "\n  * Helvault CSV file loaded"
    elsif csv_header.includes? %("collector_number", "estimated_price", "extras", "language")
      csv_helvaultpro = true
      puts "\n  * Helvault Pro CSV file loaded"
    elsif csv_header.includes? %(AetherHub Card Id)
      csv_aetherhub = true
      puts "\n  * AetherHub CSV file loaded"
    else
      raise "Unsupported CSV layout"
    end
    puts "\n  * Loading bulk data ..."
    bulk_json = JSON.parse(File.read("bulk-data.json"))
    puts "\n  * Bulk data loaded"
    puts "\n  * Reading CSV file ...", "\n"
    cardlist.each do |entry|
      row = entry.row.to_a
      x = 0
      case
      when csv_helvault
        scry_id = row[4]
        foil_status = row[0]
        quantity = row[3]
      when csv_helvaultpro
        scry_id = row[8]
        foil_status = row[2]
        quantity = row[6]
      when csv_aetherhub
        scry_id = row[13]
        foil_status = row[7]
        quantity = row[6]
      else
        raise "ERROR: csv"
      end
      until bulk_json[x]["id"] == "#{scry_id}"
        # OPTIMIZE: Not good enough!
        x += 1
      end
      scry_json = bulk_json[x]
      card_name = scry_json["name"]
      set_name = scry_json["set_name"]
      set_code = scry_json["set"].to_s.upcase.colorize.mode(:underline)
      case
      when foil_status == "1", foil_status == "foil"
        foil_layout = :▲.colorize(:light_gray)
        Counter.foil("#{quantity}".to_i)
      when foil_status == "etchedFoil"
        foil_layout = :◭.colorize(:light_gray)
        Counter.efoil("#{quantity}".to_i)
      when foil_status == "0", foil_status == ""
        foil_layout = :△.colorize(:dark_gray)
      else
        raise "ERROR: foil_status"
      end
      case
      when scry_json["legalities"]["#{game_format}"] == "legal"
        legalities = "  Legal   ".colorize(:green)
        Counter.legal("#{quantity}".to_i)
      when scry_json["legalities"]["#{game_format}"] == "not_legal"
        legalities = "Not legal ".colorize(:red)
        Counter.not_legal("#{quantity}".to_i)
      when scry_json["legalities"]["#{game_format}"] == "restricted"
        legalities = "  Restr   ".colorize(:blue)
        Counter.restricted("#{quantity}".to_i)
      when scry_json["legalities"]["#{game_format}"] == "banned"
        legalities = "   BAN    ".colorize(:red)
        Counter.banned("#{quantity}".to_i)
      else
        raise "ERROR: legalities"
      end
      case
      when scry_json["rarity"] == "common"
        rarity_symbol = :C.colorize(:white)
        Counter.common("#{quantity}".to_i)
      when scry_json["rarity"] == "uncommon"
        rarity_symbol = :U.colorize(:cyan)
        Counter.uncommon("#{quantity}".to_i)
      when scry_json["rarity"] == "rare"
        rarity_symbol = :R.colorize(:light_yellow)
        Counter.rare("#{quantity}".to_i)
      when scry_json["rarity"] == "special"
        rarity_symbol = :S.colorize(:yellow)
        Counter.special("#{quantity}".to_i)
      when scry_json["rarity"] == "mythic"
        rarity_symbol = :M.colorize(:magenta)
        Counter.mythic("#{quantity}".to_i)
      when scry_json["rarity"] == "bonus"
        rarity_symbol = :B.colorize(:light_blue)
        Counter.bonus("#{quantity}".to_i)
      else
        raise "ERROR: rarity"
      end
      Counter.total("#{quantity}".to_i)
      Counter.unique
      # TODO: Add icons
      puts "▓▒░░░  #{legalities} #{foil_layout} #{rarity_symbol} #{card_name} ⬡ #{set_name} ◄ #{set_code} ►"
      # TODO: Improve logging
      Log.info { "#{game_format}: #{legalities} #{card_name} ◄ #{set_name} ► ⑇ #{quantity}" }
    end
  end
end

t2 = Time.monotonic
elapsed_time = t2 - t1
Log.info { "Processed: #{Counter.get_unique}/#{Counter.get_total}" }
Counter.output
puts "  Elapsed time: #{elapsed_time}"
puts "\n  DONE"
