require_relative 'lib/load_inspections'

if ARGV.length < 2
  puts "Please pass in subdomain and user access token"
  puts "% ruby recover.rb [SUBDOMAIN] [USER_ACCESS_TOKEN]"
  return
end
subdomain = ARGV[0]
token = ARGV[1]

# puts "Subdomain:"
# subdomain = gets.strip
# puts "Single access token:"
# token = gets.strip

# std in uses the args so we have to remove them
# https://stackoverflow.com/questions/6965885/ruby-readline-fails-if-process-started-with-arguments
# while (l = $stdin.gets.chomp!) do
# end

inspections = LoadInspections.new.upload_inspections

puts "there are #{inspections.length} inspections"

inspections.each do |inspection|
  inspection.upload(subdomain,token)
end
