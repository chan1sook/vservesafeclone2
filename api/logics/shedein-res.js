import mongoose from "mongoose";
import ShedeinResponseModel from "../models/shedein-fs-res.js";

export function getShedeinResponsesById(id) {
  return ShedeinResponseModel.findById(id);
}

export function getShedeinResponsesBySite(formId, siteId) {
  return ShedeinResponseModel.find({
    formId: formId,
    siteId: new mongoose.Types.ObjectId(siteId.toString()),
  });
}

export function getShedeinResponsesByAnswer(formId, userid) {
  return ShedeinResponseModel.find({
    formId: formId,
    answerBy: new mongoose.Types.ObjectId(userid.toString()),
  });
}
