EventEmitter = require('events').EventEmitter
fs = require('fs')

"use strict";
constants = Object.freeze
	'MBLength': 1048576

###
# Class to handle file downloads.
# @namespace Download
# @extends EventEmitter
###
class DownloadHandler extends EventEmitter
	constructor: ->
		EventEmitter.call this

	###
	# Downloads a file.
	# @param {String} url Url of file to download.
	# @param {String} path Where should be file saved.
	# @param {String} filename Name of downloaded file.
	###
	download: (url, path, filename) ->
		@downloadPath = path
		@currentLength = 0;
		@data = ''
		str = path
		if path.length < 1
			return false

		fileDownloadStream = fs.createWriteStream path + '/' + filename
		request = require('http').get url, (response) ->
			response.pipe fileDownloadStream
			rawTotalLength = parseInt(response.headers['content-length'], 10);
			@totalLength = rawTotalLength / constants.MBLength;
			response.on 'data', (chunk) =>
				@data += chunk
				@currentLength += chunk.length
				@emit 'progress', @currentLength, @totalLength

			response.on 'end', =>
				@emit 'end'

			response.on 'error', (error) ->
				console.log 'Error: ' + error.message

module.exports = DownloadHandler