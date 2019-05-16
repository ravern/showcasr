const Router = require('koa-router');
const websocket = require('koa-easy-ws');

const projects = require('./projects');
const live = require('./live');

const buildProjectsRouter = env => {
  const router = new Router();
  projects(env, router);
  return router;
};

const buildLiveRouter = env => {
  const router = new Router();
  live(env, router);
  return router;
};

const buildRouter = env => {
  const router = new Router();

  router.use(websocket());

  const projectsRouter = buildProjectsRouter(env);
  router.use(
    '/projects',
    projectsRouter.routes(),
    projectsRouter.allowedMethods(),
  );

  const liveRouter = buildLiveRouter(env);
  router.use('/live', liveRouter.routes(), liveRouter.allowedMethods());

  return router;
};

module.exports = (env, app) => {
  const router = buildRouter(env);
  app.use(router.routes(), router.allowedMethods());
};