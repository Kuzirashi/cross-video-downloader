EventEmitter = require('events').EventEmitter

###
# Class to handle file downloads
# @namespace Download
# @class DownloadHandler
# @extends EventEmitter
###
module.exports = class DownloadHandler extends EventEmitter
	###
	# Constructor
	###
	constructor: ->
		EventEmitter.call this