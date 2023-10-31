import session from "express-session";
import RedisStore from "connect-redis";

/**
 * @param {import("redis").RedisClientType} redisClient
 */
export default function sessionMiddleware(redisClient) {
  const store = new RedisStore({
    client: redisClient,
    prefix: "vsafe-session:",
  });

  return session({
    store,
    secret: process.env.COOKIE_SECRET,
    cookie: { maxAge: 86400000, sameSite: "lax" },
    resave: false,
    saveUninitialized: false,
    rolling: true,
  });
}
