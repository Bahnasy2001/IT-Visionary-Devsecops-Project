resource "aws_lb" "this" {
# checkov:skip=CKV2_AWS_76 reason="WAF includes AWSManagedRulesLog4RuleSet for Log4j protection"
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = true

  

  tags = merge(
    {
      Name = "${var.name_prefix}-alb"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Optional redirect from HTTP to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.example.arn
}

resource "aws_wafv2_web_acl" "example" {
# checkov:skip=CKV2_AWS_31 reason="WAF Logging is enabled via aws_wafv2_logging_configuration"
  name        = "my-acl"
  description = "WAF for ALB"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    override_action {
      none {}
    }
    

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "log4j-block"
      sampled_requests_enabled   = true
    }
  }

  rule {
  name     = "AWSManagedRulesLog4RuleSet"
  priority = 2

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesLog4RuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "log4j-protection"
    sampled_requests_enabled   = true
  }
}


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf"
    sampled_requests_enabled   = true
  }

  tags=var.tags
}

# resource "aws_wafv2_logging_configuration" "waf_logs" {
#   log_destination_configs = [aws_kinesis_firehose_delivery_stream.example.arn]
#   resource_arn = aws_wafv2_web_acl.example.arn

#   redacted_fields {
#     single_header {
#       name = "Authorization"
#     }
#   }
# }


resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}