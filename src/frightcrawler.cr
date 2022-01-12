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

if !Dir.exists?(DB_HOME)
  Dir.mkdir_p(DB_HOME)
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

if !File.exists?(Database::DB_FILE)
  Database.sync
end

# :nodoc:
T1 = Time.monotonic

CLI.parse

# :nodoc:
T2 = Time.monotonic
