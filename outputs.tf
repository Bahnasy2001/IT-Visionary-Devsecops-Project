output "ecr_repository_urls" {
  description = "URLs of created ECR repositories"
  value = { for key, repo in module.ecr : key => repo.repository_url }
}
