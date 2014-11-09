hooks = Iron.Router.hooks

sessionKey = 'iron-router-auth'

hooks.authenticate = ->
  if @route.getName() is '__notfound__' or Meteor.userId()
    @next()
    return

  return if Meteor.loggingIn()

  ns = 'authenticate'

  option = @lookupOption ns

  dashboard = @lookupOption 'dashboard', ns
  layout = @lookupOption 'layout', ns
  logout = @lookupOption 'logout', ns
  replaceState = @lookupOption 'replaceState', ns
  route = @lookupOption 'route', ns
  template = @lookupOption 'template', ns

  route = option if _.isString option

  check dashboard, Match.Optional String
  check layout, Match.Optional String
  check logout, Match.Optional String
  check replaceState, Match.Optional Boolean
  check route, Match.Optional String
  check template, Match.Optional String

  replaceState ?= true

  if @route.getName() is logout
    @redirect dashboard, {}, replaceState: replaceState
    return

  if route
    sessionValue =
      params: _.omit @params, -> false
      route: @route.getName()

    Session.set sessionKey, sessionValue
    @redirect route, {}, replaceState: replaceState
    return

  @layout = layout if layout
  @render template or new Template -> 'Not authenticated...'
  @renderRegions()

hooks.authorize = ->
  if @route.getName() is '__notfound__'
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
  replaceState = @lookupOption 'replaceState', ns
  route = @lookupOption 'route', ns
  template = @lookupOption 'template', ns

  check layout, Match.Optional String
  check replaceState, Match.Optional Boolean
  check route, Match.Optional String
  check template, Match.Optional String

  if route
    sessionValue =
      authorized: false
      params: _.omit @params, -> false
      route: @route.getName()

    Session.set sessionKey, sessionValue
    replaceState ?= true
    @redirect route, {}, replaceState: replaceState
    return

  @layout layout if layout
  @render template or new Template -> 'Access denied...'
  @renderRegions()
  unless template
    console.warn 'No template set for authorize hook.'

hooks.noAuth = ->
  if @route.getName() is '__notfound__' or not Meteor.userId()
    @next()
    return

  return if Meteor.loggingIn()

  ns = 'noAuth'

  options = @lookupOption ns

  replaceState = @lookupOption 'replaceState', ns
  route = @lookupOption 'route', ns

  route = options if _.isString options
  sessionValue = Session.get sessionKey

  check replaceState, Match.Optional Boolean
  check route, Match.Optional String

  replaceState ?= true
  route = sessionValue?.route ? route
  route ?= '/'

  params = sessionValue?.params ? {}

  @redirect route, params, replaceState: replaceState
