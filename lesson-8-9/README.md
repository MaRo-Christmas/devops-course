# ДЗ-8-9 — Jenkins + Helm + Terraform + Argo CD (повний CI/CD для Django)

Цей проєкт реалізує повний CI/CD-процес у Kubernetes (EKS) з використанням Terraform, Jenkins, Helm і Argo CD:

1. Jenkins автоматично збирає Docker-образ для Django-застосунку.
2. Jenkins пушить образ в Amazon ECR.
3. Jenkins оновлює Helm values у окремому Git-репозиторії (з новим тегом образу) і пушить зміни в `main`.
4. Argo CD відстежує Helm-репозиторій і автоматично синхронізує зміни у кластері.

Гілка для здачі: `lesson-8-9`.

---

## Репозиторії

1. App repo (цей репозиторій)
- Містить Django-застосунок, Dockerfile, Terraform та Jenkinsfile.
- Jenkinsfile: `lesson-8-9/Jenkinsfile`

2. Helm repo (окремий репозиторій)
- Містить Helm chart і values, які оновлює Jenkins.
- Repo: `lesson-8-9-helm`
- Шлях чарта в helm repo: `charts/` (там знаходяться `Chart.yaml`, `values.yaml`, `templates/`)

---

## Структура проєкту (коротко)

- `backend.tf` — S3 + DynamoDB backend для Terraform state
- `main.tf` / `outputs.tf` — підключення модулів
- `modules/`:
  - `s3-backend/` — S3 bucket + DynamoDB lock
  - `vpc/` — мережа
  - `ecr/` — ECR repo для `django-app`
  - `eks/` — EKS + node group + (за потреби) addons
  - `jenkins/` — встановлення Jenkins через Helm (керується Terraform)
  - `argo_cd/` — встановлення Argo CD через Helm (керується Terraform)
- `charts/django-app/` — Helm chart (у цьому репо) для локальної перевірки/референсу
- `lesson-8-9/Jenkinsfile` — pipeline для CI/CD

---

## Як застосувати Terraform

### 1) Ініціалізація
Переконайся, що налаштовані AWS креденшали (AWS CLI), і є доступ до AWS акаунту.

```bash
terraform init -reconfigure
terraform plan
terraform apply
```

### 2) Підключити kubeconfig до EKS
Назву кластера і регіон підставити зі своїх outputs/налаштувань.

```bash
aws eks update-kubeconfig --region eu-central-1 --name <EKS_CLUSTER_NAME>
kubectl get nodes
```

---

## Jenkins: що налаштовано

### Jenkins встановлений у кластері через Helm (Terraform)
Jenkins працює з Kubernetes Agent (pod), який містить контейнери:
- `awscli` — логін в ECR, формування docker config для Kaniko
- `kaniko` — збірка і пуш образу в ECR
- `tools` — git clone/commit/push у helm repo
- `jnlp` — службовий контейнер агента

### Важливий момент про тег образу
Тег формується в Jenkins як `build-${BUILD_NUMBER}-${SHORT_SHA}`.

Щоб уникнути проблем із `env` у Jenkins Declarative pipeline, тег передається між стадіями через файл `.image_tag` у workspace (один і той самий тег використовується для ECR push і для оновлення Helm values).

---

## Як перевірити Jenkins job

1) Jenkins Job має бути налаштований як `Pipeline script from SCM`:
- Repo: цей repo
- Branch: `lesson-8-9`
- Script path: `lesson-8-9/Jenkinsfile`

2) Запусти збірку вручну (Build Now) або тригером, якщо налаштовано.

3) Артефакт для підтвердження:
- лог збірки з коректним тегом, пушем у ECR і комітом у helm repo

Для здачі додається файл:
- `lesson-8-9/Console_Output_19.txt`

---

## Що саме робить pipeline (Jenkinsfile)

Стадії:

1. Checkout app repo
- `checkout scm`
- Обчислюється SHORT_SHA: `git rev-parse --short=8 HEAD`
- Формується IMAGE_TAG: `build-${BUILD_NUMBER}-${SHORT_SHA}`
- Запис в `.image_tag`

2. Login to ECR
- `aws ecr get-login-password`
- Формується `/kaniko/.docker/config.json`

3. Build & Push (Kaniko)
- Збірка з Dockerfile
- Пуш в ECR з тегом із `.image_tag`

4. Update Helm repo values.yaml
- Clone `lesson-8-9-helm`
- Оновлення `charts/values.yaml` (поле `image.tag`)
- `git commit` + `git push origin main`

---

## Argo CD: що має бути налаштовано

### 1) Argo CD встановлений у кластері через Helm (Terraform)

### 2) Підключення helm repo як Repository (read-only)
У Argo CD доданий репозиторій `lesson-8-9-helm` з правами тільки на читання.

### 3) Створення Argo CD Application
Створюється Application, який дивиться на:
- Repo URL: `lesson-8-9-helm`
- Revision: `main`
- Path: `charts`
- Destination namespace: `django-app`
- Sync policy: Auto (рекомендовано) + Prune + Self Heal
- Опція: Create Namespace (або namespace створюється вручну)

---

## Як побачити результат в Argo CD

1) В Argo CD у розділі Applications має бути застосунок `django-app`.

2) Статуси:
- Sync status: `Synced`
- Health: `Healthy`

3) У дереві ресурсів мають бути:
- ConfigMap
- Service
- Deployment
- ReplicaSet
- Pod (Running)

---

## Перевірка в Kubernetes (kubectl)

### 1) Namespace існує
PowerShell:
```powershell
kubectl get ns | findstr django-app
```

### 2) Ресурси застосунку
```powershell
kubectl get all -n django-app
kubectl get cm -n django-app
kubectl get svc -n django-app
```

### 3) Перевірка тегу образу, який реально запущений
```powershell
kubectl describe deploy django-app -n django-app
```

Додатково (точний вивід image):
```powershell
kubectl get deploy django-app -n django-app -o jsonpath="{..image}{'\n'}"
```

---

## Очікувані артефакти після успішного прогону

1) В ECR з’являється новий tag виду:
- `build-<BUILD_NUMBER>-<SHORT_SHA>`

2) У helm repo (`lesson-8-9-helm`) у `charts/values.yaml` оновлюється:
- `image.tag: "build-<BUILD_NUMBER>-<SHORT_SHA>"`

3) Argo CD підхоплює commit з `main` helm repo і виконує sync.

---

## Безпека та ключі

Різні ключі для Jenkins і Argo CD є нормою:

- Argo CD: read-only доступ до репозиторію (тільки clone/pull)
- Jenkins: read/write доступ до helm repo (commit/push у `main`)

---

## Вимкнення ресурсів після перевірки (щоб уникнути витрат)

Після перевірки проєкту:

```bash
terraform destroy
```

Увага: якщо ви видаляєте всю інфраструктуру, також буде видалений S3 bucket і DynamoDB таблиця для Terraform state (залежить від реалізації). Пам’ятайте порядок підняття інфраструктури після повного видалення.

---

## Файли для здачі

1) Посилання на GitHub-репозиторій, гілка `lesson-8-9`.
2) Архів `lesson-8-9_<ПІБ>.zip` (згідно вимог LMS).
3) Цей `README.md`.
4) Лог збірки: `lesson-8-9/Console_Output_19.txt`.
