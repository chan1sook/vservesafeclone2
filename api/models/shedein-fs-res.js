import mongoose from "mongoose";

const shedeinAnswerSchemaMixed = new mongoose.Schema({
  // SVA
  questionId: { type: String },
  baseScore: { type: Number },
  complicant: { type: Boolean },
  deduction: { type: Number },
  evidence: { type: String },
  filePath: { type: String },
});

const shedeinResponseSchema = new mongoose.Schema(
  {
    formId: { type: String, required: true, index: true },
    siteId: { type: mongoose.Types.ObjectId, ref: "site" },
    departmentId: { type: mongoose.Types.ObjectId, ref: "department" },
    location: { type: String },
    answerBy: { type: mongoose.Types.ObjectId, ref: "user" },
    answerDate: { type: Date, required: true },
    answers: [],
  },
  { timestamps: true }
);

const ShedeinResponseModel = mongoose.model(
  "shedein_fs_res",
  shedeinResponseSchema
);

export default ShedeinResponseModel;
