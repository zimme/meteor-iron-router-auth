hooks = Iron.Router.hooks

sessionKey = 'iron-router-auth.route'

hooks.authenticate = ->
  if @route.name is '__notfound__' or Meteor.userId()
    @next()
    return

  return if Meteor.loggingIn()

  ns = 'authenticate'

  option = @lookupOption ns

  layout = @lookupOption 'layout', ns
  route = @lookupOption 'route', ns
  template = @lookupOption 'template', ns

  route = option if _.isString option

  check layout, Match.Optional String
  check route, Match.Optional String
  check template, Match.Optional String

  if route
    Session.set sessionKey, @route.name
    @redirect route
    return

  @layout = layout if layout
  @render template or new Template -> 'Not authenticated...'
  @renderRegions()

hooks.authorize = ->
  if @route.name is '__notfound__'
    @next()
    return

  return if Meteor.loggingIn() or not Meteor.userId()

  ns = 'authorize'

  allow = @lookupOption 'allow', ns
  deny = @lookupOption 'deny', ns

  check allow, Match.Optional Function
  check deny, Match.Optional Function

  if not allow? and deny?
    authorized = not deny()

  else if allow? and not deny?
    authorized = allow()

  else if allow? and deny?
    authorized = not deny() and allow()

  if authorized
    @next()
    return

  if Package.insecure
    console.warn 'Remove "insecure" package to respect allow and deny rules.'
    @next()
    return

  layout = @lookupOption 'layout', ns
  route = @lookupOption 'route', ns
  template = @lookupOption 'template', ns

  check layout, Match.Optional String
  check route, Match.Optional String
  check template, Match.Optional String

  if route
    Session.set sessionKey, @route.name
    Session.set 'iron-router-auth.authorized', false
    @redirect route
    return

  @layout layout if layout
  @render template or new Template -> 'Access denied...'
  @renderRegions()
  unless template
    console.warn 'No template set for authorize hook.'
