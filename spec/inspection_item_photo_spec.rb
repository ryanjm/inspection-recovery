require 'spec_helper'

describe InspectionItemPhoto do

  describe ".load_dictionary" do
    before :all do
      f_data = File.open("example_inspection/inspection.json", "r:UTF-32:UTF-8")
      json = JSON.load(f_data)
      @photo = InspectionItemPhoto.load_dictionary(json["inspection_item_photos"][0])
    end
    it "loads all inspection attributes from the json" do
      # attributes
      expect(@photo.id).to eq(0)
      expect(@photo.image_name).to eq("E9D22EBF-E0BC-45F1-8FF8-D47C9314F0C7")
      expect(@photo.inspection_item_uuid).to eq("F91C5351-5CF6-46F2-A6EE-E2E970D3D5B6")
      expect(@photo.inspection_item_id).to eq(17571779)
    end
  end

  describe "#to_dictionary" do
    before :all do
      f_data = File.open("example_inspection/inspection.json", "r:UTF-32:UTF-8")
      json = JSON.load(f_data)
      @inspection_item_photo_json = json["inspection_item_photos"][0]
      @photo = InspectionItemPhoto.load_dictionary(@inspection_item_photo_json)
    end

    it "returns dictionary to be saved as json" do
      expect(@photo.to_dictionary).to eq(@inspection_item_photo_json)
    end
  end

  describe "#uploaded?" do
    it "returns true if the id is higher than 0" do
      photo = InspectionItemPhoto.new
      photo.id= 3
      expect(photo.uploaded?).to be true
    end
    it "returns false if the id isn't higher than 0" do
      photo = InspectionItemPhoto.new
      photo.id = 0
      expect(photo.uploaded?).to be false
    end
  end

  describe "#uploaded_to_remote?" do
    it "returns true if it has a temporary_url is higher than 0" do
      photo = InspectionItemPhoto.new
      photo.temporary_url = "test"
      expect(photo.uploaded_to_remote?).to be true
    end
    it "returns false if the id isn't higher than 0" do
      photo = InspectionItemPhoto.new
      photo.temporary_url = nil
      expect(photo.uploaded_to_remote?).to be false
    end
  end
end
