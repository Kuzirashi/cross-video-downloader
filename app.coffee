YtVideo = require './lib/YtVideo.coffee'

window.App = Em.Application.create()
App.ApplicationAdapter = DS.FixtureAdapter.extend()

App.Format = DS.Model.extend
	video: DS.belongsTo 'video'
	itag: DS.attr 'string'
	quality: DS.attr 'string'

App.Video = DS.Model.extend
	title: DS.attr 'string'
	thumbnailUrl: DS.attr 'string'
	formats: DS.hasMany 'format'


# BEGIN -- ROUTES
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
				video = self.store.createRecord 'video', { id: @Id, title: @Title, thumbnailUrl: @ThumbnailUrl }

				@Formats.map (i) ->
					format = self.store.createRecord 'format', { itag: i.itag, quality: i.quality, video: video }
					console.log format.get('itag')
					format.save()
					console.log format.get('quality')
					console.log video.get('formats')
					video.get('formats').pushObject format
				
				#self.store.commit()
				video.save()
				console.log video.get('formats').get('length')
				console.log video.get('title')
				self.transitionTo 'video', @Id

			ytVideo.getInfo()

App.VideoRoute = Em.Route.extend
	model: (params) ->
		vid = @store.find 'video', params.video_id
		vid.then (item) ->
			console.log item.get('formats').get('length')
		vid
# END -- ROUTES

App.ConfigKey = Em.Object.extend
	Name: ''
	DefaultValue: ''
	Value: ''

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

# BEGIN -- CONTROLLERS
App.PreferencesController = Em.Controller.extend
	model: config
	directory: (->
		downloadPath = @get('model.keys').filterBy('Name', 'downloadPath').get('firstObject').get 'Value'
		if !!downloadPath
			@get('model').setValue 'downloadPath', downloadPath, db
		@get('model').getLatestData db
		downloadPath
	).property 'model.keys.@each.Value'
# END -- CONTROLLERS

# BEGIN -- DEFINING VIEWS
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
		model: config

App.DropTable = Em.View.extend
	modalActive: false
	tagName: 'button'
	classNames: ['btn', 'btn-red']
	attributeBindings: ['disabled']
	disabled: false
	click: ->
		@set 'disabled', 'disabled'
		@set 'modalActive', true
	Modal: (->
		html = '<div title="Confirm action"><p>Are you sure you want to reset preferences?</p></div>'
		$(html).dialog
			height: 200
			modal: true
			buttons:
				Yes: ->
					config.resetConfig db
					$(this).dialog 'close'
				No: ->
					$(this).dialog 'close'
	).property 'modalActive'
# END -- DEFINING VIEWS