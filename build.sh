rm -Rf build
mkdir build

npm run build

export TF_VAR_pg_username=#CONTACT_ADMIN
export TF_VAR_pg_password=#CONTACT_ADMIN

cd infrastructure
terraform apply -auto-approve
cd ../
