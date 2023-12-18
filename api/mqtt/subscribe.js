/**
 *
 * @param {import("aedes").Client} client
 * @param {import("aedes").Subscription} subscription
 * @param {Error | null} callback
 */
async function authorizeSubscribe(client, subscription, callback) {
  try {
    callback(null, subscription);
  } catch (error) {
    callback(error, null);
  }
}
export default authorizeSubscribe;
