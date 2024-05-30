#Task 1

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  # Configuration options
  region = "us-central1"
  project = "class5-5green"
  zone = "us-central1-a"
  credentials = "class5-5green-298b62a3188e.json"
}

resource "google_storage_bucket" "armabucket" {
  name          = "armabucket"
  location      = "us-central1"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }

website {
    main_page_suffix = "index.html"
    not_found_page = "404.html"    
  }
}
# access control list
// Setting the bucket ACL to public read
resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.armabucket.name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.armabucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

// Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for image files
resource "google_storage_bucket_object" "upload_images" {
  for_each     = fileset("${path.module}/", "*.jpg")
  bucket       = google_storage_bucket.armabucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "image/jpeg"
}

// Public ACL for each image file
resource "google_storage_object_acl" "image_acl" {
  for_each       = google_storage_bucket_object.upload_images
  bucket         = google_storage_bucket_object.upload_images[each.key].bucket
  object         = google_storage_bucket_object.upload_images[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.armabucket.name}/index.html"
  }

#End of Task 1