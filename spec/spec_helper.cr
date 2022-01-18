require "spec"
require "webmock"
require "../src/frightcrawler"

struct Fixtures
  BULK  = File.read("spec/fixtures/bulk.json")
  CARD  = File.read("spec/fixtures/card.json")
  CARDS = JSON.parse(File.read("spec/fixtures/cards.json")).to_json
end

def reset
  Counter.reset
end
