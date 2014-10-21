class InspectionItemPhoto

  attr_accessor :id, :image_name, :inspection_item_id, :inspection_item_uuid, :temporary_url

  def self.load_dictionary(dictionary)
    item = InspectionItemPhoto.new

    dictionary.each do |key, value|
      if item.respond_to?("#{key}=")
        item.send("#{key}=", value)
      end
    end

    item.image_name = dictionary["imageName"]
    item.inspection_item_uuid = dictionary["inspectionItem.uuid"]

    item
  end

  def to_dictionary
    dic = {}
    attributes = [:id, :image_name, :inspection_item_id, :inspection_item_uuid]
    attributes.each do |attribute|
      dic[attribute.to_s] = self.send(attribute)
    end

    dic['imageName'] = dic["image_name"]
    dic.delete("image_name")
    dic['inspectionItem.uuid'] = dic["inspection_item_uuid"]
    dic.delete("inspection_item_uuid")

    dic
  end

  def uploaded?
    self.id > 0
  end

  def uploaded_to_remote?
    !self.temporary_url.nil?
  end
end
