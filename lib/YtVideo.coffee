tls = require 'tls'
qs = require 'querystring'
Format = require './Format.coffee'

GET_VIDEO_INFO_PATH = '/get_video_info?el=detailpage&video_id='

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
		raw = ''
		@Formats = []
		self = this
		cleartextStream = tls.connect 443, host, ->
			@on 'data', (d) ->
				raw += d

			@on 'error', (e) ->
				console.log '[YtVideo::getInfo][Error]: ', e

			@on 'end', =>
				data = qs.parse raw
				encoded = qs.parse data.url_encoded_fmt_stream_map
				console.log encoded
				resolutions = data.fmt_list
				newAr = []
				for res, i in resolutions.split ','
					newAr[i] = res.split '/'

				for el, i in encoded.quality
					if Array.isArray encoded.fallback_host
						fallback_host = encoded.fallback_host[i]
					else
						fallback_host = encoded.fallback_host

					if el.match /,/
						el.split ','
						el = el[0]

					self.Formats.push new Format fallback_host, encoded.itag[i], el, encoded.type[i], encoded.url[i], newAr[i][1]
				console.log self.Formats


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