import mongoose from "mongoose";
import MongooseDelete from "mongoose-delete";

const siteSchema = new mongoose.Schema(
  {
    active: { type: Boolean, default: false },
    name: { type: String, required: true },
    logoUrl: { type: String, default: "" },
    contractEmail: { type: String, default: "" },
    phoneNumber: { type: String, default: "" },
    admins: [{ type: mongoose.Types.ObjectId, ref: "user" }],
    managers: [{ type: mongoose.Types.ObjectId, ref: "user" }],
    users: [{ type: mongoose.Types.ObjectId, ref: "user" }],
    managerUserCap: { type: Number, default: 10 },
    userUserCap: { type: Number, default: 100 },
    examPackage: {
      enableExamLimits: { type: Boolean, default: true },
      examLimits: { type: Number, default: 5 },
      examLimitsDurationFrom: { type: Date }, // TODO ?
      examLimitsDurationTo: { type: Date }, // TODO ?
    },
    examConfig: {
      revealWrongAnswer: { type: Boolean, default: true }, // TODO ?...
    },
    notifyConfig: {
      enableNotify: { type: Boolean, default: true },
      notifyLevel: {
        type: String,
        enum: ["all", "admin-manager"],
        default: "all",
      },
    },
    welcomeScreenEn: { type: String, default: "", select: false },
    welcomeScreenTh: { type: String, default: "", select: false },
    note: { type: String, default: "" },
  },
  { timestamps: true }
);

siteSchema.plugin(MongooseDelete, { overrideMethods: true, deletedBy: true });

const SiteModel = mongoose.model("site", siteSchema);
export default SiteModel;
