require "./spec_helper"

describe Bulk, tags: "api" do
  describe "#pull" do
    it "downloads bulk data" do
      Bulk.pull
      File.exists?("bulk-data.json").should be_true
    end
  end
end

describe Counter do
  describe "#get_total" do
    it "counts totals" do
      reset
      Counter.total(2)
      Counter.total(3)
      Counter.get_total.should eq(5)
    end
  end

  describe "#get_unique" do
    it "counts uniques" do
      reset
      Counter.unique
      Counter.unique
      Counter.unique
      Counter.get_unique.should eq(3)
    end
  end
end

describe Crawler do
  describe "#card_info", tags: "api" do
    it "prints card info for provided ID" do
      Crawler.card_info("989a3960-0cfc-4eab-ae9e-503b934e9835").should contain("Servo")
    end
  end

  describe "#check_csv", tags: "csv" do
    it "checks CSV file" do
      Crawler.check_csv("spec/data/test.csv").should eq("helvault file")
    end
  end

  describe "#validate_csv" do
    it "validates CSV file against provided game format" do
      Crawler.check_csv("spec/data/test.csv").should eq("helvault file")
      Crawler.validate_csv("spec/data/test.csv", "legacy").should eq("validated")
    end
  end

  describe "#foils" do
    it "checks foil layout" do
      Crawler.foils("1", "5").should eq(:▲.colorize(:light_gray))
    end

    it "checks etched layout" do
      Crawler.foils("etchedFoil", "1").should eq(:◭.colorize(:light_gray))
    end

    it "checks non-foil layout" do
      Crawler.foils("0", "1").should eq(:△.colorize(:dark_gray))
    end
  end
end
