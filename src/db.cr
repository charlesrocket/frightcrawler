module Database
  @@synced = false : Bool

  struct Cards
    include DB::Serializable

    getter id : String
    getter name : String
    getter set_name : String
    getter set_code : String
    getter rarity : String
    getter legality_standard : String
    getter legality_future : String
    getter legality_historic : String
    getter legality_gladiator : String
    getter legality_pioneer : String
    getter legality_modern : String
    getter legality_legacy : String
    getter legality_pauper : String
    getter legality_vintage : String
    getter legality_penny : String
    getter legality_commander : String
    getter legality_brawl : String
    getter legality_historicbrawl : String
    getter legality_paupercommander : String
    getter legality_duel : String
    getter legality_oldschool : String
    getter legality_premodern : String
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

    @[JSON::Field(key: "standard")]
    getter standard : String

    @[JSON::Field(key: "future")]
    getter future : String

    @[JSON::Field(key: "historic")]
    getter historic : String

    @[JSON::Field(key: "gladiator")]
    getter gladiator : String

    @[JSON::Field(key: "pioneer")]
    getter pioneer : String

    @[JSON::Field(key: "modern")]
    getter modern : String

    @[JSON::Field(key: "legacy")]
    getter legacy : String

    @[JSON::Field(key: "pauper")]
    getter pauper : String

    @[JSON::Field(key: "vintage")]
    getter vintage : String

    @[JSON::Field(key: "penny")]
    getter penny : String

    @[JSON::Field(key: "commander")]
    getter commander : String

    @[JSON::Field(key: "brawl")]
    getter brawl : String

    @[JSON::Field(key: "historicbrawl")]
    getter historicbrawl : String

    @[JSON::Field(key: "paupercommander")]
    getter paupercommander : String

    @[JSON::Field(key: "duel")]
    getter duel : String

    @[JSON::Field(key: "oldschool")]
    getter oldschool : String

    @[JSON::Field(key: "premodern")]
    getter premodern : String
  end

  def self.synced : Bool | Nil
    @@synced
  end

  def self.sync : Bool | Nil
    if !Database.synced
      Database.update
    end
  end

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

    DB.open "sqlite3://./frightcrawler.db" do |db|
      db.exec "create table if not exists cards (id text primary key, name text, set_name text, set_code text, rarity text, legality_standard text,
                        legality_future text, legality_historic text, legality_gladiator text, legality_pioneer text, legality_modern text,
                        legality_legacy text, legality_pauper text, legality_vintage text, legality_penny text, legality_commander text,
                        legality_brawl text, legality_historicbrawl text, legality_paupercommander text, legality_duel text,
                        legality_oldschool text, legality_premodern text)"
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
