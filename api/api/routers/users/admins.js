import { Router, json } from "express";
import isEmail from "validator/lib/isEmail.js";
import bcrypt from "bcrypt";

import { error } from "../../../utils/logging.js";
import APIError, {
  APIAuthRequiredError,
  APILackPermissionError,
  APIMalformedParameterError,
  APIMissingFormParameterError,
  APISelfUserProtection,
  APIServerNoSessionError,
  APIUserTargetNotExistsError,
} from "../../../utils/apierror.js";
import {
  getAdminUsers,
  getUserById,
  isDeveloper,
  isSuperadmin,
} from "../../../logics/user.js";
import UserModel from "../../../models/user.js";

const router = Router();

router.get("/adminusers", async (req, res) => {
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

    const withInactive = req.query.with_inactive === "true";
    const withDevUsers = req.query.with_devs === "true";

    const users = await getAdminUsers({
      withInactive: withInactive,
      withDevUsers: withDevUsers,
    });

    res.status(200).json({
      status: "OK",
      users: users.map((ele) => {
        const result = ele.toJSON();
        delete result.hashedPw;
        return result;
      }),
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

router.post("/adminuser/add", json(), async (req, res) => {
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

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    if (!["admin", "superadmin", "developer"].includes(req.body.role)) {
      throw APIMalformedParameterError;
    }

    if (req.body.role === "developer" && !isDeveloper(req.session.userData)) {
      throw APILackPermissionError;
    }

    if (
      !isEmail(req.body.username) ||
      !req.body.newPassword ||
      !req.body.newPasswordConfirm ||
      req.body.newPassword.length < 6 ||
      req.body.newPassword !== req.body.newPasswordConfirm
    ) {
      throw APIMalformedParameterError;
    }

    const userData = new UserModel({
      role: req.body.role,
      active: req.body.active,
      logoUrl: req.body.logoUrl || "",
      username: req.body.username,
      actualName: req.body.actualName,
      contractEmail: req.body.contractEmail,
      phoneNumber: req.body.phoneNumber || "",
      position: req.body.position || "",
      note: req.body.note,
      hashedPw: await bcrypt.hash(req.body.newPassword, 12),
    });

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

router.post("/adminuser/edit", json(), async (req, res) => {
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

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    const existsUserData = await getUserById(req.body.id, {
      withHashedPassword: true,
    });

    if (!existsUserData) {
      throw APIUserTargetNotExistsError;
    }

    if (existsUserData._id.toString() === req.session.userData._id.toString()) {
      throw APISelfUserProtection;
    }

    if (typeof req.body.active !== "undefined") {
      existsUserData.active = req.body.active;
    }

    if (typeof req.body.role !== "undefined") {
      if (!["admin", "superadmin", "developer"].includes(req.body.role)) {
        throw APIMalformedParameterError;
      }

      if (req.body.role === "developer" && !isDeveloper(req.session.userData)) {
        throw APILackPermissionError;
      }

      existsUserData.role = req.body.role;
    }

    if (typeof req.body.contractEmail !== "undefined") {
      existsUserData.contractEmail = req.body.contractEmail;
    }

    if (typeof req.body.phoneNumber !== "undefined") {
      existsUserData.phoneNumber = req.body.phoneNumber;
    }

    if (typeof req.body.position !== "undefined") {
      existsUserData.position = req.body.position;
    }

    if (typeof req.body.address !== "undefined") {
      existsUserData.address = req.body.address;
    }

    if (typeof req.body.note !== "undefined") {
      existsUserData.note = req.body.note;
    }

    if (req.body.needEditPassword === true) {
      if (
        !req.body.newPassword ||
        !req.body.newPasswordConfirm ||
        req.body.newPassword.length < 6 ||
        req.body.newPassword !== req.body.newPasswordConfirm
      ) {
        throw APIMalformedParameterError;
      }
    }

    await existsUserData.save();
    const response = existsUserData.toJSON();
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

router.post("/adminuser/delete", json(), async (req, res) => {
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

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    const existsUserData = await getUserById(req.body.id);
    if (!existsUserData) {
      throw APIUserTargetNotExistsError;
    }

    if (existsUserData._id.toString() === req.session.userData._id.toString()) {
      throw APISelfUserProtection;
    }

    await existsUserData.delete();

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
