import { init as initRuntime } from "./configs/runtime.js";
import { startMongoDbService } from "./services/mongoose.js";
import { startApiService } from "./api/api.js";
import { startRedisService } from "./services/redis.js";
import { initDevUsers } from "./logics/user.js";

async function init() {
  initRuntime();

  const redisClient = await startRedisService();
  const mongoConnection = await startMongoDbService();

  await initDevUsers();

  startApiService(parseInt(process.env.API_PORT, 10));
}

init();
