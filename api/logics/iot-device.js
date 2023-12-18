import mongoose from "mongoose";
import IotDeviceModel from "../models/iot-device.js";

export function normalizeMacAddress(macAddress = "") {
  return macAddress.toUpperCase().replace(/:/g, "");
}

export function getIotDeviceById(_id) {
  return IotDeviceModel.findById(_id);
}

export function getIotDevicesBySite(siteid) {
  const site =
    typeof siteid === "string" ? new mongoose.Types.ObjectId(siteid) : siteid;

  return IotDeviceModel.find({ siteId: site, active: true });
}

export async function checkDeviceBySites(macAddress, sites = []) {
  const result = await IotDeviceModel.findOne({
    macAddress: macAddress,
    siteId: { $in: sites },
    active: true,
  });
  return !!result;
}
