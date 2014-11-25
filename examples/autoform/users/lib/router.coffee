Router.route '/users',
  authorize:
    deny: ->
      return false if Meteor.user().username is 'admin'
      return true

    template: 'notAuthorized'

  name: 'users'
