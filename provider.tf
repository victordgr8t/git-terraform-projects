#create provider and specify provider name
provider "aws" {
  region = lookup(var.awsprops, "region")
}
