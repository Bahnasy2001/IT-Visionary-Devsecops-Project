name                 = "vprofile-ecr-dev"
image_tag_mutability = "MUTABLE"
force_delete         = false
encryption_type      = "AES256"
scan_on_push         = true
tags = {
  Environment = "dev"
  Project     = "vprofile"
}
