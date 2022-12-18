#create variable, specify type and set to default
variable "awsprops" {
  type = map(any)
  default = {
    region       = "us-east-1"
    ami          = "ami-0b0dcb5067f052a63"
    instancetype = "t2.micro"
    az1          = "us-east-1a"
    az2          = "us-east-1b"
  }
}
# key variable for refrencing
variable "keyname" {
  default = "NV_R_key"
}

# base_path for refrencing
variable "base_path" {
  default = "/Users/mac/Desktop/terraform-projects/"
}
