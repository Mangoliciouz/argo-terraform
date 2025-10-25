provider "kubernetes" {
  host                   = local.kubernetes.hostname
  token                  = local.kubernetes.access_token
  cluster_ca_certificate = local.kubernetes.ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.kubernetes.hostname
    token                  = local.kubernetes.access_token
    cluster_ca_certificate = local.kubernetes.ca_certificate
  }
}

#######################
## Using Parameters
#######################
resource "kubernetes_manifest" "best_rag_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argo-application"
      namespace = argocd-namespace
      labels = {
        "application/label-1" = "label-1"
      }
    }
    spec = {
      project = argo-project
      sources = [
        {
          repoURL        = "https://github.com/Mangoliciouz/values-repo.git"
          targetRevision = main
          ref            = "values"
        },
        {
          chart          = ""
          repoURL        = "https://github.com/Mangoliciouz/chart-repo.git"
          path           = "path/to/chart"
          targetRevision = main
          helm = {
            ignoreMissingValueFiles = true
            valueFiles = [
              "$values/helm/values/values.yaml", 
            ]
            parameters = [
              {
                name  = "global.appName"
                value = "Application Name"
              },
              {
                name  = "global.environment"
                value = local.env
              },
              {
                name  = "deployment.image.shortSha"
                value = "$ARGOCD_APP_REVISION_SHORT"
              },
              {
                name  = "database.connectionString"
                value = local.database.connectionString
              },
            ]
          }
        }
      ]
      destination = {
        name      = "deployment-cluster-name"
        namespace = application-namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
  field_manager {
    name            = "terraform-manager"
    force_conflicts = true
  }
}

#######################
## Using Values
#######################
resource "kubernetes_manifest" "best_rag_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argo-application"
      namespace = argocd-namespace
      labels = {
        "application/label-1" = "label-1"
      }
    }
    spec = {
      project = argo-project
      sources = [
        {
          repoURL        = "https://github.com/Mangoliciouz/values-repo.git"
          targetRevision = main
          ref            = "values"
        },
        {
          chart          = ""
          repoURL        = "https://github.com/Mangoliciouz/chart-repo.git"
          path           = "path/to/chart"
          targetRevision = main
          helm = {
            ignoreMissingValueFiles = true
            valueFiles = [
              "$values/helm/values/values.yaml", 
            ]
            values = <<-EOF
                global:
                  appName: Application Name
                  environment: ${local.env}
                deployment:
                  image:
                    shortSha: "{{.head_short_sha_7}}"
                database:
                  connectionString: ${local.database.connectionString}
              EOF
            }
          }
        }
      ]
      destination = {
        name      = "deployment-cluster-name"
        namespace = application-namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
  field_manager {
    name            = "terraform-manager"
    force_conflicts = true
  }
}
