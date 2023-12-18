import net from "net";

import "colors";
import Aedes from "aedes";

import authenticate from "../mqtt/auth.js";
import authorizeSubscribe from "../mqtt/subscribe.js";
import authorizePublish from "../mqtt/publish.js";
import { error, log } from "../utils/logging.js";
import { getEventEmitter } from "./event.js";

const eventEmitter = getEventEmitter();
let aedesServer = new Aedes({
  authenticate,
  authorizeSubscribe,
  authorizePublish: (...args) => {
    authorizePublish(...args, eventEmitter);
  },
});

export function getMqttClient() {
  return aedesServer;
}

export async function startMqttService(port = 4100) {
  aedesServer = new Aedes({
    authenticate,
    authorizeSubscribe,
    authorizePublish: (...args) => {
      authorizePublish(...args, eventEmitter);
    },
  });

  const server = net.createServer(aedesServer.handle);

  aedesServer.on("client", (client) => {
    log(`[${client.id}]`.gray + " Connected", { name: "MQTT Broker" });
  });

  aedesServer.on("clientDisconnect", (client) => {
    log(`[${client.id}]`.gray + " Disconnected", { name: "MQTT Broker" });
  });

  server.listen(port, () => {
    log(`Server Start at Port ` + `${port}`.green, { name: "MQTT Broker" });
  });

  return aedesServer;
}
