require "spec"
require "../src/frightcrawler"

def reset
  Counter.reset
end

def prepare
  Bulk.pull
end

def get_json
  x = 0
  prepare
  bulk_json = JSON.parse(File.read("bulk-data.json"))
  until bulk_json[x]["id"] == "bd1751ca-4945-4071-87f1-9d5f282c35f0"
    x += 1
  end
  json = bulk_json[x]
end
