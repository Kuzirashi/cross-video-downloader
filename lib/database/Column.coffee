module.exports = class Column
	constructor: (@Name, @Type, @NotNull, @AutoIncrement, @Primary, @Unique) ->
	
	getSQL: ->
		sql = '`' + @Name + '` ' + @Type;
		sql += ' NOT NULL' if @NotNull
		sql += ' PRIMARY KEY' if @Primary
		sql += ' AUTOINCREMENT' if @AutoIncrement 
		sql += ' UNIQUE' if @Unique
		sql