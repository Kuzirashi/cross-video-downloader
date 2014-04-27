module.exports = class Format
	constructor: (@fallbackHost, @itag, @quality, @type, @url, @resolution) ->
		match = @type.match /\/([a-z0-9-]+)/
		@type = if match && match[1] != 'x-flv' then match[1] else 'flv'