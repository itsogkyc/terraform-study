output "myalb_dns" {
  value       = aws_lb.myalb.dns_name
  description = "The DNS Address of the ALB"
}
