require 'pry'
require 'json'

path = Dir.pwd + "/lib/*.rb"
files = Dir[path]

files.each { |f| require f }

