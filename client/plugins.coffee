defaults =
  allow: -> true
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
    except: [enroll, forgot, login, reset, verify]

  if dashboard
    opts.dashboard = dashboard

  if logout
    opts.logout = logout

  if render
    opts.template = login

  else
    opts.route = login

  if layout
    opts.layout = layout

  if replaceState?
    opts.replaceState = replaceState

  router.onBeforeAction 'authenticate', opts

  opts.allow = allow
  opts.deny = deny

  router.onBeforeAction 'authorize', opts

  opts =
    only: [enroll, forgot, login]

  if replaceState?
    opts.replaceState = replaceState

  if dashboard
    opts.route = dashboard

  router.onBeforeAction 'noAuth', opts
