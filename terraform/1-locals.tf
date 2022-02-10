locals {
  region               = "us-west2"
  org_id               = "827891362380" #experta.com.ar
  billing_account      = "017A8B-04FE06-F0A9D9" #experta.com.ar - billiing
  host_project_name    = "host-staging"
  service_project_name = "k8s-staging"
  host_project_id      = "${local.host_project_name}-${random_integer.int.result}"
  service_project_id   = "${local.service_project_name}-${random_integer.int.result}"
  projects_api         = "container.googleapis.com"
  secondary_ip_ranges = {
    "pod-ip-range"      = "10.0.0.0/14",
    "services-ip-range" = "10.4.0.0/19"
  }
}
