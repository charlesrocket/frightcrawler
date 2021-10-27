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

  describe "#csv_layout", tags: "csv" do
    it "checks for AetherHub CSV file layout" do
      Crawler.csv_layout("spec/data/test_ah.csv").should eq("aetherhub file")
    end

    it "checks for Helvault CSV file layout" do
      Crawler.csv_layout("spec/data/test_hv.csv").should eq("helvault file")
    end

    it "checks for Helvault Pro CSV file layout" do
      Crawler.csv_layout("spec/data/test_hvp.csv").should eq("helvault pro file")
    end
  end

  describe "#validate_csv", tags: ["api", "csv"] do
    it "validates CSV file against provided game format" do
      Crawler.validate_csv("spec/data/test_ah.csv", "legacy").should eq("validated")
      Crawler.validate_csv("spec/data/test_hv.csv", "legacy").should eq("validated")
      Crawler.validate_csv("spec/data/test_hvp.csv", "legacy").should eq("validated")
    end
  end
end
