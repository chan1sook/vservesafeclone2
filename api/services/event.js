import EventEmitter from "events";

const globalEventEmitter = new EventEmitter();

export function getEventEmitter() {
  return globalEventEmitter;
}
