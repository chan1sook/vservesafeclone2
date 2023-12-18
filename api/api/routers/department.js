import { Router, json } from "express";
import APIError, {
  APIAuthRequiredError,
  APILackPermissionError,
  APIMalformedParameterError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APISiteTargetNotExistsError,
} from "../../utils/apierror.js";
import { error } from "../../utils/logging.js";
import { isSuperadmin } from "../../logics/user.js";
import {
  getDepartmentById,
  getDepartmentBySites,
} from "../../logics/department.js";
import DepartmentModel from "../../models/department.js";
import { getSiteByUser } from "../../logics/site.js";

const router = Router();

router.get("/departments/site/:id", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    const site = await getSiteByUser(req.params.id, req.session.userData._id);

    if (!site) {
      throw APISiteTargetNotExistsError;
    }

    const departments = await getDepartmentBySites(req.params.id);

    res.status(200).json({
      status: "OK",
      departments: departments.map((ele) => ele.toJSON()),
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

router.post("/department/add", json(), async (req, res) => {
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

    if (!req.body || !req.body.siteId) {
      throw APIMissingFormParameterError;
    }

    if (
      !Array.isArray(req.body.locations) ||
      req.body.locations.some((ele) => !ele)
    ) {
      throw APIMalformedParameterError;
    }

    const departmentData = new DepartmentModel({
      active: req.body.active,
      name: req.body.name,
      siteId: req.body.siteId,
      logoUrl: req.body.logoUrl,
      contractEmail: req.body.contractEmail,
      phoneNumber: req.body.phoneNumber,
      note: req.body.note,
      locations: req.body.locations,
    });

    await departmentData.save();
    const response = departmentData.toJSON();

    res.status(200).json({
      status: "OK",
      departmentData: response,
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

router.post("/department/edit", json(), async (req, res) => {
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

    const existDepartmentData = await getDepartmentById(req.body.id);
    if (!existDepartmentData) {
      throw APISiteTargetNotExistsError;
    }

    if (typeof req.body.active !== "undefined") {
      existDepartmentData.active = req.body.active;
    }
    if (typeof req.body.logoUrl !== "undefined") {
      existDepartmentData.logoUrl = req.body.logoUrl;
    }
    if (typeof req.body.name !== "undefined") {
      existDepartmentData.name = req.body.name;
    }
    if (typeof req.body.contractEmail !== "undefined") {
      existDepartmentData.contractEmail = req.body.contractEmail;
    }
    if (typeof req.body.phoneNumber !== "undefined") {
      existDepartmentData.phoneNumber = req.body.phoneNumber;
    }
    if (typeof req.body.note !== "undefined") {
      existDepartmentData.note = req.body.note;
    }
    if (typeof req.body.locations !== "undefined") {
      if (
        !Array.isArray(req.body.locations) ||
        req.body.locations.some((ele) => !ele)
      ) {
        throw APIMalformedParameterError;
      }

      existDepartmentData.locations = req.body.locations;
    }

    await existDepartmentData.save();
    const response = existDepartmentData.toJSON();

    res.status(200).json({
      status: "OK",
      departmentData: response,
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

router.post("/department/delete", json(), async (req, res) => {
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

    const existDepartmentData = await getDepartmentById(req.body.id);
    if (!existDepartmentData) {
      throw APISiteTargetNotExistsError;
    }

    await existDepartmentData.delete();

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
