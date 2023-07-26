locals {
  flux_target_path    = "${var.target_path}/${var.flux_sync_directory}"
  # cluster_admin_users = concat(var.cluster_admin_users, split(",", var.cluster_admin_users_string))
}
