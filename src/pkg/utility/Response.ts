export default class Response {

  static Success(body?: any) {
    return { statusCode: 200, body: JSON.stringify(body || {}) }
  }

  // Return a 400 Error with the given body
  static InvalidRequest(err?: Error) {
    return { statusCode: 400, body: JSON.stringify(err ? err.message : {}) }
  }

  // Return a 500 Error with the given body
  static InternalError(err?: Error) {
    return { statusCode: 500, body: JSON.stringify(err ? err.message : {}) }
  }

}
