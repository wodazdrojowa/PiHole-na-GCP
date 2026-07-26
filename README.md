# TerraformTest1forGCP
Test Terraform i Ansible tworzace instancje na GCP

What 




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





Jak to działa krok po kroku
Terraform tworzy VM, przydziela stałe IP i otwiera porty 80/443.
Ansible instaluje Pi-hole v6 w trybie unattended.
Restartuje pihole-FTL, żeby wbudowany serwer webowy działał.
Certbot wystawia certyfikat przez webroot w /etc/pihole/www (serwowany przez Pi-hole).
Ansible łączy privkey.pem + fullchain.pem w /etc/pihole/tls.pem.
Konfiguruje Pi-hole przez CLI: pihole-FTL --config webserver.tls.cert ... i webserver.domain ....
Restartuje FTL — od tej chwili panel działa po HTTPS.
Deploy hook certbota zapewnia, że po każdym certbot renew certyfikat zostanie odświeżony w Pi-hole.