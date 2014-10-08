hooks = Iron.Router.hooks

skip = ->
  @next()

hooks.authenticate = skip

hook.authorize = skip
