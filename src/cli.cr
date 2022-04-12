# Handles CLI options.
module CLI
  def self.speed : String | Nil
    @@speed
  end

  def self.set_speed(speed : String = "fast") : Nil
    @@speed = speed
  end

  def self.parse : Nil
    csv_file : String? = nil
    game_format_in : String = ""
    sf_id : String = ""

    OptionParser.parse do |parser|
      parser.on("-f CSV_FILE", "Path to CSV file") { |_csv_file| csv_file = _csv_file }
      parser.on("-g GAME_FORMAT", "Set game format") { |_game_format_in| game_format_in = _game_format_in }
      parser.on("-p SPEED", "Set speed [slow/normal/#{"fast".colorize.mode(:underline)}]") { |_speed| @@speed = _speed }
      parser.on("-i SCRYFALL_ID", "Get card info") { |_sf_id| sf_id = _sf_id }
      parser.on("-s", "--sync", "Sync DB") { Database.resync }
      parser.on("-d", "--force-sync", "Force sync DB") { Database.force_sync }
      parser.on("-h", "--help", "Print documentation") do
        parser.banner = "Usage: frightcrawler -g modern -f PATH/TO/FILE"
        parser.separator("Supported CSV layouts: Helvault, Helvault Pro, AetherHub.")
        parser.separator(%(Supported formats: #{Core::FORMATS.to_s.strip("[]")}))
        puts parser
        exit
      end

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option"
        STDERR.puts parser
        exit(1)
      end
    end

    if !sf_id.empty?
      puts Engine.card_info(sf_id)
    end

    if csv_file != nil
      Engine.validate_csv("#{csv_file}", game_format_in)
    end

    if csv_file == nil && sf_id.empty? && game_format_in.empty?
      puts "\nNo data provided"
      puts "Exiting now"
    end
  end
end
