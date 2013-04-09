require './lib/upload_inspection.rb'

# This class is responsible for loading each folder
# into an upload_inspection

class LoadInspections

  # should hold uploadInspection objcts
  attr_accessor :upload_inspections

  # Returns an array of directories under /inspections
  def list_of_directories
    Dir.entries("./inspections").select {|d| !d.start_with?(".") }
  end

  # Takes directories and loads each json into an upload_inspection
  def create_uploads(dirs)
    dirs.map do |dir|
      UploadInspection.new("./inspections/"+dir)
    end
  end

  def initialize
    dirs = list_of_directories
    if dirs && dirs.length > 0
      @upload_inspections = create_uploads(dirs)
    else
      puts "There are no folders under ./inspections"
    end

    self
  end

end
