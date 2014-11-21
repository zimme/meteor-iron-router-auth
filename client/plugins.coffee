defaults =
  allow: -> true
  dashboard: 'dashboard'
  deny: -> false
  enroll: 'enroll'
  forgot: 'forgotPassword'
  login: 'login'
  logout: 'logout'
  replaceState: true
  reset: 'resetPassword'
  verify: 'verifyEmail'

plugins = Iron.Router.plugins

plugins.auth = (router, options = {}) ->
  {
    allow, dashboard, deny, enroll, forgot, layout, login, logout, render,
    replaceState, reset, verify
  } = _.defaults options, defaults

  opts =
    authenticate: {}
    except: [enroll, forgot, login, reset, verify]

  if dashboard
    opts.authenticate.dashboard = dashboard

  if logout
    opts.authenticate.logout = logout

  if render
    opts.authenticate.template = login

  else
    opts.authenticate.route = login

  if layout
    opts.authenticate.layout = layout

  if replaceState?
    opts.authenticate.replaceState = replaceState

  router.onBeforeAction 'authenticate', EJSON.clone opts

  opts.authorize = opts.authenticate
  delete opts.authenticate
  opts.authorize.allow = allow
  opts.authorize.deny = deny

  router.onBeforeAction 'authorize', EJSON.clone opts

  opts =
    noAuth: {}
    only: [enroll, forgot, login]

  if replaceState?
    opts.noAuth.replaceState = replaceState

  if dashboard
    opts.noAuth.route = dashboard

  router.onBeforeAction 'noAuth', EJSON.clone opts
