import mongoose from "mongoose";
import MongooseDelete from "mongoose-delete";

const iotDeviceSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    active: { type: Boolean, default: false },
    siteId: { type: mongoose.Types.ObjectId, ref: "site" },
    macAddress: { type: String, required: true, unique: true },
    type: { type: String, required: true },
  },
  { timestamps: true }
);

iotDeviceSchema.plugin(MongooseDelete, {
  overrideMethods: true,
  deletedBy: true,
});

const IoTDeviceModel = mongoose.model("ioddevice", iotDeviceSchema);
export default IoTDeviceModel;
