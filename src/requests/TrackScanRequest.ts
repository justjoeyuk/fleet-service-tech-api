import ScanResult from "../models/ScanResult";
import { Number, Record, Array, Static } from 'runtypes'

const TrackScanRequest = Record({
  scanning_device_id: Number,
  visible_devices: Array(ScanResult),
});

type TrackScanRequest = Static<typeof TrackScanRequest>;

export default TrackScanRequest;
