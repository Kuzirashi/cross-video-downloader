App = Em.Application.create();

App.Router.map(function() {
	this.route('queue');
	this.route('about');
	this.route('preferences');
});

Em.TextField.reopen({
	attributeBindings: ['nwdirectory']
});

App.ConfigKey = Em.Object.extend({
	Name: '',
	DefaultValue: '',
	Value: ''
});

App.Config = Em.Object.extend({
	keys: [ App.ConfigKey.create({ Name: 'downloadPath', DefaultValue: '' }),
		App.ConfigKey.create({ Name: 'language', DefaultValue: 'en' }),
		App.ConfigKey.create({ Name: 'platform', DefaultValue: 'windows' })],

	columns: [new Column('Id', 'INTEGER', false, true, true, false),
		new Column('Key', 'TEXT', true, false, false, true),
		new Column('Value', 'TEXT', false, false, false, false)],

	getCreateTableSQL: function() {
		columns = this.get('columns');
		columnsSQL = '';
		for(i = 0; i < columns.length; i++)
			columnsSQL += (columns.length - 1 == i) ? columns[i].getSQL() : columns[i].getSQL() + ', ';
		return 'CREATE TABLE IF NOT EXISTS `config` (' + columnsSQL + ')';
	},

	insert: function(database, createTable) {
		columns = this.get('columns');
		colNames = '';
		for(i = 0; i < columns.length; i++)
			if(columns[i].Name != 'Id')
				colNames += (columns.length - 1 == i) ? '`' + columns[i].Name + '`' : '`' + columns[i].Name + '`, ';

		origin = this;
		keys = this.get('keys');
		database.transaction(function(tx) {
			if(createTable)
				tx.executeSql(origin.getCreateTableSQL());
			for(i = 0; i < keys.length; i++) {
				value = (keys[i].get('Value') == '') ? keys[i].get('DefaultValue') : keys[i].get('Value');
				tx.executeSql('INSERT INTO `config` (' + colNames + ') VALUES ("' + keys[i].get('Name') + '", "' + value + '")');
			}
		});
	},

	setValue: function(key, value, db) {
		db.transaction(function(tx) {
			tx.executeSql('UPDATE `config` SET `Value` = "' + value + '" WHERE `Key` = "' + key + '"');
		});
		this.get('keys').filterBy('Name', key)[0].set('Value', value);
	},

	getLatestData: function(db) {
		origin = this;
		db.transaction(function(tx) {
			tx.executeSql('SELECT * FROM `config`', [], function(tx, result) {
				for(var i = 0; i < result.rows.length; i++)
					origin.get('keys')[i].set('Value', result.rows.item(i).Value);
			});
		});
	},

	resetConfig: function(db) {
		db.transaction(function(tx) {
			tx.executeSql('DROP TABLE `config`');
			location.reload();
		});
	}
});

db = openDatabase('app-db', '1.0', 'Cross platform YouTube downloader database.', 2 * 1024 * 1024);

config = App.Config.create();
config.insert(db, true);

App.DirectoryChooser = Em.TextField.extend({
	type: 'file',
	classNames: ['directory-chooser'],
	change: function(evt) {
		config.get('keys').filterBy('Name', 'downloadPath')[0].set('Value', evt.target.value);
	}
});

App.ChooseDirectoryButton = Em.View.extend({
	tagName: 'span',
	classNames: ['btn', 'btn-blue'],
	template: Em.Handlebars.compile('Choose download directory'),
	click: function() {
		$('.directory-chooser').click();
	}
});

App.PreferencesController = Em.Controller.extend({
	model: config,
	directory: function() {
		downloadPath = this.get('model.keys').filterBy('Name', 'downloadPath')[0];
		if(downloadPath.Value != '' && downloadPath.Value !== undefined)
			this.get('model').setValue('downloadPath', downloadPath.Value, db);
		this.get('model').getLatestData(db);
		return downloadPath.Value;
	}.property('model.keys.@each.Value')
});

App.PreferencesView = Em.View.extend({
	controller: App.PreferencesController.create({ model: config })
});

App.DropTable = Em.View.extend({
	modalActive: false,
	tagName: 'button',
	classNames: ['btn', 'btn-red'],
	attributeBindings: ['disabled'],
	disabled: false,
	click: function() {
		this.set('disabled', 'disabled');
		this.set('modalActive', true);
		console.log('click');
	},
	Modal: function() {
		html = '<div title="Confirm action"><p>Are you sure you want to reset preferences?</p></div>';
		$(html).dialog({
			height: 200,
			modal: true,
			buttons: {
				Yes: function() {
					config.resetConfig(db);
					$(this).dialog('close');
				},
				No: function() {
					$(this).dialog('close');
				}
			}
		});
		console.log('modal');
	}.property('modalActive')
});