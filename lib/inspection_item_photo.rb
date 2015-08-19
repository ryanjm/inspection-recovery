class InspectionItemPhoto

  attr_accessor :id, :image_name, :inspection_item_id, :inspection_item_guid, :temporary_url

  def self.load_dictionary(dictionary)
    item = InspectionItemPhoto.new

    dictionary.each do |key, value|
      if item.respond_to?("#{key}=")
        item.send("#{key}=", value)
      end
    end

    item.image_name = dictionary["imageName"]
    item.inspection_item_guid = dictionary["inspectionItem.guid"]

    item
  end

  def to_dictionary
    dic = {}
    attributes = [:id, :image_name, :inspection_item_id, :inspection_item_guid, :temporary_url]
    attributes.each do |attribute|
      dic[attribute.to_s] = self.send(attribute)
    end

    dic['imageName'] = dic["image_name"]
    dic.delete("image_name")
    dic['inspectionItem.guid'] = dic["inspection_item_guid"]
    dic.delete("inspection_item_guid")

    dic
  end

  def uploaded?
    @id && @id > 0
  end

  def uploaded_to_remote?
    !@temporary_url.nil?
  end

  def upload_dictionary
    dic = self.to_dictionary

    # Delete unneeded items
    dic.delete('id')
    dic.delete('inspectionItem.guid')
    dic["image_name"] = dic["imageName"]
    dic.delete('imageName')

    # Remove nil items
    dic.delete_if { |key, value| value == nil }

    dic
  end
end
