output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets_ids" {
  value = [for i in aws_subnet.public_subnets : i.id]
}

output "private_subnets_ids" {
  value = [for i in aws_subnet.private_subnets : i.id]
}

output "default_security_group_id" {
  value = aws_default_security_group.this.id
}