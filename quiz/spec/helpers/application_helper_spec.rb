require_relative '../spec_helper'

describe ApplicationHelper do
  describe "#pounds" do
    it "formats integer amounts as pounds" do
      helper.pounds(1).should == "&pound;1"
      helper.pounds(1000).should == "&pound;1,000"
    end

    it "formats small amounts as penses" do
      helper.pounds(0).should == "0p"
      helper.pounds(0.50).should == "50p"
    end

    it "formats decimal amounts with precision = 2" do
      helper.pounds(1.25).should == "&pound;1.25"
      helper.pounds(1.20).should == "&pound;1.20"
    end
  end
end