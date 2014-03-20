require 'json'
require 'httmultiparty'
require 'pry'
require 'faraday'

class UploadInspection 
  include HTTMultiParty

  
  BASE_URL = "orangeqc.com"
  INSPECTION_URL = "/api/v3/inspections"
  INSPECTION_ITEM_URL = "/api/v3/inspection_items"

  attr_accessor :json
  attr_accessor :dir
  attr_accessor :subdomain
  attr_accessor :token
  attr_accessor :image_tracking

  def initialize(dir)
    # required right now for iOS7
    f_data = File.open(dir+"/inspection.json", "r:UTF-32:UTF-8")
    # f_data = File.open(dir+"/inspection.json")
    @json = JSON.load(f_data)
    @dir = dir
    @image_tracking = {}
  end

  ################################################
  # Methods for checking what type of upload to do
  ################################################

  # Check to see if the inspection has an id
  def inspection_has_id?
    @json['inspection'].has_key?('id')
  end

  # Check to see if any of the items have an id
  def inspection_item_has_id
    items = @json['inspection_items']
    id = nil
    items.each do |item|
      temp_id = item['inspection_id']
      id = temp_id if temp_id && temp_id.to_i != -1
    end
    id
  end

  def force_upload
    @json['inspection'].delete('id')
    @json['inspection_items'].each do |item| 
      item.delete('id')
      item.delete('inspection_id')
    end
  end


  def upload(subdomain, token, force = false)
    force_upload if force
    @subdomain = subdomain
    @token = token

    # Don't upload if it already has an id
    return if inspection_has_id?

    @conn = Faraday.new(:url => url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end


    # Finish uploading if it is a partial upload
    if id = inspection_item_has_id
      finish_upload(id)
    else
      new_upload
    end

    # TODO: save back to file
  end


  ################################################
  # Upload methods
  ################################################

  def new_upload
    # Upload inspection
    upload_inspection
    # Upload inspection items
    upload_inspection_items(@json['inspection_items'])
    # Finalize inspection
    finalize_inspection
  end

  def finish_upload(id)
    # Grab inspection items without ids
    items = @json['inspection_items'].select {|item| !item.has_key('inspection_id') }
    # Upload inspection items
    upload_inspection_items(items)
    # Finalize inspection
    finalize_inspection
  end
  
  def url
    "http://#{@subdomain}.#{BASE_URL}"
  end

  def inspection_url
    "#{INSPECTION_URL}?user_credentials=#{@token}"
  end

  def inspection_post_url
    "#{INSPECTION_URL}/#{@json['inspection']['id']}?user_credentials=#{@token}"
  end

  def inspection_item_url
    "#{INSPECTION_ITEM_URL}?user_credentials=#{@token}"
  end

  def format_date(date)
    # Old format: 2013-04-05T13:42:15-0600:00
    # New format: 2013-04-08 19:03:00 +0000
    # 2014-03-16 23:11:47 MDT
    d = DateTime.strptime(date, '%Y-%m-%d %H:%M:%S %Z')
    d.strftime("%Y-%m-%d %H:%M:%S %z")
  end
  # Due to some bugs, we want to clean up the inspection item
  def clean_inspection_item(item, pos)
    # Fix position
    item['position'] = pos
    # Rename item_id
    item['line_item_id'] = item['item_id']
    item.delete('item_id')

    item['updated_at'] = format_date(item['updated_at']) if item['updated_at']
    item['inspection_id'] = @json['inspection']['id']

    item.delete('image_name')
    item.delete_if { |key, value| value == nil }

    item
  end

  def clean_inspection(inspection)
    inspection['started_at'] = format_date(inspection['started_at'])
    inspection['ended_at'] = format_date(inspection['ended_at'])

    inspection.delete('uploaded')

    inspection
  end

  def upload_inspection
    # right now it looks like it is in the right format, just not saving it properly
    inspection = clean_inspection(@json['inspection'])
    # body = { :body => {:inspection => inspection }}
    # res = self.class.post(url+inspection_url, body)

    res = @conn.post inspection_url, { :inspection => inspection }

    if res.status == 200 # res["data"]
      # @json['inspection'] = res["data"][0]
      @json['inspection'] = JSON.parse(res.body)["data"][0]
    else
      puts "Inspection failed"
      binding.pry
    end
  end

  def upload_inspection_items(items)
    items.each_with_index do |item, index|
      i = clean_inspection_item(item.dup, index)
      # This will be for future versions
      # photo = dir+"/#{i['name']}_#{i['position']}.png"
      
      photo = "#{dir}/#{item['image_name']}.png"
      has_photo = false

      if File.exists?(photo)
        f = Faraday::UploadIO.new(photo, 'image/png')
        i['inspection_item_photos_attributes'] = [{"photo"=>f}]
        has_photo = true
      end

      res = @conn.post inspection_item_url, { inspection_item: i }

      if res.status == 200
        item = JSON.parse(res.body)['data'][0]
        print has_photo ? "!" : "."
      else
        puts "Item for inspection #{@json['inspection']['id']} failed (#{@dir})."
        binding.pry
      end
    end
    print "\n"
  end

  def finalize_inspection
    inspection = @json['inspection']
    body = { :body => {:inspection => inspection }}
    self.class.put(url+inspection_post_url, body)

    # @json['inspection'] = res["data"][0]

    puts "#{url}/reports/inspections/?id=#{@json['inspection']['id']}&user_credentials=#{@token} has #{@json['inspection_items'].length} items"
  end


end
