# Checks CSV files and prints out summary for each line.
module Engine
  @@csv_aetherhub : Bool = false
  @@csv_helvault : Bool = false
  @@csv_helvaultpro : Bool = false

  # Generates card summary
  struct Crawler
    getter game_format : String, scry_id : String, foil_status : String, quantity : String

    @card_name : String = ""
    @set_name : String = ""
    @set_code : String = ""
    @rarity : String = ""
    @legality : String = ""

    @legality_standard : String = ""
    @legality_future : String = ""
    @legality_historic : String = ""
    @legality_gladiator : String = ""
    @legality_pioneer : String = ""
    @legality_modern : String = ""
    @legality_legacy : String = ""
    @legality_pauper : String = ""
    @legality_vintage : String = ""
    @legality_penny : String = ""
    @legality_commander : String = ""
    @legality_brawl : String = ""
    @legality_historicbrawl : String = ""
    @legality_paupercommander : String = ""
    @legality_duel : String = ""
    @legality_oldschool : String = ""
    @legality_premodern : String = ""

    def initialize(@game_format, @scry_id, @foil_status, @quantity)
      card_query
    end

    # Sets card attributes.
    def card_query : Nil
      DB.open "sqlite3://./frightcrawler.db" do |db|
        db_card = db.query_one "SELECT * from cards where id = ?", "#{@scry_id}", as: Database::Cards
        @card_name = db_card.name
        @set_name = db_card.set_name
        @set_code = "#{db_card.set_code.upcase.colorize.mode(:underline)}"
        @rarity = db_card.rarity

        @legality_standard = db_card.legality_standard
        @legality_future = db_card.legality_future
        @legality_historic = db_card.legality_historic
        @legality_gladiator = db_card.legality_gladiator
        @legality_pioneer = db_card.legality_pioneer
        @legality_modern = db_card.legality_modern
        @legality_legacy = db_card.legality_legacy
        @legality_pauper = db_card.legality_pauper
        @legality_vintage = db_card.legality_vintage
        @legality_penny = db_card.legality_penny
        @legality_commander = db_card.legality_commander
        @legality_brawl = db_card.legality_brawl
        @legality_historicbrawl = db_card.legality_historicbrawl
        @legality_paupercommander = db_card.legality_paupercommander
        @legality_duel = db_card.legality_duel
        @legality_oldschool = db_card.legality_oldschool
        @legality_premodern = db_card.legality_premodern
      end
    end

    # Prints card summary
    def summary : Nil
      # TODO: Add icons
      Log.info { "#{game_format}: #{legality_stat} #{card_name} ◄ #{set_name} ► ⑇ #{quantity}" }
      puts "▓▒░░░  #{legality_stat} #{foils} #{rarities} #{card_name} ⬡ #{set_name} ◄ #{set_code} ►"
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
    def legality : String
      @legality
    end

    # Sets legality status.
    def legality_stat : Colorize::Object(Symbol)
      case
      when legalities(@game_format) == "legal"
        @legality = "LEGAL"
        Counter.legal("#{@quantity}".to_i)
        :"  Legal   ".colorize(:green)
      when legalities(@game_format) == "not_legal"
        @legality = "NOT LEGAL"
        Counter.not_legal("#{@quantity}".to_i)
        :"Not legal ".colorize(:red)
      when legalities(@game_format) == "restricted"
        @legality = "RESTRICTED"
        Counter.restricted("#{@quantity}".to_i)
        :"  Restr   ".colorize(:blue)
      when legalities(@game_format) == "banned"
        @legality = "BANNED"
        Counter.banned("#{@quantity}".to_i)
        :"   BAN    ".colorize(:red)
      else
        raise "ERROR: legality_stat"
      end
    end

    # Sets legality format.
    def legalities(for @game_format) : String
      case @game_format
      when "standard" then @legality_standard
      when "future" then @legality_future
      when "historic" then @legality_historic
      when "gladiator" then @legality_gladiator
      when "pioneer" then @legality_pioneer
      when "modern" then @legality_modern
      when "legacy" then @legality_legacy
      when "pauper" then @legality_pauper
      when "vintage" then @legality_vintage
      when "penny" then @legality_penny
      when "commander" then @legality_commander
      when "brawl" then @legality_brawl
      when "historicbrawl" then @legality_historicbrawl
      when "paupercommander" then @legality_paupercommander
      when "duel" then @legality_duel
      when "oldschool" then @legality_oldschool
      when "premodern" then @legality_premodern
      else
        raise "ERROR: Unsupported format '#{@game_format}'."
      end
    end

    # Sets rarity status.
    def rarities : Colorize::Object(Symbol)
      case
      when @rarity == "common"
        Counter.common("#{@quantity}".to_i)
        :C.colorize(:white)
      when @rarity == "uncommon"
        Counter.uncommon("#{@quantity}".to_i)
        :U.colorize(:cyan)
      when @rarity == "rare"
        Counter.rare("#{@quantity}".to_i)
        :R.colorize(:light_yellow)
      when @rarity == "special"
        Counter.special("#{@quantity}".to_i)
        :S.colorize(:yellow)
      when @rarity == "mythic"
        Counter.mythic("#{@quantity}".to_i)
        :M.colorize(:magenta)
      when @rarity == "bonus"
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
      raise "ERROR: Unsupported CSV layout"
    end
  end

  # Validates CSV file against provided format.
  def self.validate_csv(file, game_format) : String
    puts "\n  * Using #{game_format} format list"
    csv_layout(file)
    csv_file = File.read(file)
    cardlist = CSV.new(csv_file, headers: true)
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
      sleep 0.001
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
