import { Router, json } from "express";
import isEmail from "validator/lib/isEmail.js";
import bcrypt from "bcrypt";

import { error } from "../../../utils/logging.js";
import APIError, {
  APIAuthRequiredError,
  APILackPermissionError,
  APIMalformedParameterError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APISiteTargetNotExistsError,
  APISiteUserMaximumLimit,
  APIUserTargetNotExistsError,
} from "../../../utils/apierror.js";
import { getUserById, getUsersByIds, isAdmin } from "../../../logics/user.js";
import UserModel from "../../../models/user.js";
import { getSiteByUser } from "../../../logics/site.js";

const router = Router();

router.get("/siteusers", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
      throw APILackPermissionError;
    }

    const targetSite = await getSiteByUser(
      req.query.site_id,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    const withInactive = req.query.with_inactive === "true";
    const userIds = targetSite.managers.concat(targetSite.users);
    const users = await getUsersByIds(userIds, {
      withInactive: withInactive,
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

router.post("/siteuser/add", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
      throw APILackPermissionError;
    }

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    if (!["manager", "user"].includes(req.body.role)) {
      throw APIMalformedParameterError;
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

    const targetSite = await getSiteByUser(
      req.body.siteId,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
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

    if (userData.role === "manager") {
      if (
        targetSite.managers.length < targetSite.accountPackage.managers &&
        targetSite.managers.every(
          (ele) => ele.toString() !== userData._id.toString()
        )
      ) {
        targetSite.managers.push(userData._id);
      } else {
        throw APISiteUserMaximumLimit;
      }
    } else {
      if (
        targetSite.users.length < targetSite.accountPackage.users &&
        targetSite.users.every(
          (ele) => ele.toString() !== userData._id.toString()
        )
      ) {
        targetSite.users.push(userData._id);
      } else {
        throw APISiteUserMaximumLimit;
      }
    }

    await Promise.all([userData.save(), targetSite.save()]);

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

router.post("/siteuser/edit", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
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

    const targetSite = await getSiteByUser(
      req.body.siteId,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    if (
      targetSite.managers.every(
        (ele) => ele.toString() !== existsUserData._id.toString()
      ) &&
      targetSite.users.every(
        (ele) => ele.toString() !== existsUserData._id.toString()
      )
    ) {
      throw APIUserTargetNotExistsError;
    }

    if (typeof req.body.active !== "undefined") {
      existsUserData.active = req.body.active;
    }

    if (typeof req.body.role !== "undefined") {
      if (!["manager", "user"].includes(req.body.role)) {
        throw APIMalformedParameterError;
      }

      existsUserData.role = req.body.role;
      targetSite.managers = targetSite.managers.filter(
        (ele) => ele.toString() !== existsUserData._id.toString()
      );
      targetSite.users = targetSite.users.filter(
        (ele) => ele.toString() !== existsUserData._id.toString()
      );

      if (existsUserData.role === "manager") {
        if (targetSite.managers.length < targetSite.accountPackage.managers) {
          targetSite.managers.push(existsUserData._id);
        } else {
          throw APISiteUserMaximumLimit;
        }
      } else {
        if (targetSite.users.length < targetSite.accountPackage.users) {
          targetSite.users.push(existsUserData._id);
        } else {
          throw APISiteUserMaximumLimit;
        }
      }
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

    await Promise.all([existsUserData.save(), targetSite.save()]);
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

router.post("/siteuser/delete", json(), async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    if (!isAdmin(req.session.userData)) {
      throw APILackPermissionError;
    }

    if (!req.body) {
      throw APIMissingFormParameterError;
    }

    const existsUserData = await getUserById(req.body.id);
    if (!existsUserData) {
      throw APIUserTargetNotExistsError;
    }

    const targetSite = await getSiteByUser(
      req.body.siteId,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    targetSite.managers = targetSite.managers.filter(
      (ele) => ele.toString() !== existsUserData._id.toString()
    );
    targetSite.users = targetSite.users.filter(
      (ele) => ele.toString() !== existsUserData._id.toString()
    );
    await Promise.all([existsUserData.delete(), targetSite.save()]);

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
