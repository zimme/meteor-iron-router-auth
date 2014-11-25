loginSchema = new SimpleSchema
  login:
    autoform:
      placeholder: 'schemaLabel'
    label: 'Email or username'
    type: String

  password:
    autoform:
      placeholder: 'schemaLabel'
      type: 'password'
    min: 6
    type: String

loginSchema.messages
  'auth login': 'Incorrect email, username or password'
  'auth password': ' '

AutoForm.hooks
  loginForm:
    onError: (operation, error, template) ->
      if error instanceof Meteor.Error
        if error.reason in ['Incorrect password', 'User not found']
          context = AutoForm.getValidationContext @formId

          context.addInvalidKeys [
            name: 'login'
            type: 'auth'
          ,
            name: 'password'
            type: 'auth'
          ]

        else
          console.warn error.message

    onSubmit: (insertDoc, updateDoc, currentDoc) ->
      {login, password} = insertDoc

      cb = (error) =>
        @done error

      Meteor.loginWithPassword login, password, cb

      false

Template.login.helpers
  settings:
    class: 'form-login'
    id: 'loginForm'
    schema: loginSchema
