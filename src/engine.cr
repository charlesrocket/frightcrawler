struct Crawler
  @@csv_aetherhub : Bool = false
  @@csv_helvault : Bool = false
  @@csv_helvaultpro : Bool = false

  @@legality_stat : String = ""

  def self.check_csv(file)
    @@csv_aetherhub = false
    @@csv_helvault = false
    @@csv_helvaultpro = false
    csv_file = File.read(file)
    cardlist = CSV.new(csv_file, headers: true)
    csv_header = cardlist.headers.to_s
    if csv_header.includes? %("extras", "language", "name", "quantity", "scryfall_id")
      @@csv_helvault = true
      puts "\n  * Helvault CSV file loaded"
      "helvault file"
    elsif csv_header.includes? %("collector_number", "estimated_price", "extras", "language")
      @@csv_helvaultpro = true
      puts "\n  * Helvault Pro CSV file loaded"
      "helvault pro file"
    elsif csv_header.includes? %(AetherHub Card Id)
      @@csv_aetherhub = true
      puts "\n  * AetherHub CSV file loaded"
      "aetherhub file"
    else
      raise "Unsupported CSV layout"
    end
  end

  def self.validate_csv(file, game_format) : String
    Crawler.check_csv(file)
    csv_file = File.read(file)
    cardlist = CSV.new(csv_file, headers: true)
    unless File.exists?("bulk-data.json")
      Bulk.pull
    end
    puts "\n  * Loading bulk data ..."
    bulk_json = JSON.parse(File.read("bulk-data.json"))
    puts "\n  * Bulk data loaded"
    puts "\n  * Reading CSV file ...", "\n"
    cardlist.each do |entry|
      row = entry.row.to_a
      x = 0
      case
      when @@csv_helvault
        scry_id = row[4]
        foil_status = row[0]
        quantity = row[3]
      when @@csv_helvaultpro
        scry_id = row[8]
        foil_status = row[2]
        quantity = row[6]
      when @@csv_aetherhub
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
      id_json = bulk_json[x]
      card_name = id_json["name"]
      set_name = id_json["set_name"]
      set_code = id_json["set"].to_s.upcase.colorize.mode(:underline)
      Counter.total("#{quantity}".to_i)
      Counter.unique
      # TODO: Add icons
      puts "▓▒░░░  #{legalities(id_json, game_format, quantity)} #{foils(foil_status, quantity)} #{rarities(id_json, quantity)} #{card_name} ⬡ #{set_name} ◄ #{set_code} ►"
      Log.info { "#{game_format}: #{@@legality_stat} #{card_name} ◄ #{set_name} ► ⑇ #{quantity}" }
    end
    "validated"
  end

  def self.legalities(json, game_format, quantity)
    case
    when json["legalities"][game_format] == "legal"
      @@legality_stat = "LEGAL"
      Counter.legal("#{quantity}".to_i)
      "  Legal   ".colorize(:green)
    when json["legalities"][game_format] == "not_legal"
      @@legality_stat = "NOT LEGAL"
      Counter.not_legal("#{quantity}".to_i)
      "Not legal ".colorize(:red)
    when json["legalities"][game_format] == "restricted"
      @@legality_stat = "RESTRICTED"
      Counter.restricted("#{quantity}".to_i)
      "  Restr   ".colorize(:blue)
    when json["legalities"][game_format] == "banned"
      @@legality_stat = "BANNED"
      Counter.banned("#{quantity}".to_i)
      "   BAN    ".colorize(:red)
    else
      raise "ERROR: legalities"
    end
  end

  def self.rarities(json, quantity)
    case
    when json["rarity"] == "common"
      Counter.common("#{quantity}".to_i)
      :C.colorize(:white)
    when json["rarity"] == "uncommon"
      Counter.uncommon("#{quantity}".to_i)
      :U.colorize(:cyan)
    when json["rarity"] == "rare"
      Counter.rare("#{quantity}".to_i)
      :R.colorize(:light_yellow)
    when json["rarity"] == "special"
      Counter.special("#{quantity}".to_i)
      :S.colorize(:yellow)
    when json["rarity"] == "mythic"
      Counter.mythic("#{quantity}".to_i)
      :M.colorize(:magenta)
    when json["rarity"] == "bonus"
      Counter.bonus("#{quantity}".to_i)
      :B.colorize(:light_blue)
    else
      raise "ERROR: rarity"
    end
  end

  def self.foils(foil_status, quantity)
    case
    when foil_status == "1", foil_status == "foil"
      Counter.foil("#{quantity}".to_i)
      :▲.colorize(:light_gray)
    when foil_status == "etchedFoil"
      Counter.efoil("#{quantity}".to_i)
      :◭.colorize(:light_gray)
    when foil_status == "0", foil_status == ""
      :△.colorize(:dark_gray)
    else
      raise "ERROR: foil_status"
    end
  end

  def self.card_info(z)
    Log.info { "Card info requested (#{z})" }
    JSON.parse(HTTP::Client.get("https://api.scryfall.com/cards/#{z}").body).to_pretty_json
  end
end
