users = [
  password: 'password'
  username: 'user'
,
  password: 'password'
  username: 'admin'
]

Meteor.startup ->
  unless Meteor.users.find().count()
    Accounts.createUser user for user in users
