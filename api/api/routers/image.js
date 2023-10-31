import { Router } from "express";
import multer from "multer";
import fs from "fs/promises";
import imageType from "image-type";
import sharp from "sharp";
import proxy from "express-http-proxy";

import { error, log } from "../../utils/logging.js";
import APIError, {
  APIAuthRequiredError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APIMalformedParameterError,
  APISiteTargetNotExistsError,
} from "../../utils/apierror.js";
import SiteModel from "../../models/site.js";
import { isSuperadmin } from "../../logics/user.js";

const router = Router();
const imageUpload = multer({
  limits: {
    fileSize: 2097152, // 2 MiB
  },
  storage: multer.memoryStorage(),
});

router.post(
  "/avatar/update",
  imageUpload.single("avatar"),
  async (req, res) => {
    try {
      if (!req.session) {
        throw APIServerNoSessionError;
      }

      if (!req.session.userData) {
        throw APIAuthRequiredError;
      }

      if (!req.file) {
        throw APIMissingFormParameterError;
      }

      const fileType = await imageType(req.file.buffer);
      if (!fileType) {
        throw APIMalformedParameterError;
      }

      const identifier = req.session.userData._id.toString();

      await fs.mkdir("upload/avatar/", { recursive: true });

      const files = await fs.readdir("upload/avatar/");
      const oldFiles = files.filter((ele) => ele.startsWith(identifier));

      const filePath = `upload/avatar/${identifier}-${Date.now()}.png`;

      await sharp(req.file.buffer).resize(512, 512).png().toFile(filePath);

      for (const file of oldFiles) {
        fs.rm(`upload/avatar/${file}`)
          .then(() => {
            log("File Deleted", { name: "Avatar Upload", tags: [file] });
          })
          .catch((err) => {
            error(err.message, { name: "Avatar Upload" });
          });
      }

      res.status(200).json({
        status: "OK",
        path: filePath,
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
  }
);

router.use("/avatar/placeholder", proxy("https://i.pravatar.cc/"));

router.post(
  "/site-logo/update",
  imageUpload.single("logo"),
  async (req, res) => {
    try {
      if (!req.session) {
        throw APIServerNoSessionError;
      }

      if (!req.session.userData) {
        throw APIAuthRequiredError;
      }

      if (!isSuperadmin(req.session.userData)) {
        throw APILackPermissionError;
      }

      if (!req.body || !req.file) {
        throw APIMissingFormParameterError;
      }

      const fileType = await imageType(req.file.buffer);
      if (!fileType) {
        throw APIMalformedParameterError;
      }

      const identifier = req.body.id;
      const existSiteData = await SiteModel.findById(req.body.id);
      if (!existSiteData) {
        throw APISiteTargetNotExistsError;
      }

      await fs.mkdir("upload/site-logo/", { recursive: true });

      const files = await fs.readdir("upload/site-logo/");
      const oldFiles = files.filter((ele) => ele.startsWith(identifier));

      const filePath = `upload/site-logo/${identifier}-${Date.now()}.png`;

      await sharp(req.file.buffer).resize(512, 512).png().toFile(filePath);

      if (req.body.replace === true) {
        existSiteData.logoUrl = filePath;
        await existSiteData.save();
      }

      for (const file of oldFiles) {
        fs.rm(`upload/site-logo/${file}`)
          .then(() => {
            log("File Deleted", { name: "Site Logo Upload", tags: [file] });
          })
          .catch((err) => {
            error(err.message, { name: "Site Logo Upload" });
          });
      }

      res.status(200).json({
        status: "OK",
        path: filePath,
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
  }
);

// router.use("/site-logo/placeholder", proxy("https://fakeimg.pl/256x256?text=LOGO"));

export default router;
