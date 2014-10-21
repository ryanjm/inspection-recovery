class InspectionItem
  attr_accessor :inspection_id, :description, :score, :category_id, :updated_at, :max_score, :grade, :guid, :weight, :comment, :name, :value, :position, :rating_id, :min_score, :id
  attr_accessor :inspection, :inspection_item_photos

  def self.load_dictionary(dictionary)
    item = InspectionItem.new

    dictionary.each do |key, value|
      if item.respond_to?("#{key}=")
        item.send("#{key}=", value)
      end
    end

    item
  end

  def to_dictionary
    dic = {}
    attributes = [:inspection_id, :description, :score, :category_id, :updated_at, :max_score, :grade, :guid, :weight, :comment, :name, :value, :position, :rating_id, :min_score, :id]
    attributes.each do |attribute|
      dic[attribute.to_s] = self.send(attribute)
    end
    dic
  end

  def uploaded?
    self.id > 0
  end
end
