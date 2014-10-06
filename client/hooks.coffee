# XXX: Can controller's state or a reactive var be used instead
# of session var?
sessionKey = 'iron-router-auth.route'

hooks =
  authenticate: ->
    unless @route.name is '__notfound__'

      unless Meteor.loggingIn() and Meteor.userId()
        options = @lookupOption 'authenticate'

        if options
          if _.isString options
            options =
              route: options

          pattern =
            layout: Match.Optional String
            route: Match.Optional String
            template: Match.Optional String

          if Match.test options, pattern
            newRoute = options.route
            template = options.template

            if newRoute
              # Disable replaceState setting until it's supported again.
              #
              # https://github.com/EventedMind/iron-location/issues/5
              #
              # replaceState = @router.options.authenticate?.replaceState ? true
              # opts =
              #   replaceState: replaceState

              currentRoute = @route.name
              Session.set sessionKey, currentRoute
              # @redirect newRoute, {}, opts
              @redirect newRoute

            else if template
              layout = options.layout
              @layout layout if layout
              @render template
              @renderRegions()

            return

    @next()

_.extend Iron.Router.hooks, hooks
