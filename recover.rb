require './lib/load_inspections'

if ARGV.length < 2
  puts "Please pass in subdomain and user access token"
  puts "% ruby recover.rb [SUBDOMAIN] [USER_ACCESS_TOKEN]"
  return
end

subdomain = ARGV[0]
token = ARGV[1]

inspections = LoadInspections.new.upload_inspections

puts "there are #{inspections.length} inspections"

inspections.each do |inspection|
  inspection.upload(subdomain,token)
end
