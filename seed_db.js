const pgp = require("pg-promise")();
const db = pgp({
  user: 'scannerfleetmaster',
  host: 'terraform-20201219215822509300000003.cc6tgdpnt5ov.us-east-1.rds.amazonaws.com',
  database: 'ScannerFleetDB',
  password: '#CONTACTME',
  port: 5432,
});

const sdcs = new pgp.helpers.ColumnSet(['id'], {table: 'scan_device'});
const srcs = new pgp.helpers.ColumnSet(['scanning_device_id', 'visible_device_id', 'time', 'interface', 'signal_strength'], {table: 'scan_result'});

const seedDatabase = async (numDevices, numScans) => {
  const now = new Date();
  let scanDevices = [];
  let scanResults = [];
  let outputJSONRequests = [];

  for (let device = 0; device < numDevices; device++) {
    const scanDevice = {
      id: now.getTime() + device
    }
    
    for (let scan = 0; scan < numScans; scan++) {
      const scanResult = {
        // scanning_device_id: scanDevice.id,
        time: now.toISOString(),
        visible_device_id: Math.floor(100000) + now.getTime() + scan,
        interface: Math.random() > 0.5 ? "WIFI" : "BTLE",
        signal_strength: (Math.random() * 99) + 1,
      }

      scanResults.push(scanResult)
    }

    const outputJSON = {"scanning_device_id": scanDevice.id, "visible_devices": scanResults};

    outputJSONRequests.push(outputJSON);
    scanDevices.push(scanDevice);
  }

  const scanDevicesQuery = pgp.helpers.insert(scanDevices, sdcs);
  const scanResultsQuery = pgp.helpers.insert(scanResults, srcs);

  try {
    let res = await db.none(scanDevicesQuery);
    console.log("Inserted Devices: ", res);
  } catch (e) {
    console.error("Could not insert devices: ", e)
  }

  try {
    let res = await db.none(scanResultsQuery);
    console.log("Inserted Results: ", res);
  }
  catch (e) {
    console.error("Could not insert results: ", e)
  }

  // console.log("Output JSON...");
  // console.log(JSON.stringify(outputJSONRequests));
}

// 2 devices, 1 scan each
seedDatabase(2, 1);

//8 devices, 4 scans each
seedDatabase(2, 4);
