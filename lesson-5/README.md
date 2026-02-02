# Lesson 5 — Terraform on AWS (S3 backend + DynamoDB lock + VPC + ECR)

Цей проєкт демонструє базовий **production-like** підхід до Terraform на AWS:
- централізований **remote state** в **S3**
- **state locking** через **DynamoDB**
- інфраструктура: **VPC (public/private subnets)** + **ECR**

---

## Вимоги (Prerequisites)

- Встановлений **Terraform**
  ```bash
  terraform -version
  ```
- Встановлений та налаштований **AWS CLI**
  ```bash
  aws --version
  aws sts get-caller-identity
  ```
- Регіон: `eu-central-1`

---

## Структура проєкту

```text
lesson-5/
  backend.tf
  main.tf
  variables.tf
  outputs.tf
  modules/
    s3-backend/
    vpc/
    ecr/
```

---

## Що створюється

### S3 backend (state)
- S3 bucket для зберігання `terraform.tfstate`
- Versioning + Encryption + Public Access Block

### DynamoDB (locking)
- DynamoDB table для блокування state під час паралельних змін

### VPC
- VPC
- 2 public subnets + 2 private subnets (по AZ)
- Internet Gateway
- Route tables + associations

### ECR
- ECR repository для Docker-образів

---

## Як запускати

Форматування:
```bash
terraform fmt -recursive
```

Ініціалізація + перевірка:
```bash
terraform init
terraform validate
terraform plan
```

Застосування:
```bash
terraform apply
```

Щоб видалити інфраструктуру:
```bash
terraform destroy
```

---

## Backend (міграція state у S3)

Оскільки S3 bucket і DynamoDB table створюються Terraform-ом, застосовується **bootstrap підхід**:

1) Спочатку backend S3 тимчасово вимикається (локальний state).
2) Після створення S3 bucket + DynamoDB table — вмикаємо `backend "s3"` у `backend.tf`.
3) Мігруємо state:
```bash
terraform init -migrate-state -reconfigure
```

Після цього state зберігається в S3, а блокування відбувається в DynamoDB.

---

## Backend конфігурація (backend.tf)

```hcl
terraform {
  backend "s3" {
    bucket         = "maro-lesson-5-tfstate-12345"
    key            = "lesson-5/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "maro-lesson-5-tf-locks"
    encrypt        = true
  }
}
```

---

## Outputs

Після `terraform apply` очікувані outputs:
- `tf_state_bucket_name`
- `tf_lock_table_name`
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `ecr_repository_url`

---

## Git: що комітити

Комітити:
- усі `*.tf`
- папку `modules/**`
- `README.md`
- `.terraform.lock.hcl` (рекомендовано Terraform-ом)

Не комітити (додати в .gitignore):
- `.terraform/`
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `*.tfvars` (особливо якщо містять чутливі дані)