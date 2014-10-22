require 'dropbox_sdk'

# Based on: https://www.dropbox.com/developers/core/start/ruby

class UploadImage

  APP_KEY = 'ijp7b3fkvetxd8d'
  APP_SECRET = '1dr7yne3hh3vedk'

  attr_accessor :client, :access_token

  def initialize
    flow = DropboxOAuth2FlowNoRedirect.new(APP_KEY, APP_SECRET)

    authorize_url = flow.start()

    @access_token = "DYQc5jn3qXYAAAAAAAAJsOyUcfeW7657nUNS-1aMzS43m_ENsl19wXAjSoVpljEz"

    if @access_token.nil?
      # Have the user sign in and authorize this app
      puts '1. Go to: ' + authorize_url
      puts '2. Click "Allow" (you might have to log in first)'
      puts '3. Copy the authorization code'
      print 'Enter the authorization code here: '
      code = gets.strip

      # This will fail if the user gave us an invalid authorization code
      @access_token, user_id = flow.finish(code)
    end

    @client = DropboxClient.new(@access_token)
    # puts "linked account: #{client.account_info().inspect}"
  end

  # Uploads photo to dropbox and then returns the share link for it
  def get_url_for_path(path, name)
    file = File.open(path+name)
    @client.put_file(name, file)

    @client.media(name)["url"]
  end

end
