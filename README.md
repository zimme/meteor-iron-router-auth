# Auth hook for [Iron Router](https://github.com/EventedMind/iron-router)

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/zimme/meteor-iron-router-auth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

I used [iron-router-auth](https://github.com/XpressiveCode/iron-router-auth) as inspiration and created a plugin and some auth hooks to use with onBeforeAction.

### Note
This pre-release is depending on my fork of
[Iron.Router](https://github.com/zimme/meteor-iron-router). The reason for that
is because of some work I did with namespaced hook options. This will hopefully
get merged into Iron.Router and if not I'll make the necessary changes.  
See PR [#864](https://github.com/EventedMind/iron-router/pull/864).

## Plugin

The plugin is using the hooks under the hood. It's a plug 'n' Play solution for
people with "regular" setups. I would recommend to try and use the plugin
firstly and only use the hooks specifically if you really need to.

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
  login: 'signIn',
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
  layout: , // Only used when render: true and don't have default value
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
Router.onBeforeAction('authtenticate', {except: ['signIn']});

// With options on use
Router.onBeforeAction('authenticate', {
  except: ['signIn'],
  template: 'signInTemplate'
});
```

Redirect to `signIn` route when user isn't logged in.

```js
// Gobal config.
// I would recommend using on use options
// instead as you can keep the router options
// and hook options separated.
Router.configure({
  authtenticate: 'signIn'
});

Router.configure({
  authtenticate: {
    route: 'signIn'
  }
});

// Route config
Router.route('/path', {
  authtenticate: 'signIn',
  name: 'authNeededRoute',
  ...
});

Router.route('/path', {
  authtenticate: {
    route: 'signIn'
  },
  name: 'authNeededRoute',
  ...
});

// Controller config
AuthNeededController = RouteController.extend({
  authtenticate: 'signIn',
  // Activate hook per route
  onBeforeAction: 'authtenticate',
  ...
});

AuthNeededController = RouteController.extend({
  authtenticate: {
    route: 'signIn'
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
Render `signIn` template in-place when user isn't logged in. (Configurable in
same places as redirect examples)
```js
Router.onBeforeAction('authenticate', {
    layout: 'layout', // Optional
    template: 'signIn'
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
  except: ['signIn']
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

### Noauth

This hook is used when you want to redirect to another route when user already
is logged in.

```js
Router.route('/sign-in', {
  name: 'signIn',
  noAuth: {
    route: 'home'
  },
  onBeforeAction: 'noAuth'
});
```

## Basic examples

Before redirecting, these hooks sets a Session variable named
`iron-router-auth.route` with the current route.  
This way you can redirect back on successful login.

Example of `signIn` route with replaceState on redirect
```js
Router.route('/sign-in', {
  name: 'signIn',
  onBeforeAction: 'noauth',
  onStop: function() {
    delete Session['iron-router-auth.route'];
  },
});

```
