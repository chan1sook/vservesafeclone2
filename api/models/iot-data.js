import mongoose from "mongoose";

const iotDataSchema = new mongoose.Schema(
  {
    macAddress: { type: String, required: true },
    value: { type: Number },
    temp: { type: Number },
    humid: { type: Number },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

const IoTDataModel = mongoose.model("iotdata", iotDataSchema);

export default IoTDataModel;
