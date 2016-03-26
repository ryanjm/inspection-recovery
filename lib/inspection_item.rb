require_relative 'date_helper'

class InspectionItem
  attr_accessor :inspection_id, :description, :score, :category_id, :updated_at, :range_choice_max_position, :position, :guid, :weight, :comment, :name, :range_choice_position, :rating_id, :range_choice_min_position, :id, :range_choice_label
  attr_accessor :line_item_id # not sure if this is still needed
  attr_accessor :inspection

  def self.load_dictionary(dictionary, inspection = nil)
    item = InspectionItem.new

    item.inspection = inspection

    dictionary.each do |key, value|
      if item.respond_to?("#{key}=")
        item.send("#{key}=", value)
      end
    end

    item
  end

  def to_dictionary
    dic = {}
    attributes = [:inspection_id, :description, :score, :category_id, :updated_at, :range_choice_max_position, :position, :guid, :weight, :comment, :name, :range_choice_position, :rating_id, :range_choice_min_position, :id, :range_choice_label, :line_item_id]
    attributes.each do |attribute|
      dic[attribute.to_s] = self.send(attribute) if self.send(attribute)
    end
    dic
  end

  def uploaded?
    @id && @id > 0
  end

  def upload_dictionary
    dic = self.to_dictionary

    # Delete unneeded items
    # dic.delete('guid')
    dic.delete('id')

    # Update date strings
    dic['updated_at'] = dic['updated_at'].api_date if dic['updated_at']

    # Remove nil items
    dic.delete_if { |key, value| value == nil }

    dic
  end

  def update_photos
    # Select photos which match
    photos = @inspection.inspection_item_photos.select do |photo|
      photo.inspection_item_guid == @guid
    end

    # Update them all with the next inspection_id
    photos.each do |photo|
      photo.inspection_item_id = @id
    end
  end
end
