import redis from "redis";
import { error, log } from "../utils/logging.js";

let redisClient = redis.createClient();

export function getRedisClient() {
  return redisClient;
}

export async function startRedisService() {
  redisClient = redis.createClient();
  redisClient.on("connect", () => {
    log(`Connected`, { name: "Redis" });
  });

  redisClient.on("error", (err) => {
    console.error(err.stack);

    error(err.message, { name: "Redis" });
  });

  await redisClient.connect();
  return redisClient;
}
