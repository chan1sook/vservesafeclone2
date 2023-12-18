import express from "express";
import cors from "cors";
import helmet from "helmet";
import { createServer } from "http";
import { Server as SIOServer } from "socket.io";

import { error, log } from "../utils/logging.js";
import session from "./session.js";
import indexRouter from "./routers/index.js";
import { getRedisClient } from "../services/redis.js";
import { getEventEmitter } from "../services/event.js";

export function startApiService(port = 4000) {
  const redisClient = getRedisClient();
  const eventEmitter = getEventEmitter();
  const app = express();
  const httpServer = createServer(app);
  const sessionMiddleware = session(redisClient);

  app.use(sessionMiddleware);
  app.use(
    cors({
      credentials: true,
      origin: function (origin, callback) {
        callback(null, true);
      },
    })
  );
  app.use(helmet({}));

  app.use((req, res, next) => {
    req.eventEmitter = eventEmitter;
    req.redisClient = redisClient;
    next();
  });

  app.use(indexRouter);

  const socketIOServer = new SIOServer(httpServer);
  socketIOServer.use((socket, next) =>
    sessionMiddleware(socket.request, {}, next)
  );
  socketIOServer.on("connection", (socket) => {
    log("Connected", { name: "SocketIO", tags: [socket.id] });
    socket.on("disconnect", () => {
      log("Disconnected", { name: "SocketIO", tags: [socket.id] });
    });
  });

  eventEmitter.on("vsafe-iot-set", ({ key, value }) => {
    socketIOServer.emit("vsafe-iot-set", { key, value });
  });

  socketIOServer.on("error", (err) => {
    error(err.message, { name: "SocketIO" });
  });

  httpServer.listen(port, () => {
    log([`Start at port `, `${port}`.green], { name: "API" });
  });

  return { io: socketIOServer, app };
}
