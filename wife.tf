# 1. Definicja zmiennych
variable "project_id" { default = "TWÓJ_PROJEKT_ID" }
variable "github_repo" { default = "TWÓJ_LOGIN/TWOJE_REPO" } # np. "jandow/my-infra"

# 2. Utworzenie Poola tożsamości
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Pool"
  description               = "Identity pool for GitHub Actions"
}

# 3. Utworzenie Dostawcy (Providera)
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 4. Konto serwisowe, którym będzie posługiwał się GitHub
resource "google_service_account" "terraform_sa" {
  account_id   = "github-terraform-sa"
  display_name = "Service Account for GitHub Actions Terraform"
}

# 5. Pozwolenie GitHubowi na używanie tego konta serwisowego
resource "google_iam_service_account_iam_member" "wif_user" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

# 6. Nadanie uprawnień kontu serwisowemu (np. Editor)
resource "google_project_iam_member" "sa_roles" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# 7. Wyświetlenie potrzebnych danych do GitHub Actions
output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "service_account_email" {
  value = google_service_account.terraform_sa.email
}
