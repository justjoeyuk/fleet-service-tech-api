output "subnet1_id" {
  value = aws_subnet.default1.id
}

output "subnet2_id" {
  value = aws_subnet.default2.id
}

output "subnet3_id" {
  value = aws_subnet.default3.id
}

output "vpc_id" {
  value = aws_vpc.default.id
}

output "security_group_id" {
  value = aws_security_group.default.id
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
}

output "subnet_group_id" {
  value = aws_db_subnet_group.default.id
}

output "subnet_ids" {
  value = [aws_subnet.default1.id, aws_subnet.default2.id, aws_subnet.default3.id]
}

output "security_group_ids" {
  value = [aws_security_group.default.id]
}
