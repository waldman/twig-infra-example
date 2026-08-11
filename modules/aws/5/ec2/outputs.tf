output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "ssh_command" {
  description = "Convenience SSH command (if public IP present)."
  value       = var.ec2_associate_public_ip ? "ssh ubuntu@${aws_instance.this.public_ip}" : "ssh ubuntu@${aws_instance.this.private_ip}"
}
