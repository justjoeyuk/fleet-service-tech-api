rm -Rf build
mkdir build

export TF_VAR_pg_username=#CONTACT_ADMIN
export TF_VAR_pg_password=#CONTACT_ADMIN

cd src
npm run build
cd ../
