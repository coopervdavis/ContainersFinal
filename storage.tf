# Add to the top of storage.tf

resource "random_id" "suffix" {
  byte_length = 4
}
resource "aws_s3_bucket" "media" {
  bucket = "nhl-django-media-assets-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "media_public_access" {
  bucket                  = aws_s3_bucket.media.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.media.id}"
  }

  enabled = true
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.media.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Add to the bottom of storage.tf

resource "aws_s3_object" "team_logos" {
  for_each = fileset("${path.module}/media/team_logos", "*")

  bucket       = aws_s3_bucket.media.id
  key          = "team_logos/${each.value}"
  source       = "${path.module}/media/team_logos/${each.value}"
  content_type = "image/png"

  # Ensure the bucket exists before trying to upload
  depends_on = [aws_s3_bucket.media]
}
