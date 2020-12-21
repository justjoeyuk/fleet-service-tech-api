import ScanResult from "../models/ScanResult";
import { Number, Record, Static, String, Partial } from 'runtypes'

const GetScansRequest = Record({
  device_id: Number,
  from: String,
  to: String,
});

type GetScansRequest = Static<typeof GetScansRequest>;

export default GetScansRequest;
