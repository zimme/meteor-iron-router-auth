defaults =
  allow: -> true
  deny: -> false
  enroll: 'enroll'
  forgot: 'forgotPassword'
  layout: false # Should be string of layout
  login: 'login'
  render: false
  reset: 'resetPassword'
  verify: 'verifyEmail'

plugins = Iron.Router.plugins

plugins.auth = (router, options = {}) ->
  {allow, deny, enroll, forgot, layout, login, render, reset, verify} =
    _.defaults options, defaults

  opts =
    except: [enroll, forgot, login, reset, verify]

  if render
    opts.template = login

  else
    opts.route = login

  if layout
    opts.layout = layout

  # XXX: See authenticate hook for explanation why this option is disabled.
  # Add replaceState to options destruction assignment.
  #
  # if replaceState?
  #   opts.replaceState = repalceState

  router.onBeforeAction 'authenticate', opts

  opts.allow = allow
  opts.deny = deny

  router.onBeforeAction 'authorize', opts
