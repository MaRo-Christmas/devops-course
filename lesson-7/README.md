# Lesson 7 - EKS + ECR + Helm (Django)

This folder creates:
- ECR repo for your Django image
- EKS cluster in the **existing VPC** created in lesson-5 (reused via terraform_remote_state)
- Helm chart to deploy Django with ConfigMap + Service (LoadBalancer) + HPA

## 1) Terraform: create ECR + EKS
```bash
cd lesson-7
terraform init
terraform plan
terraform apply
```

## 2) Configure kubectl for EKS
```bash
aws eks update-kubeconfig --region eu-central-1 --name $(terraform output -raw eks_cluster_name)
kubectl get nodes
```

## 3) Build & push Django image to ECR
Get repo url:
```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
echo $ECR_URL
```

Login:
```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${ECR_URL%/*}
```

Build, tag, push:
```bash
docker build -t django-app:v1 .
docker tag django-app:v1 $ECR_URL:v1
docker push $ECR_URL:v1
```

## 4) Deploy with Helm
Edit `charts/django-app/values.yaml` and set:
- image.repository = your ECR url (without tag)
- image.tag = v1
- config.* = env vars from HW-4

Install:
```bash
helm lint charts/django-app
helm install myapp charts/django-app
```

Check:
```bash
kubectl get deploy,po,svc,hpa
kubectl get svc
```

## Notes
- HPA needs metrics-server. If HPA shows missing metrics, install it:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Bonus: Ingress + TLS
Enable in values.yaml:
```yaml
ingress:
  enabled: true
  className: nginx
  host: yourdomain.com
  tls: true
  clusterIssuer: letsencrypt-prod
```
You also need ingress controller + cert-manager installed in the cluster.
