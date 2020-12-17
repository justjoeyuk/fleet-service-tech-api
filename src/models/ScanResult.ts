export default class ScanResult {
  scanning_device_id: string;
  visible_device_id: string;
  time: string; // ISO String
  interface: 'WIFI' | 'BTLE';
  signal_strength: number; // 0-100
}
