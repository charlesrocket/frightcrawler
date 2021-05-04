require "http/client"
require "json"

def pull_bulk
  bulk_api = HTTP::Client.get("https://api.scryfall.com/bulk-data")
  bulk_json = JSON.parse("#{bulk_api.body}")
  download_link = bulk_json["data"][2]["download_uri"]
  HTTP::Client.get("#{download_link}") do |response|
    File.write("bulk-data.json", response.body_io)
  end
end
