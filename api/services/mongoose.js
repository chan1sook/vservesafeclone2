import mongoose from "mongoose";
import { isProductionMode } from "../configs/runtime.js";
import { error, log } from "../utils/logging.js";

function getDatabaseName() {
  let dbName = process.env.DB_DBNAME || "vsecuresafe";
  if (!isProductionMode()) {
    dbName += "-dev";
  }
  return dbName;
}

export async function startMongoDbService() {
  try {
    let dbName = getDatabaseName();
    await mongoose.connect(process.env.DB_URI, { dbName: dbName });
    log([dbName.green, " Connected"], { name: "MongoDB" });
  } catch (err) {
    error(err.message, { name: "MongoDB" });
  }

  return mongoose.connection;
}

/**
 * Reload mongodb setting
 */
export async function reloadMongoDbDatabase() {
  try {
    await mongoose.disconnect();
    return initMongoDbService();
  } catch (err) {
    error(err.message, { name: "MongoDB" });
  }

  return mongoose.connection;
}
