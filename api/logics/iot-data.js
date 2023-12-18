import dayjs from "dayjs";
import IotDataModel from "../models/iot-data.js";
import { getRedisClient } from "../services/redis.js";
import { getEventEmitter } from "../services/event.js";

function normalizeMacAddress(macAddress = "") {
  return macAddress.toUpperCase().replace(/:/g, "");
}

function filterRawData(data = {}) {
  return {
    time: data.time,
    value: data.value,
    temp: data.temp,
    humid: data.humid,
  };
}

// CompositePayload = "t:x,y:k,a:z,..."
export function splitCompositePayload(payload = "") {
  const tokens = payload.split(",");
  const result = {};
  for (const token of tokens) {
    const subtoken = token.split(":");
    if (subtoken.length === 2) {
      const n = parseFloat(subtoken[1], 10);
      if (Number.isFinite(n)) {
        result[subtoken[0]] = n;
      }
    }
  }
  return result;
}

function transformCompositePayload(payload = {}) {
  const result = {};
  for (const key of Object.keys(payload)) {
    const value = payload[key];

    if (Number.isFinite(value)) {
      result[key] = value;
    } else {
      const n = parseFloat(value, 10);
      if (Number.isFinite(n)) {
        result[key] = n;
      }
    }
  }
  return result;
}

function toPayloadString(payload = {}) {
  return Object.keys(payload)
    .map((key) => {
      return `${key}:${payload[key]}`;
    })
    .join(",");
}

export async function pushIoTData(macAddress = "", payload = "") {
  const normMacAddress = normalizeMacAddress(macAddress);
  let result = {};
  if (typeof payload === "string") {
    result = splitCompositePayload(payload);
  } else if (typeof payload === "object" && payload) {
    result = transformCompositePayload(payload);
  } else if (typeof payload === "number") {
    result = splitCompositePayload(`value:${payload}`);
  }

  if (!result.time) {
    result.time = Date.now();
  }

  const data = new IotDataModel({
    macAddress: normMacAddress,
    ...result,
  });
  data.createdAt = dayjs(result.time).toDate();

  let recordPayload = "";
  if (payload === "string") {
    recordPayload = payload;
  } else if (typeof payload === "object" && payload) {
    recordPayload = toPayloadString(payload);
  } else if (typeof payload === "number") {
    recordPayload = `value:${payload}`;
  }
  if (!recordPayload.includes("time")) {
    if (recordPayload != "") {
      recordPayload += ",";
    }
    recordPayload += `time:${result.time}`;
  }

  await getRedisClient().SET(`vsafe-iot:${normMacAddress}`, recordPayload);

  getEventEmitter().emit("vsafe-iot-set", {
    key: normMacAddress,
    value: result,
  });

  return await data.save({ timestamps: false });
}

function isKeyEmpty(payload = {}) {
  const exitsKeys = Object.keys(payload);
  return (
    exitsKeys.length === 0 ||
    (exitsKeys.length === 1 && exitsKeys.includes("time"))
  );
}

export async function getIoTDataCurrentByMacId(macAddress) {
  const normMacAddress = normalizeMacAddress(macAddress);

  const result = await getRedisClient().GET(`vsafe-iot:${normMacAddress}`);

  if (typeof result === "string") {
    const actualResult = splitCompositePayload(result);
    if (!isKeyEmpty(actualResult)) {
      return actualResult;
    }
  }

  const data = await IotDataModel.findOne({
    macAddress: normMacAddress,
  }).sort({ macAddress: 1, createdBy: -1 });

  if (data) {
    const result = filterRawData(data);
    result.time = dayjs(result.createdAt).valueOf();
    return result;
  }

  return null;
}

export async function getIoTListRangeByDevices(
  macAddress = [],
  startTime = 0,
  endTime = Date.now()
) {
  const dataset = await IotDataModel.find({
    macAddress: { $in: macAddress },
    createdAt: {
      $gte: dayjs(startTime).toDate(),
      $lte: dayjs(endTime).toDate(),
    },
  }).sort({ createdAt: -1 });

  const lists = {};
  for (const rawdata of dataset) {
    const formattedData = {
      ...filterRawData(rawdata),
      time: dayjs(rawdata.createdAt).valueOf(),
    };

    if (!Array.isArray(lists[rawdata.macAddress])) {
      lists[rawdata.macAddress] = [formattedData];
    } else {
      lists[rawdata.macAddress].push(formattedData);
    }
  }

  return lists;
}

export async function getIoTListRangeByMacAddress(
  macAddress,
  startTime = 0,
  endTime = Date.now()
) {
  const dataset = await IotDataModel.find({
    macAddress,
    createdAt: {
      $gte: dayjs(startTime).toDate(),
      $lte: dayjs(endTime).toDate(),
    },
  }).sort({ createdAt: -1 });

  const lists = {};
  for (const rawdata of dataset) {
    const formattedData = {
      ...filterRawData(rawdata),
      time: dayjs(rawdata.createdAt).valueOf(),
    };

    if (!Array.isArray(lists[rawdata.macAddress])) {
      lists[rawdata.macAddress] = [formattedData];
    } else {
      lists[rawdata.macAddress].push(formattedData);
    }
  }

  return lists;
}
export async function getIoTListCurrentByDevices(macAddress = []) {
  const lists = {};

  if (macAddress.length === 0) {
    return lists;
  }

  const keys = macAddress.map((ele) => `vsafe-iot:${ele}`);
  const values = await getRedisClient().MGET(keys);
  const dbPushMacs = [];
  for (let i = 0; i < keys.length; i++) {
    const trimKeys = keys[i].substring("vsafe-iot:".length);
    lists[trimKeys] = splitCompositePayload(values[i] || "");

    if (isKeyEmpty(lists[trimKeys])) {
      dbPushMacs.push(trimKeys);
    }
  }

  if (dbPushMacs.length > 0) {
    const results = await IotDataModel.aggregate([
      {
        $match: {
          macAddress: { $in: dbPushMacs },
        },
      },
      {
        $sort: { _id: -1 },
      },
      {
        $group: {
          _id: "$macAddress",
          createdAt: { $first: "$createdAt" },
          macAddress: { $first: "$macAddress" },
          time: { $first: "$time" },
          value: { $first: "$value" },
          temp: { $first: "$temp" },
          humid: { $first: "$humid" },
        },
      },
    ]);

    for (const result of results) {
      lists[result.macAddress] = filterRawData(result);
      lists[result.macAddress].time = dayjs(result.createdAt).valueOf();
    }
  }

  return lists;
}
