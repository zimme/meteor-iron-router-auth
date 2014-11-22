Package.describe({
  git: 'https://github.com/zimme/meteor-iron-router-auth.git',
  name: 'zimme:iron-router-auth',
  summary: 'Auth plugin and hooks for iron:router',
  version: '3.0.0-pre.0'
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

  api.use('iron:router@1.0.0');

  api.addFiles([
    'client/hooks.coffee',
    'client/plugins.coffee'
  ], 'client');

  api.addFiles([
    'server/hooks.coffee',
    'server/plugins.coffee'
  ], 'server');
});
