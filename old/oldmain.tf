# AWS S3 bucket resource

resource "aws_s3_bucket" "demo-bucket" {
  bucket = var.my_bucket_name # Name of the S3 bucket
}


resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.demo-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.demo-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# AWS S3 bucket ACL resource
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.demo-bucket.id
  acl    = "public-read"
}


resource "aws_iam_policy" "s3_policy" {
  name        = "S3Policy"
  description = "Allows full access to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:*",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "s3_attachment" {
  name       = "s3_attachment"
  policy_arn = aws_iam_policy.s3_policy.arn
  users      = ["SoumyaDevOps"]
}

resource "aws_s3_bucket_policy" "host_bucket_policy" {
  bucket =  aws_s3_bucket.demo-bucket.id # ID of the S3 bucket

  # Policy JSON for allowing public read access
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" :  [
				"s3:PutObject",
				"s3:GetObject"
			],
        "Resource": "arn:aws:s3:::${var.my_bucket_name}/*"
      }
    ]
  })
}


# module "template_files" {
#     source = "hashicorp/dir/template"

#     base_dir = "${path.module}/web-files"
# }

# https://registry.terraform.io/modules/hashicorp/dir/template/latest


resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket =    aws_s3_bucket.demo-bucket.id  # ID of the S3 bucket

  # Configuration for the index document
  index_document {
    suffix = "index.html"
  }
  # Configuration for the error document
  error_document {
    key = "error.html"
  }
}

# AWS S3 object resource for hosting bucket files
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.demo-bucket.id  # ID of the S3 bucket

  key          = "index.html"
  content_type = "text/html"  # Assuming index.html is HTML content

  # Path to your local index.html file
  source = "C:/Projects/DevOps/Projects/S3StaticWebHosting/index.html"
}
# AWS S3 object resource for hosting bucket files - error.html
resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.demo-bucket.id  # ID of the S3 bucket

  key          = "error.html"
  content_type = "text/html"  # Assuming error.html is HTML content

  # Path to your local error.html file
  source = "C:/Projects/DevOps/Projects/S3StaticWebHosting/error.html"
}