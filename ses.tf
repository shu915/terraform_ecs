resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

# DKIMの設定
resource "aws_ses_domain_dkim" "ses_dkim" {
  domain = aws_ses_domain_identity.ses.domain
}

# DKIMレコードの設定
resource "aws_route53_record" "ses_dkim_record" {
  count   = 3
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_dkim.dkim_tokens, count.index)}._domainkey.${aws_route53_zone.route53_zone.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SPFレコードの設定
resource "aws_route53_record" "ses_spf_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = aws_route53_zone.route53_zone.name
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

# ドメイン検証用のTXTレコード
resource "aws_route53_record" "ses_verification_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_amazonses.${aws_route53_zone.route53_zone.name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.ses.verification_token]
}

