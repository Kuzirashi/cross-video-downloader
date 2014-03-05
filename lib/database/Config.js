var util = require('util'),
	events = require('events');

module.exports = Config = function() {
	keys = [new ConfigKey('downloadPath', ''),
		new ConfigKey('language', 'en'),
		new ConfigKey('platform', 'windows')];

	// Column::__construct params: name, type, notNull, autoincrement, primary, unique
	columns = [new Column('Id', 'INTEGER', false, true, true, false),
		new Column('Key', 'TEXT', true, false, false, true),
		new Column('Value', 'TEXT', false, false, false, false)];

	this.getCreateTableSQL = function() {
		columnsSQL = '';
		for(i = 0; i < columns.length; i++)
			columnsSQL += (columns.length - 1 == i) ? columns[i].getSQL() : columns[i].getSQL() + ', ';
		return 'CREATE TABLE IF NOT EXISTS `config` (' + columnsSQL + ')';
	}

	this.insert = function(database, createTable) {
		colNames = '';
		for(i = 0; i < columns.length; i++) {
			if(columns[i].Name != 'Id')
				colNames += (columns.length - 1 == i) ? '`' + columns[i].Name + '`' : '`' + columns[i].Name + '`, ';
		}

		origin = this;
		database.transaction(function(tx) {
			if(createTable)
				tx.executeSql(origin.getCreateTableSQL());
			for(i = 0; i < keys.length; i++)
				tx.executeSql('INSERT INTO `config` (' + colNames + ') VALUES ("' + keys[i].Name + '", "' + keys[i].Value + '")');
		});
	}

	this.setValue = function(key, value, db) {
		db.transaction(function(tx) {
			tx.executeSql('UPDATE `config` SET `Value` = "' + value + '" WHERE `Key` = "' + key + '"');
		});
		this.getKey(key).Update(value);
	}

	this.getKey = function(name, pull, db) {
		var key = null;
		if(pull && db) {
			this.getLatestData(db);

			this.on('latestData', function() {
				for(i = 0; i < keys.length; i++) {
					if(keys[i].Name == name)
						key = keys[i]
				}
				key.Value = 'returned';
				return key;
			});
		} else {
			for(i = 0; i < keys.length; i++) {
					if(keys[i].Name == name)
						key = keys[i]
				}
				key.Value = 'returned';
				return key;
		}
		return { Value: 'ss' }
	}

	this.getLatestData = function(db) {
		origin = this;
		db.transaction(function(tx) {
			tx.executeSql('SELECT * FROM `config`', [], function(tx, result) {
				for(var i = 0; i < result.rows.length; i++) {
					item = result.rows.item(i);
					origin.getKey(item.Key).Update(item.Value);
					origin.emit('latestData');
				}
			});
		});
	}
}

util.inherits(Config, events.EventEmitter);