EventEmitter = require('events').EventEmitter

###
# Class to handle file downloads
# @namespace Download
# @extends EventEmitter
###
class DownloadHandler extends EventEmitter
	###
	# Constructor
	###
	constructor: ->
		EventEmitter.call this

module.exports = DownloadHandler