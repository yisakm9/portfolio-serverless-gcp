variable "domain_name" {
  description = "The domain name (e.g., yisakmesifin.org)"
  type        = string
}

variable "load_balancer_ip" {
  description = "The GCP Global Load Balancer static IP address"
  type        = string
}
