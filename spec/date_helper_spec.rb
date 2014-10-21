require 'spec_helper'

describe String do

  describe "#api_date" do
    it "fixes strings coming from objc to ruby" do
      expect("2014-10-17 15:39:04 EDT".api_date).to eq("2014-10-17 15:39:04 -0400")
    end
  end

end

