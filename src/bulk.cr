# Manages bulk data.
module Bulk
  class_getter get : JSON::Any { File.open("bulk-data.json", "r") { |file| JSON.parse file } }

  @@bulk_loaded : Bool = false

  def self.bootstrap : Nil
    if @@bulk_loaded == false
      Puller.update
      puts "\n  * Loading bulk data ..."
      get
      puts "\n  * Bulk data loaded"
      @@bulk_loaded = true
    end
  end

  # Pulls bulk data from Scryfall.
  class Puller
    @@force_bulk_enabled : Bool = false

    # Downloads bulk data and keeps it up to date with *bulk_time*.
    def self.update(bulk_time = 2629743) : Nil
      if @@force_bulk_enabled == true
        if File.exists?("bulk-data.json")
          File.delete("bulk-data.json")
          puts "\n  * Bulk data deleted"
        end
      end
      bulk_data = JSON.parse(HTTP::Client.get("https://api.scryfall.com/bulk-data").body)
      download_link = bulk_data["data"][3]["download_uri"]
      if File.exists?("bulk-data.json")
        local_time = Time.utc.to_unix
        modification_time = File.info("bulk-data.json").modification_time.to_unix
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

    # Deletes bulk data on start.
    def self.force_bulk_enable : Bool
      @@force_bulk_enabled = true
      @@force_bulk_enabled
    end
  end
end
