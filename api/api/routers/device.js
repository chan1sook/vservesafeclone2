import { Router, json } from "express";

import { error } from "../../utils/logging.js";
import APIError, {
  APIAuthRequiredError,
  APILackPermissionError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APISiteTargetNotExistsError,
} from "../../utils/apierror.js";
import { getSiteByUser } from "../../logics/site.js";
import {
  getIotDeviceById,
  getIotDevicesBySite,
  normalizeMacAddress,
} from "../../logics/iot-device.js";
import { isAdmin } from "../../logics/user.js";
import IoTDeviceModel from "../../models/iot-device.js";

const router = Router();

router.get("/devices/all", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    const targetSite = await getSiteByUser(
      req.query.site_id,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    const devices = await getIotDevicesBySite(targetSite._id);

    res.status(200).json({
      status: "OK",
      devices: devices.map((ele) => ele.toJSON()),
    });
  } catch (err) {
    let code = 500;

    if (err instanceof APIError) {
      code = err.code;
    }

    error(err.message, { name: "API", tags: [`${code}`] });
    res.status(code).json({
      status: "Error",
      code,
      message: err.message,
    });
  }
});

router.post("/device/add", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
      throw APILackPermissionError;
    }

    if (!req.body || !req.body.siteId) {
      throw APIMissingFormParameterError;
    }

    const iotDeviceData = new IoTDeviceModel({
      active: req.body.active,
      name: req.body.name,
      siteId: req.body.siteId,
      macAddress: normalizeMacAddress(req.body.macAddress),
      type: req.body.type,
    });

    await iotDeviceData.save();
    const response = iotDeviceData.toJSON();

    res.status(200).json({
      status: "OK",
      iotDeviceData: response,
    });
  } catch (err) {
    let code = 500;
    let errorId;

    if (err instanceof APIError) {
      code = err.code;
      errorId = err.errorId;
    }

    error(err.message, { name: "API", tags: [`${code}`] });
    res.status(code).json({
      status: "Error",
      code,
      errorId,
      message: err.message,
    });
  }
});

router.post("/device/edit", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
      throw APILackPermissionError;
    }

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    const existIotDeviceData = await getIotDeviceById(req.body.id);
    if (!existIotDeviceData) {
      throw APISiteTargetNotExistsError;
    }

    if (typeof req.body.active !== "undefined") {
      existIotDeviceData.active = req.body.active;
    }
    if (typeof req.body.name !== "undefined") {
      existIotDeviceData.name = req.body.name;
    }
    if (typeof req.body.macAddress !== "undefined") {
      existIotDeviceData.macAddress = normalizeMacAddress(req.body.macAddress);
    }
    if (typeof req.body.type !== "undefined") {
      existIotDeviceData.type = req.body.type;
    }

    await existIotDeviceData.save();
    const response = existIotDeviceData.toJSON();

    res.status(200).json({
      status: "OK",
      iotDeviceData: response,
    });
  } catch (err) {
    let code = 500;
    let errorId;

    if (err instanceof APIError) {
      code = err.code;
      errorId = err.errorId;
    }

    error(err.message, { name: "API", tags: [`${code}`] });
    res.status(code).json({
      status: "Error",
      code,
      errorId,
      message: err.message,
    });
  }
});

router.post("/device/delete", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
      throw APILackPermissionError;
    }

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    const existDeviceData = await getIotDeviceById(req.body.id);
    if (!existDeviceData) {
      throw APISiteTargetNotExistsError;
    }

    await existDeviceData.delete();

    res.status(200).json({
      status: "OK",
    });
  } catch (err) {
    let code = 500;
    let errorId;

    if (err instanceof APIError) {
      code = err.code;
      errorId = err.errorId;
    }

    error(err.message, { name: "API", tags: [`${code}`] });
    res.status(code).json({
      status: "Error",
      code,
      errorId,
      message: err.message,
    });
  }
});

export default router;
