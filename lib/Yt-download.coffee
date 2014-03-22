tls = require 'tls'
qs = require 'querystring'

GET_VIDEO_INFO_PATH = '/get_video_info?hl=en_US&el=detailpage&video_id='

module.exports = class YtVideo
	constructor: (@Url) ->
		regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
		match = @Url.match regExp
		if match && match[2].length == 11
			@Id = match[2]
		else
			throw new Error 'Invalid YouTube link.'

	getInfo: ->
		host = 'www.youtube.com'
		path = GET_VIDEO_INFO_PATH + @Id
		data = ''
		cleartextStream = tls.connect 443, host, ->
			@on 'data', (d) ->
				data += d
				console.log '[YtVideo::getInfo][Info]: Received ' + d.length + 'bytes'

			@on 'error', (e) ->
				console.log '[YtVideo::getInfo][Error]: ', e

			@on 'end', ->
				console.log '[YtVideo::getInfo][Success]: All data received.'

			console.log '[YtVideo::getInfo][Success]: Connected.'

			@setEncoding 'utf8'
			if @authorizationError
				console.log '[YtVideo::getInfo][Error]: Authorization Error: ' + @authorizationError
			else
				console.log '[YtVideo::getInfo][Success]: Authorized a Secure SSL/TLS Connection.'
			@write 'GET ' + path + ' HTTP/1.1\r\n' +
				'Host: ' + host + '\r\n' +
				'Connection: close\r\n' +
				'\r\n'

		

		

