const hooks = this.Iron.Router.hooks;

const sessionKey = 'iron-router-auth';

// onBeforeAction hook
hooks.authenticate = function authenticateHook() {
  if (this.route.getName() === '__notfound__' || Meteor.userId()) {
    this.next();
    return;
  }

  if (Meteor.loggingIn()) {
    // Remove warning about this.next(), we know what we're doing
    this._rendered = true;
    return;
  }

  const ns = 'authenticate';

  let options = this.lookupOption(ns);

  if (options == null) {
    options = {};
  }

  if (_.isFunction(options)) {
    options = options.apply(this);
  }

  if (options === false) {
    this.next();
    return;
  }

  let {
    home,
    layout,
    logout,
    replaceState,
    route,
    template,
  } = options;

  if (logout == null) {
    logout = 'logout';
  }

  if (_.isString(options)) {
    route = options;
  }

  check(home, Match.Optional(Match.OneOf(Function, String)));
  check(layout, Match.Optional(Match.OneOf(Function, String)));
  check(logout, Match.Optional(Match.OneOf(Function, String)));
  check(replaceState, Match.Optional(Match.OneOf(Boolean, Function)));
  check(route, Match.Optional(Match.OneOf(Function, String)));
  check(template, Match.Optional(Match.OneOf(Function, String)));

  if (replaceState == null) {
    replaceState = true;
  }

  if (_.isFunction(replaceState)) {
    replaceState = replaceState.apply(this);
  }

  if (_.isFunction(logout)) {
    logout = logout.apply(this);
  }

  let sessionValue = Session.get(sessionKey);
  const previousRoute = sessionValue && sessionValue.route;

  if (_.isFunction(home)) {
    home = home.apply(this);
  }

  if (!this.router.routes[home] || !home) {
    home = '/';
  }

  if (this.route.getName() !== logout && previousRoute === logout && !Meteor.userId()) {
    delete Session.keys[sessionKey];
    this.redirect(home, {}, { replaceState });
    return;
  }

  let params;
  let ref;
  if (this.route.getName() === logout && !Meteor.userId()) {
    ref = sessionValue && sessionValue.route;
    route = ref != null ? ref : home;
    ref = sessionValue && sessionValue.params;
    params = ref != null ? ref : {};
    delete Session.keys[sessionKey];
    this.redirect(route, params, { replaceState });
    return;
  }

  if (_.isFunction(route)) {
    route = route.apply(this);
  }

  if (this.router.routes[route] || route && route.slice(0, 1) === '/') {
    params = {};
    for (const key in this.params) {
      if (!this.params.hasOwnProperty(key)) {
        continue;
      }
      params[key] = this.params[key];
    }
    sessionValue = {
      params,
      route: this.route.getName(),
    };

    Session.set(sessionKey, sessionValue);
    this.redirect(route, {}, { replaceState });
    return;
  }

  if (_.isFunction(template)) {
    template = template.apply(this);
  }

  if (_.isString(template) && !Template[template]) {
    template = false;
  }

  if (_.isFunction(layout)) {
    layout = layout.apply(this);
  }

  if (layout) {
    this.layout = layout;
  }
  this.render(template || new Template(() => 'Not authenticated...'));
  this.renderRegions();

  if (route) {
    console.warn(`Route "${route}" for authenticate hook not found.`);
  } else if (!template) {
    if (template === false) {
      console.warn(`Template "${template}" for authenticate hook not found.`);
    } else if (!route) {
      console.warn('No route or template set for authenticate hook.');
    } else {
      console.warn('No template set for authenticate hook.');
    }
  }
};

// onBeforeAction hook
hooks.authorize = function authorizeHook() {
  if (this.route.getName() === '__notfound__') {
    this.next();
    return;
  }

  const authenticate = this.lookupOption('authenticate');

  if (authenticate === false) {
    this.next();
    return;
  }

  if (Meteor.loggingIn() || !Meteor.userId()) {
    // Remove warning about this.next(), we know what we're doing
    this._rendered = true;
    return;
  }

  const ns = 'authorize';

  let options = this.lookupOption(ns);

  if (_.isFunction(options)) {
    options = options.apply(this);
  }

  if (options === false) {
    this.next();
    return;
  }

  if (options == null) {
    options = {};
  }

  const {
    allow,
    deny,
  } = options;

  let {
    layout,
    replaceState,
    route,
    template,
  } = options;

  check(allow, Match.Optional(Function));
  check(deny, Match.Optional(Function));
  check(layout, Match.Optional(Match.OneOf(Function, String)));
  check(replaceState, Match.Optional(Match.OneOf(Boolean, Function)));
  check(route, Match.Optional(Match.OneOf(Function, String)));
  check(template, Match.Optional(Match.OneOf(Function, String)));

  let authorized = false;

  if (allow == null && deny != null) {
    authorized = !deny.call(this);
  } else if (allow != null && deny == null) {
    authorized = allow.call(this);
  } else if (allow != null && deny != null) {
    authorized = !deny.call(this) && allow.call(this);
  }

  if (authorized) {
    this.next();
    return;
  }

  if (Package.insecure) {
    console.warn('Remove "insecure" package to respect allow and deny rules.');
    this.next();
    return;
  }

  if (replaceState == null) {
    replaceState = true;
  }

  if (_.isFunction(replaceState)) {
    replaceState = replaceState.apply(this);
  }

  if (_.isFunction(route)) {
    route = route.apply(this);
  }

  if (this.router.routes[route] || route && route.slice(0, 1) === '/') {
    const params = {};
    for (const key in this.params) {
      if (!this.params.hasOwnProperty(key)) {
        continue;
      }
      params[key] = this.params[key];
    }

    const sessionValue = {
      notAuthorized: true,
      params,
      route: this.route.getName(),
    };

    Session.set(sessionKey, sessionValue);
    this.redirect(route, {}, { replaceState });
    return;
  }

  this.state.set(sessionKey, {
    notAuthorized: true,
  });

  if (_.isFunction(template)) {
    template = template.apply(this);
  }

  if (_.isString(template) && !Template[template]) {
    template = false;
  }

  if (_.isFunction(layout)) {
    layout = layout.apply(this);
  }

  if (layout) {
    this.layout(layout);
  }

  this.render(template || new Template(() => 'Access denied...'));
  this.renderRegions();

  if (route) {
    console.warn(`Route "${route}" for authorize hook not found.`);
  } else if (!template) {
    if (template === false) {
      console.warn(`Template "${template}" for authorize hook not found.`);
    } else if (!route) {
      console.warn('No route or template set for authorize hook.');
    } else {
      console.warn('No template set for authorize hook.');
    }
  }
};

// onBeforeAction hook
hooks.noAuth = function noAuthHook() {
  if (this.route.getName() === '__notfound__') {
    this.next();
    return;
  }

  if (Meteor.loggingIn()) {
    // Remove warning about this.next(), we know what we're doing
    this._rendered = true;
    return;
  }

  if (!Meteor.userId()) {
    this.next();
    return;
  }

  let sessionValue = Session.get(sessionKey);

  if (Meteor.userId() && sessionValue && sessionValue.notAuthorized) {
    this.next();
    return;
  }

  const ns = 'noAuth';

  let options = this.lookupOption(ns);

  if (_.isFunction(options)) {
    options = options.apply(this);
  }

  if (options === false) {
    this.next();
    return;
  }

  let route;
  let {
    dashboard,
    home,
    replaceState,
  } = options != null ? options : {};

  if (_.isString(options)) {
    route = options;
  }

  check(dashboard, Match.Optional(Match.OneOf(Function, String)));
  check(home, Match.Optional(Match.OneOf(Function, String)));
  check(replaceState, Match.Optional(Match.OneOf(Function, Boolean)));

  if (_.isFunction(dashboard)) {
    dashboard = dashboard.apply(this);
  }
  if (_.isFunction(home)) {
    home = home.apply(this);
  }

  if (dashboard && (this.router.routes[dashboard] || dashboard.slice(0, 1) === '/')) {
    route = dashboard;
  } else if (home && (this.router.routes[home] || home.slice(0, 1) === '/')) {
    route = home;
  }

  if (replaceState == null) {
    replaceState = true;
  }

  if (_.isFunction(replaceState)) {
    replaceState = replaceState.apply(this);
  }

  let ref = sessionValue != null;
  route = (ref ? sessionValue.route : void 0) != null ? ref : route;

  if (_.isFunction(route)) {
    route = route.apply(this);
  }

  if (!(route && this.router.routes[route])) {
    route = '/';
  }

  ref = sessionValue != null;
  const params = (ref ? sessionValue.params : void 0) != null ? ref : {};

  delete Session.keys[sessionKey];

  this.redirect(route, params, { replaceState });

  if (route === '/') {
    if (dashboard) {
      console.warn(`Route "${dashboard}" for noAuth hook not found, using "/"`);
    } else if (home) {
      console.warn(`Route "${home}" for noAuth hook not found, using "/"`);
    } else {
      console.warn('No route or template set for noAuth hook, using "/"');
    }
  }
};

// onStop hook
hooks.saveCurrentRoute = function saveCurrentRouteHook() {
  const params = {};
  for (const key in this.params) {
    if (!this.params.hasOwnProperty(key)) {
      continue;
    }
    params[key] = this.params[key];
  }

  const sessionValue = {
    params,
    route: this.route.getName(),
  };

  Session.set(sessionKey, sessionValue);
  return;
};

// onRun hook
hooks.removePreviousRoute = function removePreviousRouteHook() {
  const sessionValue = Session.get(sessionKey);
  if (!(sessionValue && sessionValue.route === this.route.getName())) {
    delete Session.keys[sessionKey];
  }
  this.next();
  return;
};
