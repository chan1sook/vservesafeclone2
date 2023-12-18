import { init as initRuntime } from "./configs/runtime.js";
import { startMongoDbService } from "./services/mongoose.js";
import { startApiService } from "./api/api.js";
import { startRedisService } from "./services/redis.js";
import { initDevUsers } from "./logics/user.js";
import { startMqttService } from "./services/mqtt.js";

async function init() {
  initRuntime();

  await startRedisService();
  await startMongoDbService();

  await initDevUsers();

  startApiService(parseInt(process.env.API_PORT, 10));
  startMqttService(parseInt(process.env.MQTT_PORT, 10));
}

init();
