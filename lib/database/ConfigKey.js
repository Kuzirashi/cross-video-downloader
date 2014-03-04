module.exports = ConfigKey = function(name, defaultValue) {
	this.Name = name;
	this.DefaultValue = defaultValue;
	this.Value = defaultValue;
	this.LastUpdate = new Date();

	this.Update = function(value) {
		this.Value = value;
		this.LastUpdate = new Date();
	}
}