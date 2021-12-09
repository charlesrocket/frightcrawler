# Handles CLI options.
module CLI
  def self.parse : Nil
    csv_file : String? = nil
    game_format_in : String = ""
    sf_id : String = ""
    speed : String = "normal"

    OptionParser.parse do |parser|
      parser.on("-f CSV_FILE", "Path to CSV file") { |_csv_file| csv_file = _csv_file }
      parser.on("-g GAME_FORMAT", "Set game format") { |_game_format_in| game_format_in = _game_format_in }
      parser.on("-i SCRYFALL_ID", "Get card info") { |_sf_id| sf_id = _sf_id }
      parser.on("-p SPEED", "--speed=SPEED", "Change speed (slow/fast)") { |_speed| speed = _speed }
      parser.on("-s", "--sync", "Sync DB") { Database.sync }
      parser.on("-h", "--help", "Print documentation") do
        parser.banner = "Usage: frightcrawler -g modern -f PATH/TO/FILE"
        parser.separator("Supported CSV layouts: Helvault, Helvault Pro, AetherHub.")
        parser.separator(%(Supported formats: #{FORMATS.to_s.strip("[]")}))
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
      puts Engine.card_info("#{sf_id}")
    end

    if csv_file != nil
      Engine.validate_csv("#{csv_file}", "#{game_format_in}", "#{speed}")
    end

    if csv_file == nil && sf_id.empty? && game_format_in.empty?
      puts "\nNo data provided. Exiting."
    end
  end
end
