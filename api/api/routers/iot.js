import { Router } from "express";

import { error } from "../../utils/logging.js";
import APIError from "../../utils/apierror.js";

const router = Router();

router.get("/iot/lists", async (req, res) => {
  try {
    const keys = await req.redisClient?.KEYS("vsafe-iot:*");
    const lists = {};
    if (Array.isArray(keys)) {
      const values = await req.redisClient?.MGET(keys);
      for (let i = 0; i < keys.length; i++) {
        const trimKeys = keys[i].substring("vsafe-iot:".length);
        lists[trimKeys] = values[i] || "";
      }
    }

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
    if (!req.query || typeof req.query.value === "undefined") {
      throw new APIError("Missing Parameter(s)", 400);
    }

    const value = req.query.value ? `${req.query.value}` : "";
    await req.redisClient?.SET(`vsafe-iot:${req.params.id}`, value);
    req.eventEmitter?.emit("vsafe-iot-set", { key: req.params.id, value });

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
    const data = await req.redisClient?.GET(`vsafe-iot:${req.params.id}`);
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
