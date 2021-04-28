require "http"
require "json"
require "csv"

# TODO: Write documentation for `Frightcrawler`
module Frightcrawler
  VERSION = "0.0.9"

  intro = "
  ▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
  ▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
  ▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
  ▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
  ▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
  ▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀"

  puts intro
  loop_count = 1
  counter = 0
  File.open("helvault.csv") do |infile|
    cardlist = CSV.new(infile, header = true)
    puts "  Processing CSV file ..."
    cardlist.each do |entry|
      row = entry.row.to_a
      scry_id = "https://api.scryfall.com/cards/" + row[6]
      card_name = row[3]
      foil_status = row[1]
      scry_api = HTTP::Client.get("#{scry_id}")
      api_response = scry_api.body
      puts api_response.includes? %("standard":"not_legal")
      sleep 0.1
    end
  end
end
