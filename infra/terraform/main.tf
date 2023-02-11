resource "aws_security_group" "allow_access_cori_db" {
  name = "allow_access_cori_db"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.ALLOWED_IPS
  }
}

resource "aws_db_instance" "cori_db_instance" {
  identifier             = "coridb"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 8
  db_name                = "coridb"
  engine                 = "postgres"
  engine_version         = "14.6"
  username               = var.CORI_DATABASE_USER
  password               = var.CORI_DATABASE_PASSWORD
  vpc_security_group_ids = [aws_security_group.allow_access_cori_db.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}
