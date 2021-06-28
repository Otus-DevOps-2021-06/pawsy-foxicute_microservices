terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "tf-bucket-pf"
    region                      = "ru-central1"
    key                         = "terraform.tfstate"
    access_key                  = "IZ4TgNkRT995HrWqiHmw"
    secret_key                  = "nMvqW0Es7YRc8f9uX95Ya1ngSdvU7us8M6s3UCb6"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
