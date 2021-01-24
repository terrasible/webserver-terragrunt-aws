resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "main" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.main.private_key_pem

  subject {
    common_name  = var.domain
    organization = var.organization
  }

  validity_period_hours = var.validity_period_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.main.private_key_pem
  certificate_body = tls_self_signed_cert.main.cert_pem
  tags             = merge(
    { 
      "Name" = format("%s", var.domain)
    },
    var.tags,
  )
}