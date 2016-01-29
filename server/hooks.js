const hooks = Iron.Router.hooks;

function skip() {
  this.next();
}

hooks.authenticate = skip;

hooks.authorize = skip;

hooks.noAuth = skip;
