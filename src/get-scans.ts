import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from "aws-lambda";
import ScanResult from "./models/ScanResult";
import ScanTracker from "./pkg/ScanTracker";
import Response from "./pkg/utility/Response";
import GetScansRequest from "./requests/GetScansRequest";

export const handler = async (event: APIGatewayProxyEvent, context: Context): Promise<APIGatewayProxyResult> => {
  context.callbackWaitsForEmptyEventLoop = true;
  const request: GetScansRequest = JSON.parse(event.body);
  
  if (!GetScansRequest.validate(request).success) {
    return Response.InvalidRequest(new Error(`Invalid Request Body.`))
  }
  
  const tracker = new ScanTracker();

  try {
    const results = await tracker.fetchScanResults(request);
    return Response.Success(results);
  } catch (err) {
    return Response.InternalError(err)
  }
}
