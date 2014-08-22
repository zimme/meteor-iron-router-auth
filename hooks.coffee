sessionKey = 'iron-router-hook-auth.route'

hooks =
  auth: (pause) ->
    unless @route.name is '__notfound__'

      pause() if Meteor.loggingIn()

      unless Meteor.userId()
        options = @lookupProperty 'auth'

        if options
          if Match.test options, String
            options =
              route: options

          pattern =
            layout: Match.Optional String
            route: Match.Optional String
            template: Match.Optional String

          if Match.test options, pattern
            newRoute = options.route

            if newRoute
              replaceState = @router.options.auth?.replaceState ? true
              opts =
                replaceState: replaceState

              currentRoute = @route.name
              Session.set sessionKey, currentRoute
              @redirect newRoute, {}, opts

            else if options.template
              layout = options.layout
              @layoutTemplate = layout ? @layoutTemplate
              tmpl = options.template
              @render tmpl
              @renderRegions()
              pause()

_(Router.hooks).extend hooks
