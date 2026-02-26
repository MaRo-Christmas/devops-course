# Terraform module: universal RDS / Aurora

Цей модуль створює або звичайний RDS instance (PostgreSQL/MySQL), або Aurora Cluster (з writer instance) в залежності від прапора `use_aurora`.

## Функціонал

- `use_aurora = false` → створюється `aws_db_instance`
- `use_aurora = true` → створюється `aws_rds_cluster` + `aws_rds_cluster_instance` (writer)
- В обох випадках створюються:
  - DB Subnet Group
  - Security Group
  - Parameter Group (для instance або для cluster)

## Приклад використання

```hcl
module "rds" {
  source = "./modules/rds"

  project     = "devops-course"
  environment = "dev"
  name        = "app-db"

  use_aurora = false # true -> Aurora, false -> RDS instance

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # Рекомендовано відкривати доступ через SG, а не CIDR
  allowed_security_group_ids = [module.eks.node_security_group_id]
  allowed_cidr_blocks        = []

  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.medium"
  multi_az       = false

  db_name   = "appdb"
  username  = "appuser"
  password  = var.db_password

  # Приклади:
  # postgres16 / mysql8.0 / aurora-postgresql16 / aurora-mysql8.0
  parameter_group_family = "postgres16"

  db_params = {
    max_connections = 300
    log_statement   = "none"
    work_mem        = 4096
  }

  tags = {
    Owner = "Maryna"
  }
}
```

## Змінні

### Обовʼязкові
- `project` (string) – назва проєкту (для імен ресурсів та тегів)
- `environment` (string) – середовище (dev/stage/prod)
- `vpc_id` (string) – VPC ID
- `subnet_ids` (list(string)) – subnet IDs для DB Subnet Group
- `username` (string) – master username
- `password` (string, sensitive) – master password
- `parameter_group_family` (string) – family для parameter group (приклади нижче)

### Ключова логіка
- `use_aurora` (bool, default: false) – перемикач режиму (Aurora або RDS instance)

### DB налаштування
- `engine` (string, default: postgres) – `postgres` або `mysql`
- `engine_version` (string) – версія engine
- `instance_class` (string, default: db.t3.medium) – клас інстансу
- `multi_az` (bool, default: false) – Multi-AZ (актуально для RDS instance)
- `db_name` (string, default: appdb) – назва БД
- `port` (number, default: null) – кастомний порт (якщо null, береться стандартний)

### Параметри (Parameter Group)
- `db_params` (object) – базові параметри:
  - `max_connections` (number, default: 200)
  - `log_statement` (string, default: none)
  - `work_mem` (number, default: 4096)

### Мережевий доступ
- `allowed_cidr_blocks` (list(string), default: []) – CIDR для доступу до БД
- `allowed_security_group_ids` (list(string), default: []) – SG для доступу до БД

### Storage та backup
- `allocated_storage` (number, default: 20) – лише для RDS instance
- `storage_type` (string, default: gp3) – лише для RDS instance
- `storage_encrypted` (bool, default: true)
- `kms_key_id` (string, default: null)
- `backup_retention_period` (number, default: 7)
- `backup_window` (string, default: 03:00-04:00)
- `maintenance_window` (string, default: sun:05:00-sun:06:00)

### Destroy поведінка
- `deletion_protection` (bool, default: false)
- `skip_final_snapshot` (bool, default: true)

### Інше
- `publicly_accessible` (bool, default: false)
- `apply_immediately` (bool, default: true)
- `tags` (map(string), default: {})

## Як змінити тип БД

### Звичайний PostgreSQL (RDS)
- `use_aurora = false`
- `engine = "postgres"`
- `parameter_group_family = "postgres16"` (або інша відповідна family)

### Aurora PostgreSQL
- `use_aurora = true`
- `engine = "postgres"`
- `parameter_group_family = "aurora-postgresql16"` (або інша відповідна family)

### Звичайний MySQL (RDS)
- `use_aurora = false`
- `engine = "mysql"`
- `parameter_group_family = "mysql8.0"`

### Aurora MySQL
- `use_aurora = true`
- `engine = "mysql"`
- `parameter_group_family = "aurora-mysql8.0"`

## Outputs

- `subnet_group_name` – назва DB Subnet Group
- `security_group_id` – ID DB Security Group
- `db_port` – порт БД
- `rds_instance_endpoint` / `rds_instance_address` – якщо `use_aurora = false`
- `aurora_cluster_endpoint` / `aurora_reader_endpoint` – якщо `use_aurora = true`

## Важливо про витрати

Після перевірки коду видаляйте ресурси командою `terraform destroy`.
Якщо S3 bucket + DynamoDB table для Terraform backend створюються через Terraform, видалення всієї інфраструктури може прибрати й backend ресурси, через що наступний `terraform init` не знайде state.