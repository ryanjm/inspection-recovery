require 'spec_helper'
require 'json'

describe Inspection do

  describe ".load_dictionary" do
    before :all do
      f_data = File.open("example_inspection/inspection.json", "r:UTF-32:UTF-8")
      json = JSON.load(f_data)
      @inspection = Inspection.load_dictionary(json)
    end
    it "loads all inspection attributes from the json" do
      # attributes
      expect(@inspection.score).to eq(0)
      expect(@inspection.longitude).to eq(10.4)
      expect(@inspection.latitude).to eq(11.5)
      expect(@inspection.inspection_form_id).to eq(51793)
      expect(@inspection.flagged).to eq(1)
      expect(@inspection.private).to eq(0)
      expect(@inspection.guid).to eq("1A95219F-0AE0-4786-BF48-036E9B2FEF5C")
      expect(@inspection.user_id).to eq(5603)
      expect(@inspection.name).to eq("Daily Report")
      expect(@inspection.started_at).to eq("2014-10-17 11:15:16 EDT")
      expect(@inspection.structure_id).to eq(111495)
      expect(@inspection.ended_at).to eq("2014-10-17 15:39:04 EDT")
      expect(@inspection.id).to eq(738026)

      # helper method(s)
      expect(@inspection.uploaded?).to eq(true)
    end

    it "loads children objects" do
      expect(@inspection.inspection_items.count).to eq(9)
      expect(@inspection.inspection_item_photos.count).to eq(9)
    end
  end

  describe "#to_dictionary" do
    before :all do
      f_data = File.open("example_inspection/inspection.json", "r:UTF-32:UTF-8")
      @json = JSON.load(f_data)
      @inspection = Inspection.load_dictionary(@json)
    end

    it "returns dictionary to be saved as json" do
      expect(@inspection.to_dictionary).to eq(@json)
    end
  end

end
