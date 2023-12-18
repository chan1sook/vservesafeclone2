/**
 * @param {import("aedes").Client} client
 * @param {string} username
 * @param {Buffer} password
 * @param {(error: import("aedes").AuthenticateError | null, success: boolean | null) => void} callback
 */
async function authenticate(client, username, password, callback) {
  callback(null, true);
}

export default authenticate;
