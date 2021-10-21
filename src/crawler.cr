struct Crawler
  def self.print_line(gf, fl)
    File.open(fl) do |file|
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
        when scry_json["legalities"][gf] == "legal"
          legalities = "  Legal   ".colorize(:green)
          Counter.legal("#{quantity}".to_i)
        when scry_json["legalities"][gf] == "not_legal"
          legalities = "Not legal ".colorize(:red)
          Counter.not_legal("#{quantity}".to_i)
        when scry_json["legalities"][gf] == "restricted"
          legalities = "  Restr   ".colorize(:blue)
          Counter.restricted("#{quantity}".to_i)
        when scry_json["legalities"][gf] == "banned"
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
        Log.info { "#{gf}: #{legalities} #{card_name} ◄ #{set_name} ► ⑇ #{quantity}" }
      end
    end
  end
end
