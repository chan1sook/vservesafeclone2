import { Router } from "express";

import userRouter from "./users/index.js";
import siteRouter from "./site.js";
import iotRouter from "./iot.js";
import imageRouter from "./image.js";

const router = Router();

router.use(userRouter);
router.use(siteRouter);
router.use(iotRouter);
router.use(imageRouter);

router.get("/", (req, res) => {
  res.status(200).send("OK");
});

export default router;
