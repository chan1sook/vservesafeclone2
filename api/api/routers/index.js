import { Router } from "express";

import userRouter from "./users/index.js";
import siteRouter from "./site.js";
import departmentRouter from "./department.js";
import iotRouter from "./iot.js";
import deviceRouter from "./device.js";
import shedeinResponseRouter from "./shedein-res.js";
import fileRouter from "./files.js";

const router = Router();

router.use(userRouter);
router.use(siteRouter);
router.use(departmentRouter);
router.use(iotRouter);
router.use(deviceRouter);
router.use(shedeinResponseRouter);
router.use(fileRouter);

router.get("/", (req, res) => {
  res.status(200).send("OK");
});

export default router;
