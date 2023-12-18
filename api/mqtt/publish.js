import { pushIoTData } from "../logics/iot-data.js";

const $SYS_PREFIX = "$SYS/";

/**
 * @param {import("aedes").Client} client
 * @param {import("aedes").PublishPacket} packet
 * @param {Error | null | undefined} callback
 * @param {import("events")} eventEmitter
 */
async function authorizePublish(client, packet, callback, eventEmitter) {
  try {
    if (packet.topic.startsWith($SYS_PREFIX)) {
      throw new Error(`${$SYS_PREFIX} topic is reserved`);
    }

    if (packet.topic.startsWith("push_")) {
      const macAddress = packet.topic.replace(/^push_/, "");
      const payloadStr = packet.payload.toString();

      pushIoTData(macAddress, payloadStr);
      callback(null);
    }
  } catch (err) {
    callback(err);
  }
}

export default authorizePublish;
