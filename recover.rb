require './lib/load_inspections'

inspections = LoadInspections.new.upload_inspections

puts "there is #{inspections.length} inspections"

inspections.each do |inspection|
  inspection.upload("demo","[token]",true)
end
