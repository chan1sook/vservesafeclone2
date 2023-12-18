import DepartmentModel from "../models/department.js";

export function getDepartmentById(_id) {
  return DepartmentModel.findById(_id);
}

export function getDepartmentBySites(siteId) {
  return DepartmentModel.find({
    siteId: siteId,
  });
}
