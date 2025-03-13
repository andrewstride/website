variable "AWS_REGION" {
  type    = string
  default = null
}

variable "AWS_PROFILE" {
  type    = string
  default = null
}

variable "website-bucket" {
  type    = string
  default = null
}

variable "log-bucket" {
  type    = string
  default = null
}

variable "VC_API_Integration_GET_ID" {
  type = string
  default = null
}

variable "VC_API_Integration_POST_ID" {
  type = string
  default = null
}

variable "VC_Lambda_IAM_Role_name" {
  type = string
  default = null
}