hooks = Iron.Router.hooks

skip = ->
  @next()

hooks.authenticate = skip

hooks.authorize = skip
