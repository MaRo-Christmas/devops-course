provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "arn:aws:eks:eu-central-1:209578578085:cluster/lesson-7-eks"
}

provider "helm" {
  kubernetes = {
    config_path    = pathexpand("~/.kube/config")
    config_context = "arn:aws:eks:eu-central-1:209578578085:cluster/lesson-7-eks"
  }
}