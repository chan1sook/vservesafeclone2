import mongoose from "mongoose";
import MongooseDelete from "mongoose-delete";

const userSchema = new mongoose.Schema(
  {
    active: { type: Boolean, default: false },
    username: { type: String, unique: true },
    hashedPw: { type: String, required: true, selected: false },
    role: {
      type: String,
      enum: ["user", "manager", "admin", "superadmin", "developer"],
    },
    avatarUrl: { type: String, default: "" },
    actualName: { type: String, default: "" },
    contractEmail: { type: String, default: "" },
    phoneNumber: { type: String, default: "" },
    position: { type: String, default: "" },
    address: { type: String, default: "" },
    note: { type: String, default: "" },
  },
  { timestamps: true }
);

userSchema.plugin(MongooseDelete, { overrideMethods: true, deletedBy: true });

const UserModel = mongoose.model("user", userSchema);
export default UserModel;
