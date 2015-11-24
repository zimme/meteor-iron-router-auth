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
  { authenticate
    authorize
    noAuth
    removePreviousRoute
    saveCurrentRoute
  } = options

  authenticate = _.defaults {}, authenticate, defaults.authenticate.options
  authenticateExcept = authenticate.except ? defaults.authenticate.except
  authenticateOnly = authenticate.only

  authorize = _.defaults {}, authorize, defaults.authorize.options
  authorizeExcept = authorize.except ? authenticateExcept
  authorizeOnly = authorize.only

  noAuth = _.defaults {}, noAuth, defaults.noAuth.options
  noAuthExcept = noAuth.except
  noAuthOnly = noAuth.only ? defaults.noAuth.only

  removePreviousRoute = _.defaults {}, removePreviousRoute,
    defaults.removePreviousRoute.options
  removePreviousRouteExcept = removePreviousRoute.except ?
    defaults.removePreviousRoute.except
  removePreviousRouteOnly = removePreviousRoute.only

  saveCurrentRoute = _.defaults {}, saveCurrentRoute,
    defaults.saveCurrentRoute.options
  saveCurrentRouteExcept = saveCurrentRoute.except ?
    defaults.saveCurrentRoute.except
  saveCurrentRouteOnly = saveCurrentRoute.only

  route = authenticate.route

  options =
    authenticate: _.omit authenticate, 'except', 'only'
    except: unless authenticate.only then authenticateExcept
    only: unless authenticate.except then authenticateOnly

  router.onBeforeAction 'authenticate', options

  options =
    authorize: _.omit authorize, 'except', 'only'
    except: unless authorize.only then authorizeExcept
    only: unless authorize.except then authorizeOnly

  router.onBeforeAction 'authorize', options

  options =
    noAuth: _.omit noAuth, 'except', 'only'
    except: unless noAuth.only then noAuthExcept
    only: unless noAuth.except then noAuthOnly

  router.onBeforeAction 'noAuth', options

  options =
    removePreviousRoute: _.omit removePreviousRoute, 'except', 'only'
    except: unless removePreviousRoute.only then removePreviousRouteExcept
    only: unless removePreviousRoute.except then removePreviousRouteOnly

  router.onRun 'removePreviousRoute', options if route

  options =
    saveCurrentRoute: _.omit saveCurrentRoute, 'except', 'only'
    except: unless saveCurrentRoute.only then saveCurrentRouteExcept
    only: unless saveCurrentRoute.except then saveCurrentRouteOnly

  router.onStop 'saveCurrentRoute', options if route
