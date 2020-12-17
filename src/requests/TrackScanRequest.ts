import ScanResult from "../models/ScanResult";

export default interface TrackScanRequest {
  scanning_device_id: string,
  visible_devices: [ScanResult],
}
