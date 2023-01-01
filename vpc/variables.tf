variable "default_tags" {
    type = map
    default = {
    Name                      = "sample-app"
    Project                   = "Hello-world"
  }
  
}

variable "elastic-version" {
  default = "8.5.0-1"
  
}