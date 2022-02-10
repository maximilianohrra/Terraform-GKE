# habilitar el host project y el service project y adjuntar el service project para nuestra vpc 

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_host_project
resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.host-staging.number
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_service_project
resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = local.host_project_id
  service_project = local.service_project_id

  depends_on = [google_compute_shared_vpc_host_project.host] # quien se attacha al otro
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam
resource "google_compute_subnetwork_iam_binding" "binding" {
  project    = google_compute_shared_vpc_host_project.host.project
  region     = google_compute_subnetwork.private.region
  subnetwork = google_compute_subnetwork.private.name
#accesos IAM
  role = "roles/compute.networkUser"
  members = [
    "serviceAccount:${google_service_account.k8s-staging.email}",
    "serviceAccount:${google_project.k8s-staging.number}@cloudservices.gserviceaccount.com",
    "serviceAccount:service-${google_project.k8s-staging.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}
# si no se crean los bindings para las cuentas no será posible usar la subred - host service agent user 

#role = "roles/compute.networkUser"
###role    = "roles/container.hostServiceAgentUser"
# Usuario de agente de servicios de host de Kubernetes Engine	
#Permite que la cuenta de servicio de Kubernetes Engine en el proyecto host 
#configure los recursos de red compartida de la administración de los clústeres. 
#También brinda acceso para inspeccionar las reglas de firewall del proyecto host.


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_binding" "container-engine" {
  project = google_compute_shared_vpc_host_project.host.project
  role    = "roles/container.hostServiceAgentUser"

  members = [
    "serviceAccount:service-${google_project.k8s-staging.number}@container-engine-robot.iam.gserviceaccount.com",
  ]
  depends_on = [google_project_service.service]
}