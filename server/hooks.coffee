hooks =
  authenticate: ->
    @next()

_.extend Iron.Router.hooks, hooks
