require 'json'
require 'net/http'
require 'uri'

class UploadInspection 
  
  BASE_URL = "orangeqc.dev/api"
  INSPECTION_URL = "/v3/inspections"
  INSPECTION_ITEM_URL = "/v3/inspection_items"

  attr_accessor :json
  attr_accessor :dir
  attr_accessor :subdomain
  attr_accessor :token

  def initialize(dir)
    @json = JSON.load(File.open(dir+"/inspection.json"))
    @dir = dir
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
      id = item['inspection_id'] if item['inspection_id']
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
    "#{@subdomain}.#{BASE_URL}"
  end

  def inspection_url
    "#{INSPECTION_URL}?single_access_token=#{@token}"
  end

  def inspection_item_url
    "#{INSPECTION_ITEM_URL}?single_access_token=#{@token}"
  end

  # Due to some bugs, we want to clean up the inspection item
  def clean_inspection_item(item, pos)
    # Fix position
    item['position'] = pos
    # Rename item_id
    item['line_item_id'] = item['item_id']
    item.delete('item_id')

    item
  end

  def upload_inspection
    puts "url: #{url}"
    http = Net::HTTP.new(url)

    request = Net::HTTP::Put.new(inspection_url)
    request.set_form_data(@json['inspection'])
    response = http.request(request)
    puts response.body
  end

  def upload_inspection_items(items)
    
  end

  def finalize_inspection
    
  end


end
