

 ########
 # Vars #

variable "aws_region" { default = "us-west-2" } # US-oregon

 # AWS SDK auth
provider "aws" {
    region = "${var.aws_region}"
    access_key = "ABIASDLASDIHV6QNZASQ"
    secret_key = "06mcwWI7MhP59cKss5PQjPyPGzvF7k/gNCdZGKYc"
}

 ############
 # SSH keys #

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bHilZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5AVcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"
}


resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1Av8Kj8LqsI6cK31n4IElsxsGemzDXAI8NSCSRtTlNh8dJIIXpWnrGFSM9NU8++4qQmlYv+5uRhKS1SMZcPgRlcNGIBGLQxolFVw437zvt5O5mgLePRjgXpQWF/0fwx4iKark9Djyt8eHjSbTHCqpflT2xgFPMq0sJFJWmIMcGMkIh436AbjubvlgB8K1CGJzbTM4xHhlEywrggDekUcvXD2IKQFHAbO1pU/47krLdaOEhY0KeHnxfrBLU4RLxn1lyQkWLqLvuM+7o4j5lcMS/v3CC5t8I80uMByK76TC7qFOmZdU0jdo0tJBDzCBw1EmjIkD9urO1ZfL+r7FSbH xerus@goishi"
}


