import { Router, json } from "express";
import bcrypt from "bcrypt";

import { error } from "../../../utils/logging.js";
import APIError, {
  APILoginAuthFailedError,
  APIAuthRequiredError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APIAuthFailedError,
  APIMalformedParameterError,
} from "../../../utils/apierror.js";
import { getUserById, userLogin } from "../../../logics/user.js";
import UserModel from "../../../models/user.js";

const router = Router();

router.post("/login", json(), async (req, res) => {
  try {
    if (!req.body || !req.body.username || !req.body.password) {
      throw APIMissingFormParameterError;
    }

    const fullUserData = await userLogin(req.body.username, req.body.password);
    if (fullUserData) {
      const userData = {
        _id: fullUserData._id,
        username: fullUserData.username,
        role: fullUserData.role,
      };

      req.session.userData = userData;

      res.status(200).json({
        status: "OK",
        userData: fullUserData,
      });
    } else {
      throw APILoginAuthFailedError;
    }
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

router.get("/user", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    let fullUserData = {
      role: "guest",
    };

    if (req.session.userData) {
      const userData = await getUserById(req.session.userData._id);
      if (userData) {
        fullUserData = userData;
      }
    }

    res.status(200).json({
      status: "OK",
      userData: fullUserData,
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

router.post("/user/update", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    const userData = await UserModel.findById(req.session.userData._id).select(
      "+hashedPw"
    );

    if (typeof req.body.avatarUrl !== "undefined") {
      userData.avatarUrl = req.body.avatarUrl;
    }
    if (typeof req.body.actualName !== "undefined") {
      userData.actualName = req.body.actualName;
    }
    if (typeof req.body.contractEmail !== "undefined") {
      userData.contractEmail = req.body.contractEmail;
    }
    if (typeof req.body.phoneNumber !== "undefined") {
      userData.phoneNumber = req.body.phoneNumber;
    }
    if (typeof req.body.position !== "undefined") {
      userData.position = req.body.position;
    }
    if (typeof req.body.address !== "undefined") {
      userData.address = req.body.address;
    }
    if (typeof req.body.note !== "undefined") {
      userData.note = req.body.note;
    }

    if (req.body.needEditPassword === true) {
      const isMatch = await bcrypt.compare(
        req.body.oldPassword,
        userData.hashedPw
      );
      if (!isMatch) {
        throw APIAuthFailedError;
      }

      if (
        !req.body.newPassword ||
        !req.body.newPasswordConfirm ||
        req.body.newPassword.length < 6 ||
        req.body.newPassword !== req.body.newPasswordConfirm
      ) {
        throw APIMalformedParameterError;
      }

      userData.hashedPw = await bcrypt.hash(req.body.newPassword, 12);
    }

    await userData.save();
    const response = userData.toJSON();
    delete response.hashedPw;

    res.status(200).json({
      status: "OK",
      userData: response,
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

router.post("/logout", (req, res) => {
  try {
    delete req.session.userData;

    res.status(200).json({
      status: "OK",
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
