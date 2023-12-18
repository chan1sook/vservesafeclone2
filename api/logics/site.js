import mongoose, { isObjectIdOrHexString } from "mongoose";
import SiteModel from "../models/site.js";
import { APIInvalidId } from "../utils/apierror.js";
import { isAdmin, isSuperadmin } from "./user.js";

export function getSiteEditLevel(siteData = {}, userData = {}) {
  const superadminEdit = isSuperadmin(userData);
  if (superadminEdit) {
    return "superadmin";
  }

  const adminEdit =
    isAdmin(userData) &&
    !!siteData.admins.find((ele) => ele.toString() === userData._id.toString());
  return adminEdit ? "admin" : null;
}

export function getSiteById(_id) {
  return SiteModel.findById(_id);
}

export function getSitesSuperadmins() {
  return SiteModel.find({});
}

export function getSitesByUser(adminId) {
  return SiteModel.find({
    $or: [
      {
        admins: adminId,
      },
      {
        managers: adminId,
      },
      {
        users: adminId,
      },
    ],
  });
}

export function getSiteByUser(id, adminId) {
  if (!isObjectIdOrHexString(id)) {
    throw APIInvalidId;
  }

  return SiteModel.findOne({
    _id: new mongoose.Types.ObjectId(id),
    $or: [
      {
        admins: adminId,
      },
      {
        managers: adminId,
      },
      {
        users: adminId,
      },
    ],
  });
}

export function siteToBasicJSON(siteDoc = new SiteModel(), userId) {
  const result = siteDoc.toJSON();
  result.isAdmin = userId
    ? result.admins.some((ele) => ele.toString() === userId.toString())
    : false;
  result.isManager = userId
    ? result.managers.some((ele) => ele.toString() === userId.toString())
    : false;
  result.isUser = userId
    ? result.users.some((ele) => ele.toString() === userId.toString())
    : false;

  delete result.admins;
  delete result.managers;
  delete result.users;

  return result;
}
