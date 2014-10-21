require_relative 'inspection_item'
require_relative 'inspection_item_photo'

class Inspection
  attr_accessor :score, :latitude, :longitude, :inspection_form_id, :flagged, :private, :guid, :user_id, :name, :started_at, :structure_id, :ended_at, :id
  attr_accessor :inspection_items, :inspection_item_photos

  def self.load_dictionary(dictionary)
    inspection = Inspection.new

    dictionary["inspection"].each do |key, value|
      if inspection.respond_to?("#{key}=")
        inspection.send("#{key}=", value)
      end
    end

    dictionary["inspection_items"].each do |inspection_item|
      inspection.inspection_items << InspectionItem.load_dictionary(inspection_item, inspection)
    end

    dictionary["inspection_item_photos"].each do |inspection_item_photo|
      inspection.inspection_item_photos << InspectionItemPhoto.load_dictionary(inspection_item_photo)
    end

    inspection
  end

  def initialize
    self.inspection_items = []
    self.inspection_item_photos = []
  end

  def uploaded?
    id > 0
  end

  def inspection_dictionary
    dic = {}
    attributes = [:score, :latitude, :longitude, :inspection_form_id, :flagged, :private, :guid, :user_id, :name, :started_at, :structure_id, :ended_at, :id]
    attributes.each do |attribute|
      dic[attribute.to_s] = self.send(attribute)
    end
    dic
  end

  def to_dictionary
    {
      "inspection_items" => self.inspection_items.map(&:to_dictionary),
      "inspection" => self.inspection_dictionary,
      "inspection_item_photos" => self.inspection_item_photos.map(&:to_dictionary)
    }
  end

  def upload_dictionary
    dic = self.inspection_dictionary

    # Update date strings
    dic['started_at'] = dic['started_at'].api_date
    dic['ended_at'] = dic['ended_at'].api_date

    dic
  end

  def update_items
    self.inspection_items.each do |item|
      item.inspection_id = @id
    end
  end

end
