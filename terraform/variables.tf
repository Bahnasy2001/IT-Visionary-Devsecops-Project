variable "name" {
  type = string
}

variable "image_tag_mutability" {
  type = string
}

variable "force_delete" {
  type = bool
}

variable "encryption_type" {
  type = string
}

variable "scan_on_push" {
  type = bool
}

variable "tags" {
  type = map(string)
}
#