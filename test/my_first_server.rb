require 'webrick'
#require '../lib/rails_lite'
require 'active_support/core_ext'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }



server.mount_proc '/' do |req, res|
  res.content_type = "text/text"
  res.body = req.path
end

server.start