# make port on 8080, tool for handling reqs, use mount_proc for res
require 'webrick'

root = File.expand_path '../'

server = WEBrick::HTTPServer.new :Port => 8080, 

trap('INT') { server.shutdown }

server.start
server.mount_proc '/' do |req, res|
  res.content_type = 'text/text' 
  res.body = req.path
end
