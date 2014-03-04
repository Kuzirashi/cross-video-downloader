module.exports = Column = function(name, type, notNull, autoincrement, primary, unique) {
	this.Name 			= name;
	this.Type 			= type;
	this.NotNull 		= notNull;
	this.AutoIncrement 	= autoincrement;
	this.Primary 		= primary;
	this.Unique 		= unique;

	this.getSQL = function() {
		sql = '`' + this.Name + '` ' + this.Type;
		sql += (this.NotNull) ? ' NOT NULL' : '';
		sql += (this.Primary) ? ' PRIMARY KEY' : '';
		sql += (this.AutoIncrement) ? ' AUTOINCREMENT' : '';
		sql += (this.Unique) ? ' UNIQUE' : '';
		return sql;
	}
}