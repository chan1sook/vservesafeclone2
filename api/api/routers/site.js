import { Router, json } from "express";
import APIError, {
  APIAuthRequiredError,
  APILackPermissionError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APISiteTargetNotExistsError,
} from "../../utils/apierror.js";
import { error } from "../../utils/logging.js";
import SiteModel from "../../models/site.js";
import { isAdmin, isSuperadmin } from "../../logics/user.js";
import {
  getSiteById,
  getSiteByUser,
  getSiteEditLevel,
  getSitesByUser,
  getSitesSuperadmins,
  siteToBasicJSON,
} from "../../logics/site.js";

const router = Router();

router.get("/sites/available", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    const sites = await getSitesByUser(req.session.userData._id);

    res.status(200).json({
      status: "OK",
      sites: sites.map((ele) => siteToBasicJSON(ele, req.session.userData._id)),
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

router.get("/site/:id", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    const site = await getSiteByUser(
      req.params.id,
      req.session.userData._id
    ).select("+welcomeScreenEn +welcomeScreenTh");

    if (!site) {
      throw APISiteTargetNotExistsError;
    }

    const result = siteToBasicJSON(site, req.session.userData._id);
    if (isAdmin(req.session.userData)) {
      result.admins = site.admins;
      result.managers = site.managers;
      result.users = site.users;
    }

    res.status(200).json({
      status: "OK",
      site: result,
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

router.get("/sites/all", async (req, res) => {
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

    const sites = await getSitesSuperadmins();
    res.status(200).json({
      status: "OK",
      sites: sites.map((ele) => ele.toJSON()),
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

router.post("/site/add", json(), async (req, res) => {
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

    const siteData = new SiteModel({
      active: req.body.active,
      name: req.body.name,
      logoUrl: req.body.logoUrl,
      contractEmail: req.body.contractEmail,
      phoneNumber: req.body.phoneNumber,
      admins: req.body.admins,
      managerUserCap: req.body.managerUserCap,
      userUserCap: req.body.userUserCap,
      welcomeScreenEn: req.body.welcomeScreenEn,
      welcomeScreenTh: req.body.welcomeScreenTh,
      note: req.body.note,
    });

    await siteData.save();
    const response = siteData.toJSON();

    res.status(200).json({
      status: "OK",
      siteData: response,
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

router.post("/site/edit", json(), async (req, res) => {
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

    const existSiteData = await getSiteById(req.body.id);
    if (!existSiteData) {
      throw APISiteTargetNotExistsError;
    }

    const editLevel = getSiteEditLevel(existSiteData, req.session.userData);

    if (!editLevel) {
      throw APILackPermissionError;
    }

    if (editLevel === "superadmin") {
      if (typeof req.body.active !== "undefined") {
        existSiteData.active = req.body.active;
      }
      if (typeof req.body.admins !== "undefined") {
        existSiteData.admins = req.body.admins;
      }
    }

    if (typeof req.body.name !== "undefined") {
      existSiteData.name = req.body.name;
    }
    if (typeof req.body.contractEmail !== "undefined") {
      existSiteData.contractEmail = req.body.contractEmail;
    }
    if (typeof req.body.phoneNumber !== "undefined") {
      existSiteData.phoneNumber = req.body.phoneNumber;
    }
    if (typeof req.body.managerUserCap !== "undefined") {
      existSiteData.managerUserCap = req.body.managerUserCap;
    }
    if (typeof req.body.userUserCap !== "undefined") {
      existSiteData.userUserCap = req.body.userUserCap;
    }
    if (typeof req.body.welcomeScreenEn !== "undefined") {
      existSiteData.welcomeScreenEn = req.body.welcomeScreenEn;
    }
    if (typeof req.body.welcomeScreenTh !== "undefined") {
      existSiteData.welcomeScreenTh = req.body.welcomeScreenTh;
    }
    if (typeof req.body.logoUrl !== "undefined") {
      existSiteData.logoUrl = req.body.logoUrl;
    }
    if (typeof req.body.note !== "undefined") {
      existSiteData.note = req.body.note;
    }

    await existSiteData.save();
    const response = existSiteData.toJSON();

    res.status(200).json({
      status: "OK",
      siteData: response,
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

router.post("/site/delete", json(), async (req, res) => {
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

    const existSiteData = await getSiteById(req.body.id);
    if (!existSiteData) {
      throw APISiteTargetNotExistsError;
    }

    await existSiteData.delete();

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
