import { Router } from "express";

import loginRouter from "./login.js";
import adminsRouter from "./admins.js";
import siteusersRouter from "./siteusers.js";

const router = Router();

router.use(loginRouter);
router.use(adminsRouter);
router.use(siteusersRouter);

export default router;
