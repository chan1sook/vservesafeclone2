import { Router } from "express";

import { error } from "../../utils/logging.js";
import APIError, {
  APIAuthRequiredError,
  APIDeviceTargetNotExistsError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APISiteTargetNotExistsError,
} from "../../utils/apierror.js";
import {
  getIoTDataCurrentByMacId,
  pushIoTData,
  getIoTListRangeByMacAddress,
  getIoTListRangeByDevices,
  getIoTListCurrentByDevices,
} from "../../logics/iot-data.js";
import dayjs from "dayjs";
import { getSiteByUser, getSitesByUser } from "../../logics/site.js";
import {
  checkDeviceBySites,
  getIotDevicesBySite,
} from "../../logics/iot-device.js";

const router = Router();

router.get("/iot/lists", async (req, res) => {
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

    const lists = await getIoTListCurrentByDevices(
      devices.map((ele) => ele.macAddress)
    );

    res.status(200).json({
      status: "OK",
      lists,
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

router.get("/iot/range", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    let endTime = dayjs().toDate();
    if (typeof req.query.end_ts !== undefined) {
      const n = parseInt(req.query.end_ts, 10);
      if (!Number.isNaN(n)) {
        endTime = dayjs(n).toDate();
      }
    }

    let startTime = dayjs().subtract(7, "days").toDate();
    if (typeof req.query.start_ts !== undefined) {
      const n = parseInt(req.query.start_ts, 10);
      if (!Number.isNaN(n)) {
        startTime = dayjs(n).toDate();
      }
    }

    const targetSite = await getSiteByUser(
      req.query.site_id,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    const devices = await getIotDevicesBySite(targetSite._id);

    const lists = await getIoTListRangeByDevices(
      devices.map((ele) => ele.macAddress),
      startTime,
      endTime
    );

    res.status(200).json({
      status: "OK",
      lists,
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

router.get("/iot/range_single/:id", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    let endTime = dayjs().toDate();
    if (typeof req.query.end_ts !== undefined) {
      const n = parseInt(req.query.end_ts, 10);
      if (!Number.isNaN(n)) {
        endTime = dayjs(n).toDate();
      }
    }

    let startTime = dayjs().subtract(7, "days").toDate();
    if (typeof req.query.start_ts !== undefined) {
      const n = parseInt(req.query.start_ts, 10);
      if (!Number.isNaN(n)) {
        startTime = dayjs(n).toDate();
      }
    }

    const sites = await getSitesByUser(req.session.userData._id);
    const isValid = await checkDeviceBySites(
      req.params.id,
      sites.map((ele) => ele._id)
    );

    if (!isValid) {
      throw APIDeviceTargetNotExistsError;
    }

    const lists = await getIoTListRangeByMacAddress(
      req.params.id,
      startTime,
      endTime
    );

    res.status(200).json({
      status: "OK",
      lists,
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

router.get("/iot/set/:id", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!req.query) {
      throw APIMissingFormParameterError;
    }

    const sites = await getSitesByUser(req.session.userData._id);
    const isValid = await checkDeviceBySites(
      req.params.id,
      sites.map((ele) => ele._id)
    );

    if (!isValid) {
      throw APIDeviceTargetNotExistsError;
    }

    const value = { ...req.query, time: Date.now().toString() };

    await pushIoTData(req.params.id, value);

    res.status(200).json({
      status: "OK",
      value,
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

router.get("/iot/get/:id", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    const sites = await getSitesByUser(req.session.userData._id);
    const isValid = await checkDeviceBySites(
      req.params.id,
      sites.map((ele) => ele._id)
    );

    if (!isValid) {
      throw APIDeviceTargetNotExistsError;
    }

    const data = await getIoTDataCurrentByMacId(req.params.id);
    res.status(200).json({
      status: "OK",
      data: data || "",
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

export default router;
