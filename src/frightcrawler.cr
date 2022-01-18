require "sqlite3"
require "http/client"
require "option_parser"
require "colorize"
require "json"
require "csv"
require "log"

require "./cli"
require "./counter"
require "./db"
require "./engine"

# :nodoc:
VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

if !Dir.exists?(Database::DB_HOME)
  Dir.mkdir_p(Database::DB_HOME)
end

backend = Log::IOBackend.new(File.new("#{Database::DB_HOME}/frightcrawler.log", "a+"))
Log.setup(:info, backend)

# Supported formats.
FORMATS = ["standard", "future", "historic", "gladiator", "pioneer", "modern", "legacy", "pauper", "vintage", "penny", "commander", "brawl", "historicbrawl", "paupercommander", "duel", "oldschool", "premodern"]

# :nodoc:
INTRO = "
▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀"

puts INTRO, VERSION

# :nodoc:
T1 = Time.monotonic

CLI.parse

# :nodoc:
T2 = Time.monotonic
