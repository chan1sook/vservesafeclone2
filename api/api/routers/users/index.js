import { Router } from "express";

import loginRouter from "./login.js";
import adminsRouter from "./admins.js";

const router = Router();

router.use(loginRouter);
router.use(adminsRouter);

export default router;
