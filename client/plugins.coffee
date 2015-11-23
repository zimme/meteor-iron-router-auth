defaults =
  authenticate:
    options:
      home: 'home'
      route: 'login'
    except: [
      'enroll'
      'forgotPassword'
      'home'
      'login'
      'resetPassword'
      'signup'
      'verifyEmail'
    ]

  authorize:
    options:
      allow: -> true
      deny: -> false
      template: 'notAuthorized'

  noAuth:
    options:
      dashboard: 'dashboard'
      home: 'home'
    only: [
      'enroll'
      'login'
    ]

  removePreviousRoute:
    except: [
      'login'
      'logout'
      'signup'
    ]

  saveCurrentRoute:
    except: [
      'login'
      'logout'
      'signup'
    ]

plugins = Iron.Router.plugins

plugins.auth = (router, options = {}) ->
  options.authenticate = _.defaults options.authenticate ? {},
    defaults.authenticate.options
  options.authorize = _.defaults options.authorize ? {},
    defaults.authorize.options
  options.noAuth = _.defaults options.noAuth ? {}, defaults.noAuth.options
  options.removePreviousRoute = _.defaults options.removePreviousRoute ? {},
    defaults.removePreviousRoute.options
  options.saveCurrentRoute = _.defaults options.saveCurrentRoute ? {},
    defaults.saveCurrentRoute.options

  route = options.authenticate.route

  options.removePreviousRoute =
    removePreviousRoute: _.omit options.removePreviousRoute, 'except', 'only'
    except: unless options.removePreviousRoute.only
      _.defaults options.removePreviousRoute.except ? [],
        defaults.removePreviousRoute.except
    only: unless options.removePreviousRoute.except
      options.removePreviousRoute.only

  router.onRun 'removePreviousRoute', options.removePreviousRoute if route

  options.authenticate =
    authenticate: _.omit options.authenticate, 'except', 'only'
    except: unless options.authenticate.only
      _.defaults options.authenticate.except ? [],
        defaults.authenticate.except
    only: unless options.authenticate.except
      options.authenticate.only

  router.onBeforeAction 'authenticate', options.authenticate

  options.authorize =
    authorize: _.omit options.authorize, 'except', 'only'
    except: unless options.authorize.only
      _.defaults options.authorize.except ? [], options.authenticate.except,
        defaults.authenticate.except
    only: unless options.authorize.except
      options.authorize.only

  router.onBeforeAction 'authorize', options.authorize

  options.saveCurrentRoute =
    saveCurrentRoute: _.omit options.saveCurrentRoute, 'except', 'only'
    except: unless options.saveCurrentRoute.only
      _.defaults options.saveCurrentRoute.except ? [],
        defaults.saveCurrentRoute.except
    only: unless options.saveCurrentRoute.except
      options.saveCurrentRoute.only

  router.onStop 'saveCurrentRoute', options.saveCurrentRoute if route

  options.noAuth =
    noAuth: _.omit options.noAuth, 'except', 'only'
    except: unless options.noAuth.only
      options.noAuth.except
    only: unless options.noAuth.except
      _.defaults options.noAuth.only ? [],
        defaults.noAuth.only

  router.onBeforeAction 'noAuth', options.noAuth
