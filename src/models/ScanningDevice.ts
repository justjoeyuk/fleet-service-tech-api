import { Record, Number, Static } from "runtypes";
const ScanningDevice = Record({
  id: Number,
});

type ScanningDevice = Static<typeof ScanningDevice>;

export default ScanningDevice;
