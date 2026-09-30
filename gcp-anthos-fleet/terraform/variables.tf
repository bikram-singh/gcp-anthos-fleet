variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "gcp-anthos-fleet"
}

variable "region_a" {
  type    = string
  default = "asia-south1"
}

variable "zone_a" {
  type    = string
  default = "asia-south1-a"
}

variable "region_b" {
  type    = string
  default = "asia-southeast1"
}

variable "zone_b" {
  type    = string
  default = "asia-southeast1-a"
}

variable "machine_type" {
  description = "Node machine type. Use e2-standard-2 to save cost."
  type        = string
  default     = "e2-standard-4"
}

variable "node_count" {
  description = "Nodes per cluster"
  type        = number
  default     = 2
}
