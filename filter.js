/**
// JSON Template
{
  "scanning_device_id" : "string_value",
  "visible_devices": [{
    "visible_device_id" : "string_value",
    "time" : "iso_timestamp_string_value",
    "interface" : "WIFI",
    "signal_strength" : 100
  }]
}
*/

const pgp = require("pg-promise")();

const db = pgp({
  user: 'scannerfleetmaster',
  host: 'terraform-20201219215822509300000003.cc6tgdpnt5ov.us-east-1.rds.amazonaws.com',
  database: 'ScannerFleetDB',
  password: 'scannerfleet',
  port: 5432,
});

let fromDate = new Date("2020-12-20 03:00:00.000+00")
fromDate.setHours(0,0,0,0);

let toDate = new Date("2020-12-20 03:00:00.000+00");
toDate.setHours(23,59,59,999);

const select = async () => {
  let r1 = await db.query(`SELECT * FROM scan_result WHERE ((scanning_device_id = 1608503246986) OR (visible_device_id = 1608503246986)) AND (time BETWEEN $1 AND $2)`, [pgp.as.date(fromDate), pgp.as.date(toDate)])
  let r3 = await db.query(`SELECT AVG(signal_strength)::NUMERIC(10,2) FROM scan_result WHERE ((scanning_device_id = 1608503246986) OR (visible_device_id = 1608503246986)) AND (time BETWEEN $1 AND $2)`, [pgp.as.date(fromDate), pgp.as.date(toDate)])

  // let res = await db.many(`SELECT * FROM scan_result WHERE ((scanning_device_id = 1608504907676) OR (visible_device_id = 1608504907676)) AND (time BETWEEN $1 AND $2)`, [pgp.as.date(fromDate), pgp.as.date(toDate)]);
  console.log(r1)
  console.log(r3)
}

select()
