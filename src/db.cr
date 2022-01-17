# Manages DB data.
module Database
  DB_HOME = Path.home / "frightcrawler"
  DB_FILE = "#{DB_HOME}/frightcrawler.db"

  @@synced = false : Bool

  # Returns synchronization status.
  def self.synced : Bool | Nil
    @@synced
  end

  # Synchronizes DB.
  def self.sync : Nil
    if !Database.synced
      Database.update
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

    bulk_data = JSON.parse(HTTP::Client.get("https://api.scryfall.com/bulk-data").body)
    bulk_link = bulk_data["data"][3]["download_uri"]

    DB.open "sqlite3://#{DB_FILE}" do |db|
      db.exec "create table if not exists cards (id text primary key, name text, set_name text, set_code text, rarity text, legality_standard text,
                        legality_future text, legality_historic text, legality_gladiator text, legality_pioneer text, legality_modern text,
                        legality_legacy text, legality_pauper text, legality_vintage text, legality_penny text, legality_commander text,
                        legality_brawl text, legality_historicbrawl text, legality_paupercommander text, legality_duel text,
                        legality_oldschool text, legality_premodern text, timestamp datetime default current_timestamp)"
      db.exec "BEGIN TRANSACTION;"
      HTTP::Client.get "#{bulk_link}" do |rsp|
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

      db.exec "COMMIT;"
    end

    @@synced = true
    puts "\n  * Database synchronized"
  end
end
