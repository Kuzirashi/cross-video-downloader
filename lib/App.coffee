YtVideo = require './lib/modules/YtVideo.coffee'
DownloadHandler = require './lib/modules/DownloadHandler.coffee'
Column = require('./lib/modules/Column.coffee');

window.App = Em.Application.create()

DS.JSONSerializer.reopen
	serializeHasMany: (record, json, relationship) ->
		key = relationship.key
		relationshipType = DS.RelationshipChange.determineRelationshipType record.constructor, relationship

		if relationshipType == 'manyToNone' || relationshipType == 'manyToMany' || relationshipType == 'manyToOne'
			json[key] = Em.get(record, key).mapBy 'id'

App.ApplicationAdapter = DS.FixtureAdapter.extend()

App.Format = DS.Model.extend
	video: DS.belongsTo 'video'
	itag: DS.attr 'string'
	quality: DS.attr 'string'
	resolution: DS.attr 'string'
	type: DS.attr 'string'
	url: DS.attr 'string'
	label: (->
		@get('quality') + ' ' + @get('resolution') + ' ' + @get('type')
	).property 'quality', 'resolution', 'type'

App.Video = DS.Model.extend
	title: DS.attr 'string'
	thumbnailUrl: DS.attr 'string'
	formats: DS.hasMany 'format', async: true
	filenameTitle: (->
		@get('title').replace /[\\/:"*?<>|]+/g, ''
	).property 'title'

App.Router.map ->
	@route 'queue'
	@route 'about'
	@route 'preferences'
	@route 'video', path: 'video/:video_id'

App.IndexRoute = Em.Route.extend
	actions:
		parse: ->
			ytVideo = new YtVideo @get 'controller.link'

			ytVideo.on 'error', (e) ->
				alert e

			self = this
			ytVideo.on 'info', ->
				video = self.store.createRecord 'video', id: @Id, title: @Title, thumbnailUrl: @ThumbnailUrl

				@Formats.map (i) ->
					format = self.store.createRecord 'format', itag: i.itag, quality: i.quality, resolution: i.resolution, type: i.type, url: i.url
					video.get('formats').then (f) ->
						f.pushObject format

				self.transitionToAnimated 'video', main: 'fade', @Id

			ytVideo.getInfo()

App.ConfigKey = Em.Object.extend
	Name: ''
	DefaultValue: ''
	Value: ''

##
# @class Config
# @namespace Application
App.Config = Em.Object.extend
	keys: [
		App.ConfigKey.create
			Name: 'downloadPath'
			DefaultValue: ''
		App.ConfigKey.create
			Name: 'language'
			DefaultValue: 'en'
		App.ConfigKey.create
			Name: 'platform'
			DefaultValue: 'windows'
	]

	columns: [
		new Column 'Id', 'INTEGER', false, true, true
		new Column 'Key', 'TEXT', true, false, false, true
		new Column 'Value', 'TEXT'
	]

	##
	# Method to get complete SQL code to create Config table.
	# @return {String} SQL code for Config table.
	# @memberof Config
	getCreateTableSQL: ->
		columns = @get 'columns'
		len = columns.length
		columnsSQL = ''
		for column, i in columns
			columnsSQL += if len - 1 is i then column.getSQL() else column.getSQL() + ', '
		'CREATE TABLE IF NOT EXISTS `config` (' + columnsSQL + ')'

	insert: (database, createTable) ->
		columns = @get 'columns'
		colNames = ''
		len = columns.length
		for column, i in columns when column.Name isnt 'Id'
			colNames += if len-1 is i then '`' + column.Name + '`' else '`' + column.Name + '`, '
		keys = @get 'keys'
		database.transaction (tx) =>
			if createTable
				tx.executeSql @getCreateTableSQL()
			for key in keys
				value = if !!key.get 'Value' then key.get 'Value' else key.get 'DefaultValue'
				tx.executeSql 'INSERT INTO `config` (' + colNames + ') VALUES ("' + key.get('Name') + '", "' + value + '")'
	

	setValue: (key, value, db) ->
		db.transaction (tx) ->
			tx.executeSql 'UPDATE `config` SET `Value` = "' + value + '" WHERE `Key` = "' + key + '"'
		@get('keys').filterBy('Name', key)[0].set 'Value', value

	getLatestData: (db) ->
		that = this
		db.transaction (tx) =>
			tx.executeSql 'SELECT * FROM `config`', [], (tx, result) ->
				for row, i in result.rows
					that.get('keys')[i].set 'Value', result.rows.item(i).Value

	resetConfig: (db) ->
		db.transaction (tx) ->
			tx.executeSql 'DROP TABLE `config`'
			location.reload()

db = openDatabase 'app-db', '1.0', 'Cross platform YouTube downloader database.', 2 * 1024 * 1024

config = App.Config.create()
config.insert db, true
config.setValue 'platform', os.platform(), db

App.PreferencesController = Em.Controller.extend
	model: config
	directory: (->
		downloadPath = @get('model.keys').filterBy('Name', 'downloadPath').get('firstObject').get 'Value'
		if !!downloadPath
			@get('model').setValue 'downloadPath', downloadPath, db
		@get('model').getLatestData db
		downloadPath
	).property 'model.keys.@each.Value'

App.VideoController = Em.Controller.extend
	selectedFormat: 'fixture-0'
	actions:
		download: ->
			@store.find('format', @get('selectedFormat')).then (f) ->
				downloadHandler = new DownloadHandler();
				alert 'Link do pobrania filmiku: ' + f.get('url')

App.IndexView = Em.View.extend()
App.VideoView = Em.View.extend()
Em.TextField.reopen
	attributeBindings: ['nwdirectory']

App.DirectoryChooser = Em.TextField.extend
	type: 'file'
	classNames: ['directory-chooser']
	change: (evt) ->
		config.get('keys').filterBy('Name', 'downloadPath')[0].set 'Value', evt.target.value

App.ChooseDirectoryButton = Em.View.extend
	tagName: 'span'
	classNames: ['btn', 'btn-blue']
	template: Em.Handlebars.compile 'Choose download directory'
	click: ->
		$('.directory-chooser').click()

App.PreferencesView = Em.View.extend
	controller: App.PreferencesController.create

App.DropTable = Em.View.extend
	modalActive: false
	tagName: 'button'
	classNames: ['btn', 'btn-red']
	attributeBindings: ['disabled']
	disabled: false
	click: ->
		@set 'disabled', true
		@set 'modalActive', true
	Modal: (->
		self = this
		$('<div title="Confirm action"><p>Are you sure you want to reset preferences?</p></div>').dialog
			height: 200
			modal: true
			buttons:
				Yes: ->
					config.resetConfig db
					$(this).dialog 'close'
				No: ->
					$(this).dialog 'close'
					self.set 'disabled', false
					self.set 'modalActive', false
		''
	).property 'modalActive'