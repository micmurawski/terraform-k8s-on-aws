### Examples


To deploy only EKS module

```
make deploy TERRAFORM_DIR=deployment/shared_infra/eks BACKEND_CONFIG=../../../config/cognito.conf VAR_FILE=../../../vars/test.tfvars.json
```

```
make deploy TERRAFORM_DIR=deployment/shared_infra/cognito BACKEND_CONFIG=../../../config/test.conf VAR_FILE=../../../vars/cognito.tfvars.json
```

```
make deploy BACKEND_CONFIG=../../../config/test.conf
```

