tls = require 'tls'

module.exports = class YtDownload
	constructor: (@URL) ->
		conn = tls.connect 443, 'www.youtube.com', ->
			conn.pipe process.stdout
			conn.write 'GET /watch?v=mlt7MrwU4hY HTTP/1.1\r\n' + 'Host: www.youtube.com\r\n' + '\r\n'