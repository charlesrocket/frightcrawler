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
      Counter.total(2)
      Counter.total(3)
      Counter.get_total.should eq(5)
    end
  end

  describe "#get_unique" do
    it "counts uniques" do
      Counter.unique
      Counter.unique
      Counter.unique
      Counter.get_unique.should eq(3)
    end
  end
end
