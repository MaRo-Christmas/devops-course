# Lesson 7 — EKS + ECR + Helm (Django)

У цьому проекті розгортається Kubernetes-кластер в AWS (EKS) у **вже існуючій VPC** з lesson-5, створюється ECR-репозиторій для Docker-образу та деплоїться Django застосунок через Helm.

## Що створюється

- **ECR репозиторій** для Docker-образу Django
- **EKS кластер** у VPC з lesson-5 (підтягуємо мережу через `terraform_remote_state`)
- **Node Group** (керований) для воркер-нод
- **Helm chart** для деплою Django:
  - ConfigMap з env змінними
  - Service типу LoadBalancer
  - HPA (HorizontalPodAutoscaler) для масштабування за CPU
- (Опційно) **metrics-server** для роботи HPA

---

## 1) Terraform: створити ECR + EKS

```bash
cd lesson-7
terraform init -reconfigure
terraform plan
terraform apply
```

Перевір, що ноди піднялись:
```bash
aws eks update-kubeconfig --region eu-central-1 --name lesson-7-eks
kubectl get nodes
```

---

## 2) Docker: збірка та пуш образу в ECR

Логін в ECR:
```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 209578578085.dkr.ecr.eu-central-1.amazonaws.com
```

Збірка (приклад з тегом `v1`):
```bash
docker build -t django-app:v1 .
```

Тег + пуш у ECR:
```bash
docker tag django-app:v1 209578578085.dkr.ecr.eu-central-1.amazonaws.com/django-app:v1
docker push 209578578085.dkr.ecr.eu-central-1.amazonaws.com/django-app:v1
```

Перевір, що тег зʼявився:
```bash
aws ecr describe-images --region eu-central-1 --repository-name django-app --query "imageDetails[].imageTags" --output json
```

---

## 3) Helm: деплой Django в кластер

Чарт знаходиться тут:
- `charts/django-app`

### Варіант A (рекомендований): передати образ через `--set`

```bash
helm lint .\charts\django-app
helm upgrade --install django-app .\charts\django-app --namespace django --create-namespace ^
  --set image.repository="209578578085.dkr.ecr.eu-central-1.amazonaws.com/django-app" ^
  --set image.tag="v1"
```

Перевір:
```bash
kubectl get pods -n django
kubectl get svc -n django
kubectl describe svc -n django django-app
```

### Варіант B: прописати образ у `values.yaml`

У `charts/django-app/values.yaml`:
- `image.repository`
- `image.tag`

Після цього:
```bash
helm upgrade --install django-app .\charts\django-app --namespace django --create-namespace
```

---

## 4) HPA та metrics-server

HPA потребує metrics API. Якщо `kubectl describe hpa` показує помилки типу `pods.metrics.k8s.io not found`, встанови metrics-server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Перевір:
```bash
kubectl get pods -n kube-system | findstr /I metrics
kubectl top nodes
kubectl top pods -n django
kubectl get hpa -n django
kubectl describe hpa -n django django-app
```

---

## Перевірка результату

1) Под(и) працюють:
```bash
kubectl get pods -n django -o wide
```

2) Service має External endpoint (LoadBalancer):
```bash
kubectl get svc -n django
```

3) HPA активний і бачить метрики:
```bash
kubectl get hpa -n django
kubectl describe hpa -n django django-app
```

---

## Нотатки

- VPC та підмережі беруться з lesson-5. Для EKS воркери повинні бути у приватних підмережах з виходом через NAT, інакше ноди можуть “не приєднатися до кластера”.
- Якщо `helm upgrade` падає через конфлікти/невідповідність labels або `containers: Required value`, перевір `templates/deployment.yaml` (labels + selector мають збігатися, і контейнер не може бути порожнім).
