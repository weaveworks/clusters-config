variable "name" {
  type        = string
  description = "Name of the service role"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the service role"
}

variable "service_identifier" {
  type        = string
  description = "Subdomain of amazonaws.com that identifies this service (e.g. 'ec2.amazonaws.com' -> 'ec2')"
}

variable "aws_policies_to_attach" {
  type        = list(string)
  description = "List of AWS managed policies to attach to the role"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to the role"
}
