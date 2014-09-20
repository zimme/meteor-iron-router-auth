# Auth hook for [Iron Router](https://github.com/EventedMind/iron-router)

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/zimme/meteor-iron-router-auth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

I used [iron-router-auth](https://github.com/XpressiveCode/iron-router-auth) as inspiration and created an auth hook to use with onBeforeAction.

It's configurable globally and per route, using the ```auth``` namespace.
There is however one option that can only be set globally and that's ```replaceState```

Activate hook globally
```js
Router.onBeforeAction('auth', {except: ['signIn']});
```

Redirect to ```signIn``` route when user isn't logged in.

```js
//Gobal config
Router.configure({
  auth: 'signIn'
});

Router.configure({
  auth: {
    route: 'signIn',
    replaceState: false // Optional, defaults to true
  }
});

//Route config
Router.map(function() {
  this.route('authNeededRoute', {
    auth: 'signIn',
    ...
  }
});

Router.map(function() {
  this.route('authNeededRoute', {
    auth: {
      route: 'signIn'
    },
    ...
  }
});

//Controller config
AuthNeededController = RouteController.extend({
  auth: 'signIn',
  // Activate hook per route
  onBeforeAction: 'auth',
  ...
});

AuthNeededController = RouteController.extend({
  auth: {
    route: 'signIn'
  }
  // Activate hook per route with another custom hook
  onBeforeAction: [
    'auth',
    function(pause) {
      // onBeforeAction hook
    }
  ],
  ...
});
```
Render ```signIn``` template in-place when user isn't logged in. (Configurable in same places as redirect examples)
```js
Router.configure({
  auth: {
    layout: 'layout', // Optional
    template: 'signIn'
  }
});
```

On redirect this hook sets a Session variable named ```iron-router-auth.route``` to the current route before redirecting, that way you can redirect back on successful login, and if you use replaceState on that redirect the ```signIn``` route won't be in the history.

Example of ```signIn``` route with replaceState on redirect
```js
Router.map(function() {
  this.route('signIn', {
    onBeforeAction: function(pause) {
      if (Meteor.userId()) {
        this.redirect('home', {}, {
          replaceState: true
        });
      }
    },
    onStop: function() {
      delete Session['iron-router-auth.route'];
    },
    path: 'sign-in'
  });
});
```
