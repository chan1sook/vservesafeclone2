import "colors";
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc.js";
import timezone from "dayjs/plugin/timezone.js";

dayjs.extend(utc);
dayjs.extend(timezone);

export function log(
  message = "",
  { name = "", tags = [], datetag = true } = {
    name: "",
    tags: [],
    datetag: true,
  }
) {
  const nameTag = name ? `[${name}]`.yellow : "";

  let datetimeTag = "";
  if (datetag === true) {
    const timestr = dayjs().tz("Asia/Bangkok").format("YYYY-MM-DDTHH:mm");
    datetimeTag = `[${timestr}]`.magenta;
  } else if (Number.isInteger(datetag) || datetag instanceof Date) {
    const timestr = dayjs(datetag)
      .tz("Asia/Bangkok")
      .format("YYYY-MM-DDTHH:mm");
    datetimeTag = `[${timestr}]`.magenta;
  }

  const remainTags = tags.map((tag) => `[${tag}]`.gray);

  const actualMessage = Array.isArray(message)
    ? ` ${message.join("")}`
    : ` ${message}`;

  console.log([datetimeTag, nameTag, ...remainTags, actualMessage].join(""));
}

export function warn(
  message = "",
  { name = "", tags = [], datetag = true } = {
    name: "",
    tags: [],
    datetag: true,
  }
) {
  const nameTag = name ? `[${name}]`.white : "";

  let datetimeTag = "";
  if (datetag === true) {
    const timestr = dayjs().tz("Asia/Bangkok").format("YYYY-MM-DDTHH:mm");
    datetimeTag = `[${timestr}]`.magenta;
  } else if (Number.isInteger(datetag) || datetag instanceof Date) {
    const timestr = dayjs(datetag)
      .tz("Asia/Bangkok")
      .format("YYYY-MM-DDTHH:mm");
    datetimeTag = `[${timestr}]`.magenta;
  }

  const remainTags = tags.map((tag) => `[${tag}]`.gray);

  const actualMessage = Array.isArray(message)
    ? ` ${message.join("")}`
    : ` ${message}`;

  console.warn([datetimeTag, nameTag, ...remainTags, actualMessage].join(""));
}

export function error(
  message = "",
  { name = "", tags = [], datetag = true } = {
    name: "",
    tags: [],
    datetag: true,
  }
) {
  const nameTag = name ? `[${name}]`.red : "";

  let datetimeTag = "";
  if (datetag === true) {
    const timestr = dayjs().tz("Asia/Bangkok").format("YYYY-MM-DDTHH:mm");
    datetimeTag = `[${timestr}]`.magenta;
  } else if (Number.isInteger(datetag) || datetag instanceof Date) {
    const timestr = dayjs(datetag)
      .tz("Asia/Bangkok")
      .format("YYYY-MM-DDTHH:mm");
    datetimeTag = `[${timestr}]`.magenta;
  }

  const remainTags = tags.map((tag) => `[${tag}]`.gray);

  const actualMessage = Array.isArray(message)
    ? ` ${message.join("")}`
    : ` ${message}`;

  console.error([datetimeTag, nameTag, ...remainTags, actualMessage].join(""));
}

export default Object.freeze({
  log,
  error,
});
