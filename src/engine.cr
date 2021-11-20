# Checks CSV files and prints out summary for each line.
module Engine
  @@csv_aetherhub : Bool = false
  @@csv_helvault : Bool = false
  @@csv_helvaultpro : Bool = false

  # Generates card summary
  struct Crawler
    getter game_format : String, scry_id : String, foil_status : String, quantity : String

    @card_bulk : JSON::Any = JSON::Any.new("")
    @card_name : String = ""
    @set_name : String = ""
    @set_code : String = ""
    @legality_stat : String = ""

    def initialize(@game_format, @scry_id, @foil_status, @quantity)
      card_json
    end

    # Sets card attributes and filters bulk data.
    def card_json : Nil
      Bulk.bootstrap
      x = 0
      until Bulk.get[x]["id"] == "#{@scry_id}"
        # OPTIMIZE: Not good enough!
        x += 1
      end
      @card_bulk = Bulk.get[x]
      @card_name = "#{@card_bulk["name"]}"
      @set_name = "#{@card_bulk["set_name"]}"
      @set_code = "#{@card_bulk["set"].to_s.upcase.colorize.mode(:underline)}"
    end

    # Prints card summary
    def summary : Nil
      # TODO: Add icons
      Log.info { "#{game_format}: #{legality_stat} #{card_name} ◄ #{set_name} ► ⑇ #{quantity}" }
      puts "▓▒░░░  #{legalities} #{foils} #{rarities} #{card_name} ⬡ #{set_name} ◄ #{set_code} ►"
    end

    # Returns card bulk data.
    def card_bulk : JSON::Any
      @card_bulk
    end

    # Returns card name.
    def card_name : String
      @card_name
    end

    # Returns card set name.
    def set_name : String
      @set_name
    end

    # Returns card set code.
    def set_code : String
      @set_code
    end

    # Returns card legality status.
    def legality_stat : String
      @legality_stat
    end

    # Sets legality status.
    def legalities : Colorize::Object(Symbol)
      case
      when @card_bulk["legalities"][@game_format] == "legal"
        @legality_stat = "LEGAL"
        Counter.legal("#{@quantity}".to_i)
        :"  Legal   ".colorize(:green)
      when @card_bulk["legalities"][@game_format] == "not_legal"
        @legality_stat = "NOT LEGAL"
        Counter.not_legal("#{@quantity}".to_i)
        :"Not legal ".colorize(:red)
      when @card_bulk["legalities"][@game_format] == "restricted"
        @legality_stat = "RESTRICTED"
        Counter.restricted("#{@quantity}".to_i)
        :"  Restr   ".colorize(:blue)
      when @card_bulk["legalities"][@game_format] == "banned"
        @legality_stat = "BANNED"
        Counter.banned("#{@quantity}".to_i)
        :"   BAN    ".colorize(:red)
      else
        raise "ERROR: legalities"
      end
    end

    # Sets rarity status.
    def rarities : Colorize::Object(Symbol)
      case
      when @card_bulk["rarity"] == "common"
        Counter.common("#{@quantity}".to_i)
        :C.colorize(:white)
      when @card_bulk["rarity"] == "uncommon"
        Counter.uncommon("#{@quantity}".to_i)
        :U.colorize(:cyan)
      when @card_bulk["rarity"] == "rare"
        Counter.rare("#{@quantity}".to_i)
        :R.colorize(:light_yellow)
      when @card_bulk["rarity"] == "special"
        Counter.special("#{@quantity}".to_i)
        :S.colorize(:yellow)
      when @card_bulk["rarity"] == "mythic"
        Counter.mythic("#{@quantity}".to_i)
        :M.colorize(:magenta)
      when @card_bulk["rarity"] == "bonus"
        Counter.bonus("#{@quantity}".to_i)
        :B.colorize(:light_blue)
      else
        raise "ERROR: rarity"
      end
    end

    # Sets foil status.
    def foils : Colorize::Object(Symbol)
      case
      when @foil_status == "1", @foil_status == "foil"
        Counter.foil("#{@quantity}".to_i)
        :▲.colorize(:light_gray)
      when @foil_status == "etchedFoil"
        Counter.efoil("#{@quantity}".to_i)
        :◭.colorize(:light_gray)
      when @foil_status == "0", @foil_status == ""
        :△.colorize(:dark_gray)
      else
        raise "ERROR: foil_status"
      end
    end
  end

  # Checks if CSV file is supported.
  def self.csv_layout(file) : String
    @@csv_aetherhub = @@csv_helvault = @@csv_helvaultpro = false
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

  # Validates CSV file against provided format.
  def self.validate_csv(file, game_format) : String
    csv_layout(file)
    csv_file = File.read(file)
    cardlist = CSV.new(csv_file, headers: true)
    Bulk.bootstrap
    puts "\n  * Reading CSV file ...", "\n"
    cardlist.each do |entry|
      row = entry.row.to_a
      case
      when @@csv_helvault
        card = Crawler.new game_format, row[4], row[0], row[3]
      when @@csv_helvaultpro
        card = Crawler.new game_format, row[8], row[2], row[6]
      when @@csv_aetherhub
        card = Crawler.new game_format, row[13], row[7], row[6]
      else
        raise "ERROR: csv"
      end
      Counter.total("#{card.quantity}".to_i)
      Counter.unique
      card.summary
    end
    Log.info { "Processed: #{Counter.get_unique}/#{Counter.get_total}" }
    Counter.output
    "validated"
  end

  # Returns card info for provided Scryfall ID.
  def self.card_info(id) : String
    Log.info { "Card info requested (#{id})" }
    puts "\n  * Printing card info ..."
    JSON.parse(HTTP::Client.get("https://api.scryfall.com/cards/#{id}").body).to_pretty_json
  end
end
