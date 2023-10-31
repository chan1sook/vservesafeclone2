import bcrypt from "bcrypt";

import UserModel from "../models/user.js";
import { log } from "../utils/logging.js";

export async function initDevUsers() {
  const targetUser = await UserModel.findOne({ role: "developer" });
  if (!targetUser) {
    const newUser = new UserModel({
      active: true,
      username: process.env.INIT_DEV_USERNAME,
      hashedPw: await bcrypt.hash(process.env.INIT_DEV_PASSWORD, 12),
      role: "developer",
    });
    await newUser.save();
    log("Developer User Created", { name: "initDevUsers" });
  } else {
    if (!targetUser.active) {
      targetUser.active = true;
      await targetUser.save();
      log("Migrated Active Users", { name: "initDevUsers" });
    } else {
      log("Already Have Developer User", { name: "initDevUsers" });
    }
  }
}

export async function userLogin(username, password) {
  const targetUser = await UserModel.findOne({ username, active: true }).select(
    "+hashedPw"
  );
  if (targetUser) {
    if (await bcrypt.compare(password, targetUser.hashedPw)) {
      const response = targetUser.toJSON();
      delete response.hashedPw;
      return response;
    }
  }

  return null;
}

export async function getUserById(_id) {
  const targetUser = await UserModel.findById(_id);
  if (targetUser) {
    const response = targetUser.toJSON();
    delete response.hashedPw;
    return response;
  }

  return null;
}

export function getUsers() {
  return UserModel.find({});
}

export function getAdminUsers(
  { withInactive, withDevUsers } = { withInactive: false, withDevUsers: false }
) {
  const query = {
    role: { $in: ["admin", "superadmin"] },
  };

  if (!!withDevUsers) {
    query.role.$in.push("developer");
  }

  if (!withInactive) {
    query.active = true;
  }

  return UserModel.find(query);
}

export function isDeveloper(userData) {
  return (
    !!userData && typeof userData === "object" && userData.role === "developer"
  );
}

export function isSuperadmin(userData) {
  return (
    !!userData &&
    typeof userData === "object" &&
    (userData.role === "developer" || userData.role === "superadmin")
  );
}
