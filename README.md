[![Gitter](https://img.shields.io/badge/gitter-join_chat-brightgreen.svg)]
(https://gitter.im/zimme/meteor-iron-router-auth)
[![Code Climate](https://img.shields.io/codeclimate/github/zimme/meteor-iron-router-auth.svg)]
(https://codeclimate.com/github/zimme/meteor-iron-router-auth)

# Auth plugin and hooks for [Iron.Router](https://github.com/EventedMind/iron-router)

I used [iron-router-auth](https://github.com/XpressiveCode/iron-router-auth) as inspiration and created a plugin and
some auth hooks to use with onBeforeAction.

## Install
```sh
meteor add zimme:iron-router-auth
```

## Plugin

The plugin is using the hooks provided under the hood. It's a plug 'n' play solution for
people with "regular" login flow. I would recommend you to try and use the plugin
first and only use the provided hooks manually if you really need too.

You can use the hook options on specific routes when using the plugin.

### Deprecation

The default exception routes `reset` and `verify` have been deprecated in favor
of `resetPassword` and `verifyEmail`. These routes will be removed from the
defaults with the next major version.

To have the hooks run on these routes either set new options for the plugin

```js
Router.plugin('auth', {
  ...
  except: [
    'enroll'
    'forgotPassword'
    'home'
    'login'
    'resetPassword'
    'signup'
    'verifyEmail'
  ],
  ...
});
```
or manually add this to these route definitions.
```js
// Do the same for /verify
Router.route('/reset', {
  ...
  onBeforeAction: ['authenticate', 'authorize'],
  ...
}
```

### Usage
```js
// Default options
Router.plugin('auth');

// Custom options
Router.plugin('auth', {
  authenticate: {
    route: 'signIn'
  },
  authorize: {
    allow: function() {
      if Roles.findOne({name: 'user', userIds: {$in: [Meteor.userId()]}})
        return true
      else
        return false
    },
    template: 'notAuthorized'
  }
});
```

### Options
```js
{
  authenticate: {
    allowExternalRoute: undefined,
    home: 'home',
    layout: undefined,
    logout: 'logout',
    replaceState: undefined,
    route: 'login',
    template: undefined
  },
  authorize: {
    allow: function() {return true},
    allowExternalRoute: undefined,
    deny: function() {return false}, // deny overrides allow
    layout: undefined,
    replaceState: undefined,
    route: undefined,
    template: 'notAuthorized'
  },
  except: ['enroll', 'forgotPassword', 'home', 'login', 'reset', 'verify'],
  noAuth: {
    allowExternalRoute: undefined,
    dashboard: 'dashboard',
    home: 'home',
    replaceState: undefined
  },
  only: ['enroll', 'login']
}
```


## Hooks

### Authenticate
It's configurable globally, on use and per route; using the `authenticate`
namespace.

Use hook globally
```js
Router.onBeforeAction('authenticate', {except: ['login']});

// With options on use
Router.onBeforeAction('authenticate', {
  authenticate: {
    template: 'signIn'
  },
  except: ['login']
});
```

Redirect to `login` route when user isn't logged in.

```js
// Gobal config.
// I would recommend using on use options
// instead as you can keep the router options
// and hook options separated.
Router.configure({
  authenticate: 'login'
});

Router.configure({
  authenticate: {
    route: 'login'
  }
});

// Route config
Router.route('/path', {
  authenticate: 'login',
  name: 'authNeededRoute',
  ...
});

Router.route('/path', {
  authenticate: {
    route: 'login'
  },
  name: 'authNeededRoute',
  ...
});

// Controller config
AuthNeededController = RouteController.extend({
  authenticate: 'login',
  // Activate hook per route
  onBeforeAction: ['authenticate'],
  ...
});

AuthNeededController = RouteController.extend({
  authenticate: {
    route: 'login'
  }
  // Activate hook per route with another custom hook
  onBeforeAction: [
    'authenticate',
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
    authenticate: {
      layout: 'layout', // Optional
      template: 'login'
    }
  }
});
```

### Authorize

This hook is configurable in the same places as [Authenticate](#authenticate).
It just uses different options.

```js
Router.onBeforeAction('authorize');

Router.onBeforeAction('authorize', {
  authorize: {
    allow: function() {
      if (Roles.findOne({name: 'admin', userIds: {$in: [Meteor.userId()]}}))
        return true
      else
        return false  
    }
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

This hook is used when you want to redirect an already logged in user to another route, for example the `login` route. It tries to use `dashboard`, `home` and falls back to the path `/`

```js
Router.route('/login', {
  name: 'login',
  noAuth: {
    dashboard: 'homeForLoggedInUsers',
    home: 'home'
  },
  onBeforeAction: ['noAuth']
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
  onBeforeAction: ['noAuth']
});
```

More examples can be found in the examples folder.
