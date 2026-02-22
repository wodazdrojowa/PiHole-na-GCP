# TerraformTest1forGCP
Test Terraform i Ansible tworzace instancje na GCP

What 



Don't forget:
GCP limitations - Compute Engine	
- 1 non-preemptible e2-micro VM instance per month
Region:
    us-west1
    us-central1
    us-east1
Disk:
    30 GB
    HDD only
Transfer:
    1 GB of outbound data transfer from North America to all region destinations (excluding China and Australia) per month.



    Spacelift.io
    przekazywanie zmiennych i loginów/haseł
    Jak bezpiecznie przekazać terraform.tfvars i dane do GCP w Spacelift
🔐 Metoda 1 (Zalecana): OIDC / Workload Identity Federation dla GCP
To najlepsza metoda — Spacelift nie przechowuje żadnych długotrwałych kluczy. Zamiast tego generuje krótkotrwały token przy każdym uruchomieniu.
Konfiguracja po stronie GCP:

W GCP Console → IAM & Admin → Workload Identity Federation → Create Pool
Dodaj provider OpenID Connect (OIDC):
    Issuer URL: https://<twoja-nazwa>.app.spacelift.io
    Audiences: <twoja-nazwa>.app.spacelift.io
Skonfiguruj mapowania atrybutów:
    google.subject → assertion.sub
    attribute.space → assertion.spaceId
Powiąż Service Account z tym pool'em i nadaj mu odpowiednie role
Po konfiguracji Spacelift automatycznie wstrzykuje zmienną GOOGLE_OAUTH_ACCESS_TOKEN do każdego runu — bez żadnego klucza JSON w kodzie.

pozostałe metody:
https://claude.ai/share/b61bbfde-34a3-405b-a4cb-da888438bbfe

##################
dodać w GCP Service Account dla Spacelift.io z minimalnymi uprawinieniami czyli 
roles/compute.admin