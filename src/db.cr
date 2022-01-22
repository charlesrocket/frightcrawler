# Manages DB data.
module Database
  DB_HOME = Path.home / "frightcrawler"
  DB_FILE = !Crystal.env.test? ? "#{DB_HOME}/frightcrawler.db" : "#{DB_HOME}/test.db"

  @@synced = false : Bool

  # Returns synchronization status.
  def self.synced : Bool | Nil
    @@synced
  end

  # Synchronizes DB.
  def self.sync : Nil
    if !File.exists?(DB_FILE)
      update
    end

    if !synced
      local_time = Time.utc.to_unix
      sync_time = "#{latest_timestamp}"
      flag_time = 2629743

      if (local_time - sync_time.to_i) >= flag_time
        update
      end
    end

    @@synced = true
  end

  # Returns latest timestamp.
  def self.latest_timestamp : DB::Any
    DB.open "sqlite3://#{DB_FILE}" do |db|
      db.scalar "select strftime('%s', timestamp) from cards order by timestamp desc limit 1;"
    end
  end

  struct Cards
    include DB::Serializable

    getter id : String
    getter name : String
    getter set_name : String
    getter set_code : String
    getter rarity : String
    getter legality : String
  end

  struct Card
    include JSON::Serializable

    getter id : String
    getter name : String
    getter set_name : String

    @[JSON::Field(key: "set")]
    getter set_code : String

    getter rarity : String
    getter legalities : Legalities
  end

  struct Legalities
    include JSON::Serializable

    getter standard : String
    getter future : String
    getter historic : String
    getter gladiator : String
    getter pioneer : String
    getter modern : String
    getter legacy : String
    getter pauper : String
    getter vintage : String
    getter penny : String
    getter commander : String
    getter brawl : String
    getter historicbrawl : String
    getter paupercommander : String
    getter duel : String
    getter oldschool : String
    getter premodern : String
  end

  def self.get_bulk_uri
    bulk_data = JSON.parse(HTTP::Client.get("https://api.scryfall.com/bulk-data").body)
    bulk_data["data"][3]["download_uri"].to_s
  end

  def self.delete : Nil
    File.delete(Database::DB_FILE)
  end

  # Updates DB data.
  def self.update : Nil
    puts "\n  * Database synchronization ..."

    private insert_sql = <<-SQL
    INSERT OR IGNORE INTO "cards" ("id", "name", "set_name", "set_code", "rarity", "legality_standard", "legality_future",
                         "legality_historic", "legality_gladiator", "legality_pioneer", "legality_modern",
                         "legality_legacy", "legality_pauper", "legality_vintage", "legality_penny", "legality_commander",
                         "legality_brawl", "legality_historicbrawl", "legality_paupercommander", "legality_duel",
                         "legality_oldschool", "legality_premodern")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    SQL

    DB.open "sqlite3://#{DB_FILE}" do |db|
      db.exec "create table if not exists cards (id text primary key, name text, set_name text, set_code text, rarity text, legality_standard text,
                        legality_future text, legality_historic text, legality_gladiator text, legality_pioneer text, legality_modern text,
                        legality_legacy text, legality_pauper text, legality_vintage text, legality_penny text, legality_commander text,
                        legality_brawl text, legality_historicbrawl text, legality_paupercommander text, legality_duel text,
                        legality_oldschool text, legality_premodern text, timestamp datetime)"
      db.exec "BEGIN TRANSACTION;"

      HTTP::Client.get "#{get_bulk_uri}" do |rsp|
        Array(Card).from_json(rsp.body_io) do |card|
          db.exec(
            insert_sql,
            card.id,
            card.name,
            card.set_name,
            card.set_code,
            card.rarity,
            card.legalities.standard,
            card.legalities.future,
            card.legalities.historic,
            card.legalities.gladiator,
            card.legalities.pioneer,
            card.legalities.modern,
            card.legalities.legacy,
            card.legalities.pauper,
            card.legalities.vintage,
            card.legalities.penny,
            card.legalities.commander,
            card.legalities.brawl,
            card.legalities.historicbrawl,
            card.legalities.paupercommander,
            card.legalities.duel,
            card.legalities.oldschool,
            card.legalities.premodern,
          )
        end
      end

      db.exec "update cards set timestamp=current_timestamp;"
      db.exec "COMMIT;"
    end

    puts "\n  * Database synchronized"
  end
end
