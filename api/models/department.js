import mongoose from "mongoose";
import MongooseDelete from "mongoose-delete";

const departmentSchema = new mongoose.Schema(
  {
    active: { type: Boolean, default: false },
    name: { type: String, required: true },
    siteId: { type: mongoose.Types.ObjectId, ref: "site" },
    logoUrl: { type: String, default: "" },
    contractEmail: { type: String, default: "" },
    phoneNumber: { type: String, default: "" },
    note: { type: String, default: "" },
    locations: [
      {
        type: String,
        required: true,
      },
    ],
  },
  { timestamps: true }
);

departmentSchema.plugin(MongooseDelete, {
  overrideMethods: true,
  deletedBy: true,
});

const DepartmentModel = mongoose.model("department", departmentSchema);
export default DepartmentModel;
