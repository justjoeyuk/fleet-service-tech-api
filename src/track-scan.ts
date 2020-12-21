import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from "aws-lambda";
import ScanTracker from "./pkg/ScanTracker";
import Response from "./pkg/utility/Response";
import TrackScanRequest from "./requests/TrackScanRequest";

export const handler = async (event: APIGatewayProxyEvent, context: Context): Promise<APIGatewayProxyResult> => {
  context.callbackWaitsForEmptyEventLoop = true;
  const request: TrackScanRequest = JSON.parse(event.body);
  
  if (!TrackScanRequest.validate(request).success) {
    return Response.InvalidRequest(new Error(`Invalid Request Body.`))
  }
  
  const tracker = new ScanTracker();
  
  try {
    await tracker.saveScanResults(request);
  } catch (err) {
    return Response.InternalError(err)
  }
  
  return Response.Success();
}
