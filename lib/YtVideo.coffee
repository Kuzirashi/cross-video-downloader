tls = require 'tls'
qs 	= require 'querystring'
EventEmitter = require('events').EventEmitter
Format 	= require './Format.coffee'

GET_VIDEO_INFO_PATH = '/get_video_info?el=detailpage&video_id='

module.exports = class YtVideo extends EventEmitter
	constructor: (@Url) ->
		EventEmitter.call this

	getId: ->
		match = @Url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
		if match && match[2].length == 11
			match[2]
		else
			@emit 'error', 'Invalid YouTube link.'
			false

	getInfo: ->
		@Id = @getId()
		if !@Id
			return
		host = 'www.youtube.com'
		path = GET_VIDEO_INFO_PATH + @Id
		raw = ''
		@Formats = []
		self = this
		cleartextStream = tls.connect 443, host, ->
			@on 'data', (d) ->
				raw += d

			@on 'end', =>
				data = qs.parse raw.split("\r\n\r\n")[1].split("\r\n")[1]

				resolutions = data.fmt_list.split(',').map (v) ->
					v = v.split('/')[1]

				encoded = data.url_encoded_fmt_stream_map.split(',').map (v, i) ->
					v = qs.parse v
					self.Formats.push new Format v.fallback_host, v.itag, v.quality, v.type, v.url, resolutions[i]

			@write 'GET ' + path + ' HTTP/1.1\r\n' +
				'Host: ' + host + '\r\n' +
				'Connection: close\r\n' +
				'\r\n'