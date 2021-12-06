# Checks CSV files and prints out summary for each line.
module Engine
  @@csv_aetherhub : Bool = false
  @@csv_helvault : Bool = false
  @@csv_helvaultpro : Bool = false

  # Generates card summary
  struct Crawler
    getter game_format : String
    getter scry_id : String
    getter foil_status : String
    getter quantity : String

    @card_name : String = ""
    @set_name : String = ""
    @set_code : String = ""
    @rarity : String = ""
    @legality : String = ""

    def initialize(@game_format, @scry_id, @foil_status, @quantity)
      DB.open "sqlite3://./frightcrawler.db" do |db|
        db_card = db.query_one "SELECT id, name, set_name, set_code, rarity, legality_#{@game_format} AS legality from cards where id = ?", @scry_id, as: Database::Cards
        @card_name = db_card.name
        @set_name = db_card.set_name
        @set_code = "#{db_card.set_code.upcase.colorize.mode(:underline)}"
        @rarity = db_card.rarity
        @legality = db_card.legality.upcase
      end
    end

    # Prints card summary
    def summary : Nil
      # TODO: Add icons
      Log.info { "#{@game_format}: #{@legality} #{@card_name} ◄ #{@set_name} ► ⑇ #{@quantity}" }
      puts "▓▒░░░  #{legalities} #{foils} #{rarities} #{@card_name} ⬡ #{@set_name} ◄ #{@set_code} ►"
    end

    # Sets legality status.
    def legalities : Colorize::Object(Symbol)
      case @legality
      when "LEGAL"
        Counter.legal("#{@quantity}".to_i)
        :"  Legal   ".colorize(:green)
      when "NOT_LEGAL"
        Counter.not_legal("#{@quantity}".to_i)
        :"Not legal ".colorize(:red)
      when "RESTRICTED"
        Counter.restricted("#{@quantity}".to_i)
        :"  Restr   ".colorize(:blue)
      when "BANNED"
        Counter.banned("#{@quantity}".to_i)
        :"   BAN    ".colorize(:red)
      else
        raise "ERROR: legalities"
      end
    end

    # Sets rarity status.
    def rarities : Colorize::Object(Symbol)
      case @rarity
      when "common"
        Counter.common("#{@quantity}".to_i)
        :C.colorize(:white)
      when "uncommon"
        Counter.uncommon("#{@quantity}".to_i)
        :U.colorize(:cyan)
      when "rare"
        Counter.rare("#{@quantity}".to_i)
        :R.colorize(:light_yellow)
      when "special"
        Counter.special("#{@quantity}".to_i)
        :S.colorize(:yellow)
      when "mythic"
        Counter.mythic("#{@quantity}".to_i)
        :M.colorize(:magenta)
      when "bonus"
        Counter.bonus("#{@quantity}".to_i)
        :B.colorize(:light_blue)
      else
        raise "ERROR: rarities"
      end
    end

    # Sets foil status.
    def foils : Colorize::Object(Symbol)
      case @foil_status
      when "1", "foil"
        Counter.foil("#{@quantity}".to_i)
        :▲.colorize(:light_gray)
      when "etchedFoil"
        Counter.efoil("#{@quantity}".to_i)
        :◭.colorize(:light_gray)
      when "0", ""
        :△.colorize(:dark_gray)
      else
        raise "ERROR: foils"
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

  # Validates provided format.
  def self.check_format(input)
    if !FORMATS.includes? "#{input}"
      if !input.empty?
        STDERR.puts "ERROR: Unknown game format #{input}"
        exit(1)
      end
    end
  end
end
