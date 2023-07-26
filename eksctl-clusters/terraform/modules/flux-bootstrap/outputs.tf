output "group" {
  description = "owner of repository flux is bootstrapped"
  value       = var.github_owner
}

output "repository_name" {
  description = "name of repository flux is bootstrapped"
  value       = local.github_repository.name
}

output "branch" {
  description = "repository branch flux is monitoring"
  value       = var.branch
}

output "target_path" {
  description = "path within repository flux is monitoring"
  value       = var.target_path
}
