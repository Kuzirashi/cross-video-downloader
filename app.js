App = Ember.Application.create();

App.Router.map(function() {
	this.route('queue');
	this.route('about');
	this.route('preferences');
});

Ember.TextField.reopen({
    attributeBindings: ['nwdirectory']
});

App.PreferencesController = Em.Controller.extend({
	directory: 'ss/controller',

	actions: {
		setDirectory: function(el) {
			alert('set directory');
			this.set('directory', el.value);
		},
		change: function(s) {
			alert(s);
		}
	}
});

App.PreferencesRoute = Em.Route.extend({
	
});

App.DirectoryChooser = Ember.TextField.extend({
    type: 'file',
    nwdirectory: '',
    directory: 'some',
    change: function(evt) {
        var input = evt.target;
		this.set('directory', input.value);
    }

    
});