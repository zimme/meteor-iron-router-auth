# Auth hook for [Iron.Router](https://github.com/EventedMind/iron-router)

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/zimme/meteor-iron-router-auth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Code Climate](https://codeclimate.com/github/zimme/meteor-iron-router-auth/badges/gpa.svg)](https://codeclimate.com/github/zimme/meteor-iron-router-auth)

I used [iron-router-auth](https://github.com/XpressiveCode/iron-router-auth) as inspiration and created a plugin and some auth hooks to use with onBeforeAction.

## Plugin

The plugin is using the hooks under the hood. It's a plug 'n' Play solution for
people with "regular" setups. I would recommend to try and use the plugin
first and only use the hooks manually if you really need to.

You can use the hook options on specific routes when using the plugin.

### Usage
```js
// Default options
Router.plugin('auth');

// Custom options
Router.plugin('auth', {
  allow: function() {
    if Roles.findOne({name: 'user', userIds: {$in: [Meteor.userId()]}})
      return true
    else
      return false
  },
  dashboard: 'home',
  login: 'login',
  render: true
});
```

### Options
```js
{
  allow: function() {return true},
  deny: function() {return false}, // deny overrides allow
  dashboard: 'dashboard'
  enroll: 'enroll',
  forgot: 'forgotPassword',
  layout: undefined, // Only used when render: true
  login: 'login',
  render: false,
  reset: 'resetPassword',
  verify: 'verifyPassword'
}
```


## Hooks

### Authenticate
It's configurable globally, on use and per route; using the `authenticate`
namespace.

Use hook globally
```js
Router.onBeforeAction('authtenticate', {except: ['login']});

// With options on use
Router.onBeforeAction('authenticate', {
  except: ['login'],
  template: 'signInTemplate'
});
```

Redirect to `login` route when user isn't logged in.

```js
// Gobal config.
// I would recommend using on use options
// instead as you can keep the router options
// and hook options separated.
Router.configure({
  authtenticate: 'login'
});

Router.configure({
  authtenticate: {
    route: 'login'
  }
});

// Route config
Router.route('/path', {
  authtenticate: 'login',
  name: 'authNeededRoute',
  ...
});

Router.route('/path', {
  authtenticate: {
    route: 'login'
  },
  name: 'authNeededRoute',
  ...
});

// Controller config
AuthNeededController = RouteController.extend({
  authtenticate: 'login',
  // Activate hook per route
  onBeforeAction: 'authtenticate',
  ...
});

AuthNeededController = RouteController.extend({
  authtenticate: {
    route: 'login'
  }
  // Activate hook per route with another custom hook
  onBeforeAction: [
    'authtenticate',
    function(pause) {
      // onBeforeAction hook
    }
  ],
  ...
});
```
Render `login` template in-place when user isn't logged in. (Configurable in
same places as redirect examples)
```js
Router.onBeforeAction('authenticate', {
    layout: 'layout', // Optional
    template: 'login'
  }
});
```

### Authorize

This hook is configurable in the same places as [Authenticate](#authenticate).
It just uses different options.

```js
Router.onBeforeAction('authorize');

Router.onBeforeAction('authorize', {
  allow: function() {
    if (Roles.findOne({name: 'admin', userIds: {$in: [Meteor.userId()]}}))
      return true
    else
      return false  
  },
  except: ['login']
});

Router.route('/path', {
  authorize: {
    deny: function() {
      if Meteor.user().admin
        return  false
      else
        return true
    }
  },
  name: 'authNeededRoute'
});
```

### No auth

This hook is used when you want to redirect to another route when user already
is logged in.

```js
Router.route('/login', {
  name: 'login',
  noAuth: {
    route: 'home'
  },
  onBeforeAction: 'noAuth'
});
```

## Basic examples

Before redirecting, these hooks sets a Session variable named
`iron-router-auth` with the current route and params and a flag
indicating if user wasn't authorized; authorized is only avaiable if redirected from `authorize`
 hook.  
This way you can redirect back on successful login.

Example `login` route.
```js
Router.route('/login', {
  name: 'login',
  onBeforeAction: 'noauth'
  },
});

```
