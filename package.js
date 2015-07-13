Package.describe({
  git: 'https://github.com/zimme/meteor-iron-router-auth.git',
  name: 'zimme:iron-router-auth',
  summary: 'Authentication and authorization for iron:router',
  version: '3.2.0-rc.3'
});

Package.onUse(function (api) {
  api.versionsFrom('1.0');

  api.use('accounts-base', 'client');

  api.use([
    'check',
    'coffeescript',
    'ejson',
    'underscore'
  ]);

  api.use('iron:router@1.0.3');

  api.addFiles([
    'client/hooks.coffee',
    'client/plugins.coffee'
  ], 'client');

  api.addFiles([
    'server/hooks.coffee',
    'server/plugins.coffee'
  ], 'server');
});
