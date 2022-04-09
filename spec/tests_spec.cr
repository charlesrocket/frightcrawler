require "./spec_helper"

Spec.before_suite { clean; Fixtures.prepare }
Spec.after_suite { clean }
Spec.before_each { clean; reset }

describe CLI do
  describe ".speed" do
    it "returns processing speed" do
      CLI.speed.should eq("fast")
    end
  end

  describe ".set_speed" do
    it "sets processing speed to slow" do
      CLI.set_speed("slow")
      Engine.validate_csv("spec/data/test_hv.csv", "vintage")
      CLI.speed.should eq("slow")
    end

    it "sets processing speed to normal" do
      CLI.set_speed("normal")
      Engine.validate_csv("spec/data/test_hv.csv", "vintage")
      CLI.speed.should eq("normal")
    end

    it "sets processing speed to fast" do
      CLI.set_speed("fast")
      Engine.validate_csv("spec/data/test_hv.csv", "vintage")
      CLI.speed.should eq("fast")
    end

    it "uses default processing speed with no input value" do
      CLI.set_speed
      Engine.validate_csv("spec/data/test_hv.csv", "vintage")
      CLI.speed.should eq("fast")
      expect_raises(Exception, "ERROR: Unsupported speed value foo") do
        CLI.set_speed("foo")
        Engine.validate_csv("spec/data/test_hv.csv", "vintage")
      end
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
  describe ".bulk_uri" do
    it "returns bulk file uri" do
      WebMock.stub(:get, "https://api.scryfall.com/bulk-data")
        .to_return(body: Fixtures::Data::BULK)
      Database.bulk_uri.should eq("https://c2.scryfall.com/file/scryfall-bulk/all-cards/all-cards-20220117101233.json")
    end
  end

  describe ".sync" do
    it "synchronizes db" do
      Database.sync
      Database.synced.should be_true
    end
  end

  describe ".force_sync" do
    it "forces db synchronization" do
      Database.force_sync
      Database.synced.should be_true
    end
  end

  describe ".delete" do
    it "erases db" do
      if !File.exists?(Database::DB_FILE)
        File.touch(Database::DB_FILE)
      end
      File.exists?(Database::DB_FILE).should be_true
      Database.delete
      File.exists?(Database::DB_FILE).should be_false
      expect_raises(Exception, "ERROR: No DB file") do
        Database.delete
      end
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
        .to_return(body: Fixtures::Data::CARD)
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
      expect_raises(Exception, "ERROR: Unsupported CSV layout") do
        Engine.validate_csv("spec/data/test_hv_invalid.csv", "vintage")
      end
    end

    it "validates csv helvault pro file against provided game format" do
      Engine.validate_csv("spec/data/test_hvp.csv", "legacy").should be_nil
      expect_raises(Exception, "ERROR: Unsupported CSV layout") do
        Engine.validate_csv("spec/data/test_hv_invalid.csv", "vintage")
      end
    end

    {% if flag? :extended %}
      it "validates csv aetherhub file against provided game format" do
        Engine.validate_csv("spec/data/test_ah.csv", "legacy").should be_nil
        expect_raises(Exception, "ERROR: Unknown game format foo") do
          Engine.validate_csv("spec/data/test_ah.csv", "foo")
        end
      end
    {% end %}
  end
end
