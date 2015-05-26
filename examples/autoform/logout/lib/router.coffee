Router.route '/logout',
  action: ->
    cb = (error) ->
      if error
        console.log error.reason

    # Remove warning about this.next(), we know what we're doing
    @_rendered = true
    Meteor.logout cb

  name: 'logout'
