defaults =
  enroll: 'enroll'
  forgot: 'forgotPassword'
  login: 'login'
  render: false
  reset: 'resetPassword'
  verify: 'verifyEmail'

plugins =
  auth: (router, options = {}) ->
    {enroll, forgot, layout, login, render, reset, verify} =
      _.defaults options, defaults

    opts =
      except: [enroll, forgot, login, reset, verify]

    authn = opts.authenticate = {}

    if render
      authn.template = login

    else
      authn.route = login

    if layout
      authn.layout = layout

    # XXX: See authenticate hook for explanation why this option is disabled.
    # Add replaceState to options destruction assignment.
    #
    # if replaceState?
    #   authn.replaceState = repalceState

    router.onBeforeAction 'authenticate', opts

_.extend Iron.Router.plugins, plugins
