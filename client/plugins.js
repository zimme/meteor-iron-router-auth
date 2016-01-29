const defaults = {
  authenticate: {
    options: {
      home: 'home',
      route: 'login',
    },
    except: [
      'enroll',
      'forgotPassword',
      'home',
      'login',
      'resetPassword',
      'signup',
      'verifyEmail',
    ],
  },

  authorize: {
    options: {
      allow() { return true; },
      deny() { return false; },
      template: 'notAuthorized',
    },
  },

  noAuth: {
    options: {
      dashboard: 'dashboard',
      home: 'home',
    },
    only: [
      'enroll',
      'login',
    ],
  },

  removePreviousRoute: {
    except: [
      'login',
      'logout',
      'signup',
    ],
  },

  saveCurrentRoute: {
    except: [
      'login',
      'signup',
    ],
  },
};

plugins = Iron.Router.plugins;

plugins.auth = function(router, options = {}) {
  let {
    authenticate,
    authorize,
    noAuth,
    removePreviousRoute,
    saveCurrentRoute,
  } = options;
  let ref;

  authenticate = _.defaults({}, authenticate, defaults.authenticate.options);
  const authenticateExcept = (ref = authenticate.except) != null ? ref :
    defaults.authenticate.except;
  const authenticateOnly = authenticate.only;

  authorize = _.defaults({}, authorize, defaults.authorize.options);
  const authorizeExcept = (ref = authorize.except) != null ? ref :
    authenticateExcept;
  const authorizeOnly = authorize.only;

  noAuth = _.defaults({}, noAuth, defaults.noAuth.options);
  const noAuthExcept = noAuth.except;
  const noAuthOnly = (ref = noAuth.only) != null ? ref : defaults.noAuth.only;

  removePreviousRoute = _.defaults({}, removePreviousRoute,
    defaults.removePreviousRoute.options);
  const removePreviousRouteExcept = (ref = removePreviousRoute.except) != null ?
    ref : defaults.removePreviousRoute.except;
  const removePreviousRouteOnly = removePreviousRoute.only;

  saveCurrentRoute = _.defaults({}, saveCurrentRoute,
    defaults.saveCurrentRoute.options);
  const saveCurrentRouteExcept = (ref = saveCurrentRoute.except) != null ? ref :
    defaults.saveCurrentRoute.except;
  const saveCurrentRouteOnly = saveCurrentRoute.only;

  const route = authenticate.route;

  options = {
    authenticate: _.omit(authenticate, 'except', 'only'),
  };
  if (!authenticate.only) {
    options.except = authenticateExcept;
  } else if (!authenticate.except) {
    options.only = authenticateOnly;
  }

  router.onBeforeAction('authenticate', options);

  options = {
    authorize: _.omit(authorize, 'except', 'only'),
  };
  if (!authorize.only) {
    options.except = authorizeExcept;
  } else if (!authorize.except) {
    options.only = authorizeOnly;
  }

  router.onBeforeAction('authorize', options);

  options = {
    noAuth: _.omit(noAuth, 'except', 'only'),
  };
  if (!noAuth.only) {
    options.except = noAuthExcept;
  } else if (!noAuth.except) {
    options.only = noAuthOnly;
  }

  router.onBeforeAction('noAuth', options);

  options = {
    removePreviousRoute: _.omit(removePreviousRoute, 'except', 'only'),
  };
  if (!removePreviousRoute.only) {
    options.except = removePreviousRouteExcept;
  } else if (!removePreviousRoute.except) {
    options.only = removePreviousRouteOnly;
  }

  if (route) {
    router.onRun('removePreviousRoute', options);
  }

  options = {
    saveCurrentRoute: _.omit(saveCurrentRoute, 'except', 'only'),
  };
  if (!saveCurrentRoute.only) {
    options.except = saveCurrentRouteExcept;
  } else if (!saveCurrentRoute.except) {
    options.only = saveCurrentRouteOnly;
  }

  if (route) {
    router.onStop('saveCurrentRoute', options);
  }
};
