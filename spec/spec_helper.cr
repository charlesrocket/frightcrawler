require "spec"
require "webmock"
require "../src/frightcrawler"

struct Fixtures
  BULK  = File.read("spec/fixtures/bulk.json")
  CARD  = File.read("spec/fixtures/card.json")
  CARDS = JSON.parse(File.read("spec/fixtures/cards.json")).to_json

  def self.prepare
    WebMock.stub(:get, "https://api.scryfall.com/bulk-data")
      .to_return(body: Fixtures::BULK)
    WebMock.stub(:get, "https://c2.scryfall.com/file/scryfall-bulk/all-cards/all-cards-20220117101233.json")
      .to_return(body_io: IO::Memory.new(Fixtures::CARDS))
    Database.sync
  end
end

def reset
  Counter.reset
end
