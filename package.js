Package.describe({
  git: 'https://github.com/zimme/meteor-iron-router-auth.git',
  name: 'zimme:iron-router-auth',
  summary: 'Auth hook for iron-router',
  version: '0.0.10'
});

Package.on_use(function (api, where) {
  api.versionsFrom('METEOR@0.9.0');

  api.use('coffeescript', 'client');
  api.use('underscore', 'client');
  api.use("cmather:iron-router@0.8.2", 'client');

  api.add_files('hooks.coffee', 'client');
});
