Router.route '/logout',
  action: ->
    cb = (error) ->
      if error
        console.log error.reason

    Meteor.logout cb

  name: 'logout'
