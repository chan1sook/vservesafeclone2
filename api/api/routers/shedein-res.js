import { Router, json } from "express";
import APIError, {
  APIAuthRequiredError,
  APILackPermissionError,
  APIMissingFormParameterError,
  APIServerNoSessionError,
  APIShedeinResponseTargetNotExistsError,
  APISiteTargetNotExistsError,
} from "../../utils/apierror.js";
import { error } from "../../utils/logging.js";
import ShedeinResponseModel from "../../models/shedein-fs-res.js";
import { isAdmin } from "../../logics/user.js";
import {
  getShedeinResponsesByAnswer,
  getShedeinResponsesById,
  getShedeinResponsesBySite,
} from "../../logics/shedein-res.js";
import { getSiteByUser } from "../../logics/site.js";
const router = Router();

router.get("/shedein-res/history", async (req, res) => {
  try {
    if (!req.session) {
      throw APIServerNoSessionError;
    }

    if (!req.session.userData) {
      throw APIAuthRequiredError;
    }

    const adminMode = isAdmin(req.session.userData);
    const targetSite = await getSiteByUser(
      req.query.site_id,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    const query = adminMode
      ? getShedeinResponsesBySite(req.query.form_id, req.query.site_id).sort({
          _id: -1,
        })
      : getShedeinResponsesByAnswer(
          req.query.form_id,
          req.session.userData._id
        );
    const shedeinResponseList = await query
      .sort({ _id: -1 })
      .populate("answerBy");

    const response = shedeinResponseList.map((ele) => {
      const result = ele.toJSON();
      delete result.answer;
      result.answerBy = result.answerBy.username;
      return result;
    });

    res.status(200).json({
      status: "OK",
      shedeinResponses: response,
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

router.get("/shedein-res/get/:id", async (req, res) => {
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
    const shedeinResponse = await getShedeinResponsesById(
      req.params.id
    ).populate("answerBy");

    if (!shedeinResponse) {
      throw APIShedeinResponseTargetNotExistsError;
    }

    const targetSite = await getSiteByUser(
      shedeinResponse.siteId,
      req.session.userData._id
    );

    if (!targetSite) {
      throw APISiteTargetNotExistsError;
    }

    const response = shedeinResponse.toJSON();
    response.answerBy = response.answerBy.username;
    res.status(200).json({
      status: "OK",
      shedeinResponse: response,
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

router.post("/shedein-res/add", json(), async (req, res) => {
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

    const shedeinResData = new ShedeinResponseModel({
      formId: req.body.formId,
      siteId: req.body.siteId,
      departmentId: req.body.departmentId,
      location: req.body.location,
      answerBy: req.session.userData._id,
      answerDate: req.body.answerDate,
      answers: req.body.answers,
    });

    await shedeinResData.save();
    const response = shedeinResData.toJSON();

    res.status(200).json({
      status: "OK",
      shedeinResponse: response,
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
