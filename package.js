Package.describe({
  git: 'https://github.com/zimme/meteor-iron-router-auth.git',
  name: 'zimme:iron-router-auth',
  summary: 'Authentication and authorization for iron:router',
  version: '4.0.0-alpha.5',
});

Package.onUse(function (api) {
  api.versionsFrom('1.2');

  api.use('accounts-base', 'client');

  api.use([
    'check',
    'ecmascript',
    'ejson',
    'underscore',
  ]);

  api.use('iron:router@1.0.3');

  api.addFiles([
    'client/hooks.js',
    'client/plugins.js',
  ], 'client');

  api.addFiles([
    'server/hooks.js',
    'server/plugins.js',
  ], 'server');
});
