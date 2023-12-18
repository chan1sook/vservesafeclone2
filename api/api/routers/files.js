import { Router, static as _static } from "express";
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
  APILackPermissionError,
  APIUserTargetNotExistsError,
} from "../../utils/apierror.js";
import { getUserByAvatar, isSuperadmin } from "../../logics/user.js";
import { getSiteById } from "../../logics/site.js";
import { getDepartmentById } from "../../logics/department.js";
import { nanoid } from "nanoid";
import path from "path";

const router = Router();
const imageUpload = multer({
  limits: {
    fileSize: 2097152, // 2 MiB
  },
  storage: multer.memoryStorage(),
});

const pdfUpload = multer({
  limits: {
    fileSize: 20971520, // 20 MiB
  },
  storage: multer.memoryStorage(),
});

// TODO restriction
// router.get("/upload/avatar/:fileName", async (req, res) => {
//   try {
//     if (!req.session) {
//       throw APIServerNoSessionError;
//     }

//     if (!req.session.userData) {
//       throw APIAuthRequiredError;
//     }

//     console.log();

//     const fullPath = `upload/avatar/${req.params.fileName}`;

//     const targetUser = await getUserByAvatar(fullPath);
//     if (!targetUser) {
//       throw APIUserTargetNotExistsError;
//     }

//     res.status(200).attachment(req.params.fileName).sendFile(fullPath);
//   } catch (err) {
//     let code = 500;
//     let errorId;

//     if (err instanceof APIError) {
//       code = err.code;
//       errorId = err.errorId;
//     }

//     error(err.message, { name: "API", tags: [`${code}`] });
//     res.status(code).json({
//       status: "Error",
//       code,
//       errorId,
//       message: err.message,
//     });
//   }
// });

router.use("/upload/avatar", _static("upload/avatar"));
router.use("/upload/site-logo", _static("upload/site-logo"));
router.use("/upload/department-logo", _static("upload/department-logo"));
router.use("/upload/sva-evidence", _static("upload/sva-evidence"));

router.use("/avatar/placeholder", proxy("https://i.pravatar.cc/"));

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

      if (!req.body || !req.file) {
        throw APIMissingFormParameterError;
      }

      const fileType = await imageType(req.file.buffer);
      if (!fileType) {
        throw APIMalformedParameterError;
      }

      const identifier = req.body.id;
      const existSiteData = await getSiteById(req.body.id);
      if (!existSiteData) {
        throw APISiteTargetNotExistsError;
      }

      const editLevel = getSiteEditLevel(existSiteData, req.session.userData);

      if (!editLevel) {
        throw APILackPermissionError;
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
router.post(
  "/department-logo/update",
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
      const existDepartmentData = await getDepartmentById(req.body.id);
      if (!existDepartmentData) {
        throw APISiteTargetNotExistsError;
      }

      await fs.mkdir("upload/department-logo/", { recursive: true });

      const files = await fs.readdir("upload/department-logo/");
      const oldFiles = files.filter((ele) => ele.startsWith(identifier));

      const filePath = `upload/department-logo/${identifier}-${Date.now()}.png`;

      await sharp(req.file.buffer).resize(512, 512).png().toFile(filePath);

      if (req.body.replace === true) {
        existDepartmentData.logoUrl = filePath;
        await existDepartmentData.save();
      }

      for (const file of oldFiles) {
        fs.rm(`upload/department-logo/${file}`)
          .then(() => {
            log("File Deleted", {
              name: "Department Logo Upload",
              tags: [file],
            });
          })
          .catch((err) => {
            error(err.message, { name: "Department Logo Upload" });
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

router.post(
  "/sva-evidence/upload",
  pdfUpload.single("file"),
  async (req, res) => {
    try {
      if (!req.session) {
        throw APIServerNoSessionError;
      }

      if (!req.session.userData) {
        throw APIAuthRequiredError;
      }

      if (!req.body || !req.file) {
        throw APIMissingFormParameterError;
      }

      const identifier = nanoid();
      await fs.mkdir("upload/sva-evidence/", { recursive: true });

      const filePath = `upload/sva-evidence/${identifier}${path.extname(
        req.file.originalname
      )}`;
      await fs.writeFile(filePath, req.file.buffer);

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

export default router;
