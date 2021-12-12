resource "google_container_cluster" "first-cluster" {
  name               = "first-cluster"
  location           = "us-west1-b"
  initial_node_count = 3
}
output "cluster_name" {
  value = google_container_cluster.first-cluster.name
}
output "cluster_location" {
  value = google_container_cluster.first-cluster.location
}