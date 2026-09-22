output "api_url" {
  description = "Application URL. Open this in a browser."
  value       = local.app_url
}

output "employee_api_url" {
  description = "Authenticated employee lookup route."
  value       = "${trimsuffix(local.app_url, "/")}/employee/{id}"
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_client_id" {
  description = "Public app client ID. There is no client secret."
  value       = aws_cognito_user_pool_client.this.id
}

output "cognito_managed_login_domain" {
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "student_employee_id" {
  value = var.student_employee_id
}

output "student_description_arn" {
  value = local.student_arn
}
