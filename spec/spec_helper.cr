require "spec"
require "crystal-env/spec"
require "webmock"

require "../src/frightcrawler"

module Fixtures
  struct Data
    BULK  = File.read("spec/fixtures/bulk.json")
    CARD  = File.read("spec/fixtures/card.json")
    CARDS = JSON.parse(File.read("spec/fixtures/cards.json")).to_json
  end

  def self.prepare
    WebMock.stub(:get, "https://api.scryfall.com/bulk-data")
      .to_return(body: Fixtures::Data::BULK)
    WebMock.stub(:get, "https://c2.scryfall.com/file/scryfall-bulk/all-cards/all-cards-20220117101233.json")
      .to_return(body_io: IO::Memory.new(Fixtures::Data::CARDS))
    Database.sync
  end
end

def reset
  CLI.set_speed
  Counter.reset
  WebMock.reset
  Fixtures.prepare
end

def clean
  return unless File.exists?(Database::DB_FILE)
  Database.delete
end
