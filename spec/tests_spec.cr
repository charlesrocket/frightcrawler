require "./spec_helper"

Spec.before_suite { Fixtures.prepare }
Spec.before_each { reset }

describe CLI do
  describe ".parse" do
    it "loads cli options" do
      CLI.parse.should be_nil
    end
  end
end

describe Counter do
  it "counts attributes" do
    Engine.validate_csv("spec/data/test_hv.csv", "vintage")
    Counter.get_unique.should eq(9)
    Counter.get_total.should eq(13)
    Counter.get_legal.should eq(10)
    Counter.get_not_legal.should eq(1)
    Counter.get_restricted.should eq(1)
    Counter.get_banned.should eq(1)
    Counter.get_common.should eq(2)
    Counter.get_uncommon.should eq(2)
    Counter.get_rare.should eq(5)
    Counter.get_special.should eq(1)
    Counter.get_mythic.should eq(2)
    Counter.get_bonus.should eq(1)
    Counter.get_foil.should eq(4)
    Counter.get_efoil.should eq(1)
  end
end

describe Database, tags: ["api", "db"] do
  describe ".sync" do
    it "synchronizes db" do
      WebMock.stub(:get, "https://api.scryfall.com/bulk-data")
        .to_return(body: Fixtures::BULK)
      WebMock.stub(:get, "https://c2.scryfall.com/file/scryfall-bulk/all-cards/all-cards-20220117101233.json")
        .to_return(body_io: IO::Memory.new(Fixtures::CARDS))
      Database.sync
      Database.synced.should be_true
    end
  end
end

describe Engine do
  describe Engine::Crawler do
    describe "#legalities" do
      it "returns legality status" do
        card = Engine::Crawler.new "legacy", "bd1751ca-4945-4071-87f1-9d5f282c35f0", "foil", "2"
        card.legalities.should eq(:"  Legal   ".colorize(:green))
      end
    end

    describe "#rarities" do
      it "returns rarity status" do
        card = Engine::Crawler.new "legacy", "bd1751ca-4945-4071-87f1-9d5f282c35f0", "foil", "2"
        card.rarities.should eq(:R.colorize(:light_yellow))
      end
    end

    describe "#foils" do
      it "returns foil status" do
        card = Engine::Crawler.new "legacy", "bd1751ca-4945-4071-87f1-9d5f282c35f0", "foil", "2"
        card.foils.should eq(:"▲".colorize(:light_gray))
      end
    end
  end

  describe ".card_info", tags: "api" do
    it "prints card info for provided id" do
      WebMock.stub(:get, "https://api.scryfall.com/cards/989a3960-0cfc-4eab-ae9e-503b934e9835")
        .to_return(body: Fixtures::CARD)
      Engine.card_info("989a3960-0cfc-4eab-ae9e-503b934e9835").should contain("Servo")
    end
  end

  describe ".format_check" do
    it "checks if provided format is valid." do
      Engine.format_check("premodern").should be_nil
    end
  end

  describe ".csv_layout", tags: "csv" do
    it "checks for helvault csv file layout" do
      Engine.csv_layout("spec/data/test_hv.csv")
      Engine.helvault.should be_true
    end

    it "checks for helvault pro csv file layout" do
      Engine.csv_layout("spec/data/test_hvp.csv")
      Engine.helvaultpro.should be_true
    end

    {% if flag? :extended %}
      it "checks for aetherhub csv file layout" do
        Engine.csv_layout("spec/data/test_ah.csv")
        Engine.aetherhub.should be_true
      end
    {% end %}
  end

  describe ".validate_csv", tags: "csv" do
    it "validates csv helvault file against provided game format" do
      Engine.validate_csv("spec/data/test_hv.csv", "vintage").should be_nil
    end

    it "validates csv helvault pro file against provided game format" do
      Engine.validate_csv("spec/data/test_hvp.csv", "legacy").should be_nil
    end

    {% if flag? :extended %}
      it "validates csv aetherhub file against provided game format" do
        Engine.validate_csv("spec/data/test_ah.csv", "legacy").should be_nil
      end
    {% end %}
  end
end
