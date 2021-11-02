require "./spec_helper"

Spec.before_each { reset }

describe Bulk::Puller, tags: "api" do
  describe ".update" do
    it "downloads bulk data" do
      Bulk::Puller.update
      File.exists?("bulk-data.json").should be_true
    end
  end
end

describe Counter do
  describe ".get_total" do
    it "counts totals" do
      Counter.total(2)
      Counter.total(3)
      Counter.get_total.should eq(5)
    end
  end

  describe ".get_unique" do
    it "counts uniques" do
      Counter.unique
      Counter.unique
      Counter.unique
      Counter.get_unique.should eq(3)
    end
  end
end

describe Engine do
  describe ".card_info", tags: "api" do
    it "prints card info for provided ID" do
      Engine.card_info("989a3960-0cfc-4eab-ae9e-503b934e9835").should contain("Servo")
    end
  end

  describe ".csv_layout", tags: "csv" do
    it "checks for Helvault CSV file layout" do
      Engine.csv_layout("spec/data/test_hv.csv").should eq("helvault file")
    end

    it "checks for Helvault Pro CSV file layout" do
      Engine.csv_layout("spec/data/test_hvp.csv").should eq("helvault pro file")
    end

    {% if flag? :extended %}
      it "checks for AetherHub CSV file layout" do
        Engine.csv_layout("spec/data/test_ah.csv").should eq("aetherhub file")
      end
    {% end %}
  end

  describe ".validate_csv", tags: ["api", "csv"] do
    it "validates CSV Helvault file against provided game format" do
      Engine.validate_csv("spec/data/test_hv.csv", "legacy").should eq("validated")
    end

    it "validates CSV Helvault Pro file against provided game format" do
      Engine.validate_csv("spec/data/test_hvp.csv", "legacy").should eq("validated")
    end

    {% if flag? :extended %}
      it "validates CSV AetherHub file against provided game format" do
        Engine.validate_csv("spec/data/test_ah.csv", "legacy").should eq("validated")
      end
    {% end %}
  end
end
