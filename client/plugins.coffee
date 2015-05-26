defaults =
  authenticate:
    home: 'home'
    route: 'login'

  authorize:
    allow: -> true
    deny: -> false
    template: 'notAuthorized'

  except: [
    'enroll'
    'forgotPassword'
    'home'
    'login'
    'reset' # XXX: Remove in next major version
    'resetPassword'
    'signup'
    'verify' # XXX: Remove in next major version
    'verifyEmail'
  ]

  noAuth:
    dashboard: 'dashboard'
    home: 'home'

  only: ['enroll', 'login']

plugins = Iron.Router.plugins

plugins.auth = (router, options = {}) ->
  _.defaults options, defaults

  router.onBeforeAction 'authenticate', _.pick options, 'authenticate', 'except'

  router.onBeforeAction 'authorize', _.pick options, 'authorize', 'except'

  router.onBeforeAction 'noAuth', _.pick options, 'noAuth', 'only'
