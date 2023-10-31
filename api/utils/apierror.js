class APIError extends Error {
  constructor(message = "", code = 400, errorId = undefined) {
    super(message);
    this.code = code;
    this.errorId = errorId;
  }
}

export default APIError;

export const APILoginAuthFailedError = new APIError(
  "Invalid Username/Password",
  403,
  1
);

export const APIMissingFormParameterError = new APIError(
  "Missing form parameter(s)",
  400,
  2
);

export const APIAuthRequiredError = new APIError("Auth Required", 401, 3);

export const APIServerNoSessionError = new APIError(
  "Server Session Problem",
  500,
  4
);

export const APIAuthFailedError = new APIError("Auth Failed", 400, 5);

export const APIMalformedParameterError = new APIError(
  "Malformed Prameter(s)",
  400,
  6
);

export const APINotImplemented = new APIError("Not Implemented Yet", 501, 7);

export const APISiteTargetNotExistsError = new APIError(
  "Site target not found",
  400,
  8
);

export const APILackPermissionError = new APIError("Forbidden", 403, 9);
export const APIUserTargetNotExistsError = new APIError(
  "User target not found",
  400,
  10
);
export const APISelfUserProtection = new APIError(
  "Self User Protection",
  403,
  11
);

export const APIErrorCodes = Object.freeze({
  1: APILoginAuthFailedError,
  2: APIMissingFormParameterError,
  3: APIAuthRequiredError,
  4: APIServerNoSessionError,
  5: APIAuthFailedError,
  6: APIMalformedParameterError,
  7: APINotImplemented,
  8: APISiteTargetNotExistsError,
  9: APILackPermissionError,
  10: APIUserTargetNotExistsError,
  11: APISelfUserProtection,
});
