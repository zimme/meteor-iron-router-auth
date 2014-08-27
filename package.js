Package.describe({
  git: 'https://github.com/zimme/meteor-iron-router-auth.git',
  name: 'zimme:iron-router-auth',
  summary: 'Auth hook for iron-router',
  version: '0.1.0'
});

Package.onUse(function (api, where) {
  api.versionsFrom('0.9.0');

  api.use('accounts-base', 'client');
  api.use('coffeescript', 'client');
  api.use('iron:router@0.9.0', 'client');
  api.use('underscore', 'client');

  api.addFiles('hooks.coffee', 'client');
});
