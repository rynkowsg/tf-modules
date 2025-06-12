# chargedup-tf-modules

## Run example

```bash
cd examples/backend-s3
aws-vault-ryn exec ryn-test/management/greg -- terraform plan
aws-vault-ryn exec ryn-test/management/greg -- terraform apply
aws-vault-ryn exec ryn-test/management/greg -- terraform destroy
```
