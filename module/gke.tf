resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  initial_node_count = 1

  # Node pool configuration
  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Networking configuration
  network    = var.network
  subnetwork = var.subnetwork

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.endpoint_private_access
    enable_private_endpoint = var.endpoint_private_access
  }

  # Master authentication
  master_auth {
    username = "admin"
    password = var.master_password
  }

  # Tags for the cluster
  tags = {
    Name = var.cluster_name
    Env  = var.env
  }
}

resource "google_container_node_pool" "ondemand_node_pool" {
  name       = "${var.cluster_name}-on-demand-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke.name

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 100
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  initial_node_count = var.desired_capacity_on_demand

  autoscaling {
    min_node_count = var.min_capacity_on_demand
    max_node_count = var.max_capacity_on_demand
  }

  labels = {
    type = "ondemand"
  }

  tags = {
    Name = "${var.cluster_name}-ondemand-nodes"
  }

  depends_on = [google_container_cluster.gke]
}

resource "google_container_node_pool" "spot_node_pool" {
  name       = "${var.cluster_name}-spot-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke.name

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 100
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  initial_node_count = var.desired_capacity_spot

  autoscaling {
    min_node_count = var.min_capacity_spot
    max_node_count = var.max_capacity_spot
  }

  labels = {
    type = "spot"
    lifecycle = "spot"
  }

  tags = {
    Name = "${var.cluster_name}-spot-nodes"
  }

  depends_on = [google_container_cluster.gke]
}
