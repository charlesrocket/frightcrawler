require "./bulk"
require "./counter"
require "./engine"
require "http/client"
require "option_parser"
require "colorize"
require "json"
require "csv"
require "log"

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

t1 = Time.monotonic

if sf_id != ""
  puts "\n  * Printing card info ..."
  puts Crawler.card_info("#{sf_id}")
end

if game_format != ""
  puts "\n  * Using #{game_format} format list"
  Bulk.pull
end

if csv_file != Nil
  Crawler.check_csv("#{csv_file}")
  Crawler.validate_csv("#{csv_file}", "#{game_format}")
end

t2 = Time.monotonic

if csv_file != Nil
  Log.info { "Processed: #{Counter.get_unique}/#{Counter.get_total}" }
  Counter.output
end

if csv_file == Nil && sf_id == "" && game_format == ""
  puts "\n  No data provided"
end

elapsed_time = t2 - t1
puts "  Elapsed time: #{elapsed_time}"
puts "\n  DONE"
