# Фінальний проєкт DevOps на AWS (Terraform + EKS + Jenkins + Argo CD + Monitoring)

Цей репозиторій містить фінальний проєкт дисципліни DevOps: розгортання інфраструктури в AWS через Terraform та демонстрація повного CI/CD циклу для Django-застосунку.

> За основу взято попередні домашні завдання і підхід до документації (структура, приклади, поради щодо destroy) на кшталт README з модулем RDS/Aurora.

---

## 1) Архітектура (що розгортаємо)

**AWS (Terraform):**
- VPC (public/private subnets, routing, NAT/IGW)
- EKS (кластер + node group)
- ECR (Docker registry)
- RDS або Aurora (опційно, через модуль)
- S3 + DynamoDB для Terraform backend (state)

**Kubernetes (EKS):**
- Jenkins (CI)
- Argo CD (CD / GitOps)
- Prometheus + Grafana (monitoring)
- Django application (Helm chart)

---

## 2) Репозиторій та структура

Робоча гілка: **`final-project`**  
Основний каталог фінального проєкту: **`Project/`**

```
devops-course/
└── Project/
    ├── main.tf
    ├── backend.tf
    ├── providers.tf
    ├── providers-k8s.tf
    ├── variables.tf
    ├── outputs.tf
    ├── modules/
    │   ├── vpc/
    │   ├── eks/
    │   ├── ecr/
    │   ├── rds/
    │   ├── jenkins/
    │   ├── argo_cd/
    │   └── monitoring/
    ├── charts/
    │   └── django-app/
    │       ├── Chart.yaml
    │       ├── values.yaml
    │       └── templates/
    ├── app/                 # Django app files (використовується Dockerfile)
    ├── Dockerfile           # збірка образу для Django
    └── Jenkinsfile          # CI: build+push to ECR + update Helm values
```

---

## 3) Передумови (локально)

Потрібно встановити:
- Terraform
- AWS CLI
- kubectl
- (опційно) helm

Також потрібні AWS credentials (локально для Terraform / kubectl доступу до кластера).

---

## 4) Порядок запуску інфраструктури

### 4.1) Terraform init
З кореня фінального проєкту:

```bash
cd Project
terraform init
```

Якщо backend (S3/DynamoDB) створюється окремо або вже існує — переконайтесь, що `backend.tf` налаштований правильно.

### 4.2) Terraform apply
```bash
terraform apply
```

Після створення EKS онови kubeconfig:

```bash
aws eks update-kubeconfig --region eu-central-1 --name <EKS_CLUSTER_NAME>
kubectl get nodes
```

> Якщо у вас використовується “2-фазний” apply (спочатку без k8s провайдерів/helm release, потім з ними) — дотримуйтесь саме цього підходу.

---

## 5) Перевірка компонентів у кластері

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get all -n django
```

---

## 6) Доступ до сервісів (port-forward)

### Jenkins
```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```
Відкрий: http://localhost:8080

### Argo CD
```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```
Відкрий: https://localhost:8081

### Grafana
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
Відкрий: http://localhost:3000

---

## 7) CI/CD флоу (Jenkins → ECR → Git → ArgoCD → EKS)

### 7.1) Як працює CI (Jenkins)
`Project/Jenkinsfile` робить:
1) Checkout репозиторію
2) ECR login
3) Build та push Docker image у ECR через Kaniko (tags: `build-<BUILD_NUMBER>-<SHA>` та `latest`)
4) Оновлює Helm values у цьому ж репозиторії:
   - файл: `Project/charts/django-app/values.yaml`
   - поле: `image.tag`
5) Commit + push змін у гілку `final-project`

### 7.2) Налаштування Argo CD Application
ArgoCD Application налаштовано на:
- Repo URL: `https://github.com/MaRo-Christmas/devops-course.git`
- Target revision: `final-project`
- Path: `Project/charts/django-app`
- Namespace: `django`

Після пуша Jenkins (оновлення `values.yaml`) ArgoCD синхронізує стан і оновлює деплой у кластері.

---

## 8) Перевірка Django застосунку

### 8.1) Перевір pod/servіс
```bash
kubectl get pods -n django
kubectl get svc -n django
```

### 8.2) Port-forward (якщо потрібно)
Замінити `<service-name>` на актуальний, наприклад `django-app-final-project`:

```bash
kubectl port-forward -n django svc/<service-name> 8000:80
```

Відкрий: http://localhost:8000  
Очікувана відповідь health endpoint: `{"status":"ok"}`

---

## 9) Важливо про витрати (AWS cost safety)

Після перевірки/демо ресурси **треба видаляти**, інакше AWS радісно виставляє рахунок.

```bash
terraform destroy
```

> Увага: якщо Terraform backend (S3 bucket + DynamoDB table) створювався через Terraform у цьому ж стеку, `destroy` може прибрати й backend. Тоді наступний `terraform init` не знайде state.  
> Рекомендація: або робити backend окремим модулем/стеком, або чітко контролювати порядок destroy.

---

## 10) Корисні команди

```bash
# Кластер
kubectl get nodes
kubectl get ns

# Jenkins/Argo/Monitoring
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring

# Django
kubectl get all -n django
kubectl describe pod -n django <pod>
kubectl logs -n django <pod>
```
