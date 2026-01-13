output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "oidc_provider_thumbprint" {
  description = "First thumbprint of the GitHub Actions OIDC provider"
  value       = aws_iam_openid_connect_provider.github.thumbprint_list[0]
}

output "oidc_provider_url" {
  description = "URL of the GitHub Actions OIDC provider"
  value       = aws_iam_openid_connect_provider.github.url
}