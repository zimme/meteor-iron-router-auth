Package.describe({
  summary: 'Auth hook for iron-router',
  version: '0.0.1'
});

Package.on_use(function (api, where) {
  api.use('coffeescript', 'client');
  api.use('underscore', 'client');
  api.use('iron-router', 'client');

  api.add_files('hooks.coffee', 'client');
});
