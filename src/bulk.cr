# Pulls bulk data from Scryfall
class Bulk
  # Downloads bulk data and keeps it up to date
  def self.pull : Nil
    bulk_data = JSON.parse(HTTP::Client.get("https://api.scryfall.com/bulk-data").body)
    download_link = bulk_data["data"][3]["download_uri"]
    if File.exists?("bulk-data.json")
      # Daily bulk data pulls
      local_time = Time.utc.to_unix
      modification_time = File.info("bulk-data.json").modification_time.to_unix
      bulk_time = 86000
      if (local_time - modification_time) >= bulk_time
        puts "\n  * Deleting old bulk data"
        File.delete("bulk-data.json")
      end
    end
    if !File.exists?("bulk-data.json")
      puts "\n  * Downloading bulk data from Scryfall ..."
      HTTP::Client.get("#{download_link}") do |response|
        File.write("bulk-data.json", response.body_io)
      end
      puts "\n  * Bulk data downloaded"
    end
  end
end
