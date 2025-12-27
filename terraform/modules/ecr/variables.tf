variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Tag mutability setting"
  type        = string
}

variable "force_delete" {
  description = "Force delete the repo"
  type        = bool
}

variable "encryption_type" {
  description = "Encryption type"
  type        = string
}

variable "scan_on_push" {
  description = "Scan images on push"
  type        = bool
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
}
