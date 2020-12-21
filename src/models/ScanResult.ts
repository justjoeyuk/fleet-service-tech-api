import { Record, String, Union, Literal, Number, Static, Partial } from "runtypes";
import { pgp } from "../pkg/DatabaseInstance";

const ScanResult = Record({
  visible_device_id: Number,
  time: String,
  interface: Union(Literal('WIFI'), Literal('BTLE')),
  signal_strength: Number
}).And(Partial({
  scanning_device_id: Number
}));

type ScanResult = Static<typeof ScanResult>;

export const ScanResultColumnSet = new pgp.helpers.ColumnSet(['scanning_device_id', 'visible_device_id', 'time', 'interface', 'signal_strength'], {table: 'scan_result'});

export default ScanResult;
