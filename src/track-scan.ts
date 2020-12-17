import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import TrackScanRequest from "./requests/TrackScanRequest";

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  const results = <TrackScanRequest>JSON.parse(event.body)
  console.log("Got Results: ", results);
  
  return {
    statusCode: 200,
    body: JSON.stringify(results)
  }
}
