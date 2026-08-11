output "key_name" {
  value = aws_key_pair.this.key_name
}

output "key_pair_id" {
  value = aws_key_pair.this.key_pair_id
}

output "fingerprint" {
  value = aws_key_pair.this.fingerprint
}
