require 'json'
require 'httmultiparty'
require 'faraday'
require 'pry'

require_relative 'inspection'
require_relative 'inspection_item'
require_relative 'inspection_item_photo'

class UploadInspection
  include HTTMultiParty


  BASE_URL = "orangeqc.com"
  # BASE_URL = "orangeqc-staging.com"
  # BASE_URL = "orangeqc.dev"
  INSPECTION_URL = "/api/v4/inspections"
  INSPECTION_ITEM_URL = "/api/v4/inspection_items"
  INSPECTION_ITEM_PHOTO_URL = "/api/v4/inspection_item_photos"

  attr_accessor :inspection
  attr_accessor :subdomain
  attr_accessor :token
  attr_accessor :dir, :upload_image


  def initialize(dir, upload_image)
    @dir = dir
    @upload_image = upload_image
    f_data = File.open(dir+"/inspection.json","r:UTF-32:UTF-8")
    json = JSON.load(f_data)
    @inspection = Inspection.load_dictionary(json)
  end

  ################################################
  # Methods for checking what type of upload to do
  ################################################

  def upload(subdomain, token)
    @subdomain = subdomain
    @token = token

    @conn = Faraday.new(:url => url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    start_upload
  end

  def save_inspection
    json = JSON.pretty_unparse(@inspection.to_dictionary)

    f = File.open(dir+"/inspection.json", "w:UTF-32:UTF-8")
    f.write(json)
  end


  ################################################
  # Upload methods
  ################################################

  # Stop the next method from being called if there is an error
  # Assumption: the method that returns true, should print what the error is
  def start_upload
    no_error = true # This is the value we expect from each of the following methods

    # Upload inspection
    no_error = upload_inspection

    # Upload inspection items
    no_error = upload_inspection_items if no_error

    # Upload inspection item photos
    no_error = upload_inspection_item_photo_to_remote if no_error

    no_error = upload_inspection_item_photos if no_error

    # Finalize inspection
    finalize_inspection if no_error
  end

  def url
    "http://#{@subdomain}.#{BASE_URL}"
  end

  def inspection_url
    "#{INSPECTION_URL}?user_credentials=#{@token}"
  end

  def inspection_post_url
    "#{INSPECTION_URL}/#{@inspection.id}?user_credentials=#{@token}"
  end

  def inspection_item_url
    "#{INSPECTION_ITEM_URL}?user_credentials=#{@token}"
  end

  def inspection_item_photo_url
    "#{INSPECTION_ITEM_PHOTO_URL}?user_credentials=#{@token}"
  end

  def upload_inspection
    # Don't upload if it is already uploaded
    return true if @inspection.uploaded?

    res = @conn.post inspection_url, { :inspection => @inspection.upload_dictionary }

    if res.status == 200
      @inspection.id = JSON.parse(res.body)["inspection"]["id"]
      @inspection.update_items

      save_inspection
      true
    else
      puts "Inspection failed to upload"
      binding.pry
      false
    end
  end

  def upload_inspection_items
    @inspection.inspection_items.each do |item|

      # Skip if item is already uploaded
      next if item.uploaded?

      res = @conn.post inspection_item_url, { inspection_item: item.upload_dictionary }

      if res.status == 200
        item.id = JSON.parse(res.body)['inspection_item']["id"]
        item.update_photos

        print "."

        save_inspection
      else
        puts "Item (#{item.guid}) for inspection #{item.inspection_id} failed."
        binding.pry
        return false
      end
    end
    print "\n"
    true
  end

  def upload_inspection_item_photo_to_remote
    @inspection.inspection_item_photos.each do |photo|
      # Skip if it has already been uploaded to the remote location
      next if photo.uploaded_to_remote?

      photo.temporary_url = @upload_image.get_url_for_path(@dir + "/", photo.image_name+".png")

      save_inspection
      print "~"
    end
    print "\n"
    true
  end

  def upload_inspection_item_photos
    @inspection.inspection_item_photos.each do |photo|
      # Can't upload to OQC until it is uploaded to a remote location
      unless photo.uploaded_to_remote?
        puts "Photo (#{photo.image_name}) for inspection #{@inspection.id} isn't uploaded to remote yet."
        return false
      end

      if photo.inspection_item_id <= 0
        puts "Related inspection item for photo #{photo.image_name} isn't uploaded"
        return false
      end

      # Skip if it has already been uploaded
      next if photo.uploaded? || !photo.uploaded_to_remote?

      res = @conn.post inspection_item_photo_url, { inspection_item_photo: photo.upload_dictionary }

      if res.status == 200
        photo.id = JSON.parse(res.body)['inspection_item_photo']['id']
        print "!"

        save_inspection
      else
        puts "Photo (#{photo.image_name}) for inspection #{@inspection.id} failed."
        binding.pry
        return false
      end
    end
    print "\n"
    true
  end

  def finalize_inspection
    body = { body: { inspection: @inspection.upload_dictionary } }

    # TODO: Can this be written @conn.put ?
    # self.class.put(url+inspection_post_url, body)

    put_url = url + inspection_post_url
    @conn.put put_url, body

    # @json['inspection'] = res["data"][0]

    puts "#{url}/reports/inspections/?id=#{@inspection.id}&user_credentials=#{@token} has #{@inspection.inspection_items.length} items"
  end

end
