import ScanResult, { ScanResultColumnSet } from "../models/ScanResult";
import ScanningDevice from "../models/ScanningDevice";

import TrackScanRequest from "../requests/TrackScanRequest";
import DatabaseInstance, { pgp } from "./DatabaseInstance";
import GetScansRequest from "../requests/GetScansRequest";

export default class ScanTracker {

  async saveScanResults(trackScanRequest: TrackScanRequest) {
    const db = DatabaseInstance.get();

    const scanDevice = ScanningDevice.check({id: trackScanRequest.scanning_device_id});

    // Assign the scanning device to the scan result
    for (let i = 0; i < trackScanRequest.visible_devices.length; i++) {
      trackScanRequest.visible_devices[i].scanning_device_id = scanDevice.id
    }

    // We could handle errors here, but i've taken a "fire and forget" approach for the "tracking"

    const qInsertScanDevice = `INSERT INTO scan_device (id) VALUES (${scanDevice.id}) ON CONFLICT (id) DO UPDATE SET id = excluded.id`;
    await db.none(qInsertScanDevice);

    const qInsertScanResults = pgp.helpers.insert(trackScanRequest.visible_devices, ScanResultColumnSet);
    await db.none(qInsertScanResults);
  }

  async fetchScanResults(getScansRequest: GetScansRequest) : Promise<{ scans: [ScanResult], avg: Number }> {
    const db = DatabaseInstance.get();

    const from = pgp.as.date(new Date(getScansRequest.from))
    const to = pgp.as.date(new Date(getScansRequest.to))

    let scanResults = await db.query(`SELECT * FROM scan_result WHERE ((scanning_device_id = $1) OR (visible_device_id = $1)) AND (time BETWEEN $2 AND $3)`, [getScansRequest.device_id, from, to])
    let averageSignalResult = await db.one(`SELECT AVG(signal_strength)::NUMERIC(10,2) FROM scan_result WHERE ((scanning_device_id = $1) OR (visible_device_id = $1)) AND (time BETWEEN $2 AND $3)`, [getScansRequest.device_id, from, to])
  
    return {
      scans: scanResults,
      avg: averageSignalResult.avg
    }
  }

}
