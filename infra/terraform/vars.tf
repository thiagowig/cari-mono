variable "CORI_DATABASE_USER" {
  type = string
}

variable "CORI_DATABASE_PASSWORD" {
  type = string
}

variable "CORI_ALARM_USER" {
  type = string
}

variable "ALLOWED_IPS" {
  type = list(string)
}

variable "tags" {
  type = map(string)

  default = {
    Terraform = "TRUE"
    Team      = "Alone"
    Name      = "cari-mono"
  }
}