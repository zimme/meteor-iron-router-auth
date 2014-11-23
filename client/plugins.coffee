defaults =
  authenticate:
    home: 'home'
    route: 'login'

  authorize:
    allow: -> true
    deny: -> false
    template: 'notAuthorized'

  except: ['enroll', 'forgotPassword', 'login', 'reset', 'verify']

  noAuth:
    dashboard: 'dashboard'
    home: 'home'

  only: ['enroll', 'login']

plugins = Iron.Router.plugins

plugins.auth = (router, options = {}) ->
  for key in _.keys defaults
    options[key] ?= {}
    _.defaults options[key], defaults[key]

  router.onBeforeAction 'authenticate', _.pick options, 'authenticate', 'except'

  router.onBeforeAction 'authorize', _.pick options, 'authorize', 'except'

  router.onBeforeAction 'noAuth', _.pick options, 'noAuth', 'only'
