require 'spec_helper'
require 'json'

describe InspectionItem do

  describe ".load_dictionary" do
    before :all do
      f_data = File.open("example_inspection/inspection.json", "r:UTF-32:UTF-8")
      json = JSON.load(f_data)
      @item = InspectionItem.load_dictionary(json["inspection_items"][0])
    end
    it "loads all inspection attributes from the json" do
      # attributes
      expect(@item.inspection_id).to eq(738026)
      expect(@item.description).to eq("")
      expect(@item.score).to eq(0.5)
      expect(@item.category_id).to eq(5439)
      expect(@item.updated_at).to eq("2014-10-17 14:29:47 EDT")
      expect(@item.max_score).to eq(3)
      expect(@item.grade).to eq(2)
      expect(@item.guid).to eq("F91C5351-5CF6-46F2-A6EE-E2E970D3D5B6")
      expect(@item.weight).to eq(1)
      expect(@item.name).to eq("100. After - Enter Station # and 100 foot after picture.")
      expect(@item.value).to eq("During")
      expect(@item.position).to eq(6)
      expect(@item.rating_id).to eq(24703)
      expect(@item.min_score).to eq(1)
      expect(@item.id).to eq(17581451)

      # helper method(s)
      expect(@item.uploaded?).to eq(true)
    end
  end

  describe "#to_dictionary" do
    before :all do
      f_data = File.open("example_inspection/inspection.json", "r:UTF-32:UTF-8")
      json = JSON.load(f_data)
      @inspection_item_json = json["inspection_items"][0]
      @item = InspectionItem.load_dictionary(@inspection_item_json)
    end

    it "returns dictionary to be saved as json" do
      expect(@item.to_dictionary).to eq(@inspection_item_json)
    end
  end

  describe "#update_photos" do
    it "updates inspection_id on all related photos" do
      uuid = "ABC-123"
      photo = InspectionItemPhoto.new
      photo.inspection_item_uuid = uuid
      item = InspectionItem.new
      item.guid = uuid
      inspection = Inspection.new
      inspection.inspection_items << item
      inspection.inspection_item_photos << photo
      item.inspection = inspection

      item.id = 123
      item.update_photos

      expect(photo.inspection_item_id).to eq(123)
    end
  end

end
