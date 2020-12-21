import pgPromise from "pg-promise";
import { IClient } from "pg-promise/typescript/pg-subset";

export const pgp = pgPromise();

export default class DatabaseInstance {

  private static _pgpInstance: pgPromise.IDatabase<{}, IClient>;

  static get() {
    if (!this._pgpInstance) {
      this._pgpInstance = pgp({
        user: 'scannerfleetmaster',
        host: 'terraform-20201219215822509300000003.cc6tgdpnt5ov.us-east-1.rds.amazonaws.com',
        database: 'ScannerFleetDB',
        password: 'scannerfleet',
        port: 5432,
      });
    }

    return this._pgpInstance;
  }

}
