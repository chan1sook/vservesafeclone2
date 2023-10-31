import dotenv from "dotenv";
import { log } from "../utils/logging.js";

function showRuntimeConfigs() {
  log([process.env.NODE_ENV], { name: "Runtime", tags: ["NODE_ENV"] });
}

export function init() {
  dotenv.config();
  log("Loaded Configs", { name: "Runtime" });
  showRuntimeConfigs();
}

export function isProductionMode() {
  return process.env.NODE_ENV === "production";
}

export function toggleProductionMode(isProduction) {
  if (!!isProduction) {
    process.env.NODE_ENV = "production";
  } else if (isProduction === false) {
    process.env.NODE_ENV = "development";
  } else {
    process.env.NODE_ENV = isProductionMode() ? "development" : "production";
  }

  return process.env.NODE_ENV;
}
