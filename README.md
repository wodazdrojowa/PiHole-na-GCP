kod QR dla klienta wireguard generujeszz poleceniem
sudo su
# ZAKODUJ KONFIGURACJĘ KLIENTA, nie serwera!
qrencode -t ansiutf8 < /etc/wireguard/clients/client1.conf


diagnostyka

# 1. Sprawdź czy IP forwarding jest włączony w GCP
sudo sysctl net.ipv4.ip_forward
# Powinno być: net.ipv4.ip_forward = 1

# 2. Sprawdź czy MASQUERADE działa
sudo iptables -t nat -L POSTROUTING -v -n
# Powinno pokazać: MASQUERADE  all --  anywhere  anywhere   [interfejs]

# 3. Sprawdź czy FORWARD chain przepuszcza pakiety z wg0
sudo iptables -L FORWARD -v -n | grep wg0
# Powinno pokazać: ACCEPT  all --  anywhere  anywhere  [interfejs: wg0]

# 4. Sprawdź czy UFW nie blokuje forwardingu
sudo iptables -L ufw-forward -v -n 2>/dev/null || echo "no ufw-forward chain"
sudo iptables -L ufw-before-forward -v -n 2>/dev/null || echo "no ufw-before-forward"

# 5. Sprawdź czy WireGuard w ogóle forwarduje
sudo wg show
# Powinno pokazać: transfer, latest-handshake

# 6. Sprawdź routing na serwerze
ip route | grep default

# 7. Sprawdź czy pakiety z VPN wychodzą na internet
sudo tcpdump -i wg0 -n icmp 2>/dev/null &
# Z telefonu: ping 1.1.1.1
# Na serwerze powinieneś zobaczyć pakiety ICMP z 10.8.0.X



certyfikat SSL
Uprawnienia w OVH API
W formularzu createToken dodaj:
Table
Method	Path
GET	/domain/zone/owmor.de/*
POST	/domain/zone/owmor.de/record
DELETE	/domain/zone/owmor.de/record/*
Jak to działa
Ansible instaluje python3-certbot-dns-ovh
Tworzy /etc/letsencrypt/ovh.ini z kluczami
Certbot dodaje rekord TXT _acme-challenge.pihole.owmor.de przez API OVH
Let's Encrypt weryfikuje domenę przez DNS (nie potrzeba portu 80!)
Certbot usuwa rekord TXT i wystawia certyfikat
Pi-hole dostaje certyfikat i działa po HTTPS
Nie potrzeba nginx, nie potrzeba webroot, nie potrzeba zatrzymywać Pi-hole.


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


Jak uzyskać klucze OVH
Wejdź na https://eu.api.ovh.com/createToken/
Zaloguj się do konta OVH
Wypełnij formularz:
Application name: certbot
Application description: Let's Encrypt DNS challenge
Validity: Unlimited
Rights:
GET → /domain/zone/owmor.de/*
POST → /domain/zone/owmor.de/record
DELETE → /domain/zone/owmor.de/record/*
Kliknij Create keys
Zapisz:
Application Key
Application Secret
Consumer Key
Krok 3: Wystaw certyfikat
bash
sudo certbot certonly \
  --dns-ovh \
  --dns-ovh-credentials /etc/letsencrypt/ovh.ini \
  -d pihole.owmor.de
Krok 4: Skonfiguruj Pi-hole
bash
sudo bash -c 'cat /etc/letsencrypt/live/pihole.owmor.de/privkey.pem /etc/letsencrypt/live/pihole.owmor.de/fullchain.pem > /etc/pihole/tls.pem'
sudo chown pihole:pihole /etc/pihole/tls.pem
sudo chmod 600 /etc/pihole/tls.pem
sudo pihole-FTL --config webserver.domain pihole.owmor.de
sudo pihole-FTL --config webserver.tls.cert /etc/pihole/tls.pem
sudo systemctl restart pihole-FTL
Krok 5: Auto-odnawianie
bash
sudo tee /etc/letsencrypt/renewal-hooks/deploy/99-pihole.sh << 'EOF'
#!/bin/bash
cat /etc/letsencrypt/live/pihole.owmor.de/privkey.pem /etc/letsencrypt/live/pihole.owmor.de/fullchain.pem > /etc/pihole/tls.pem
chown pihole:pihole /etc/pihole/tls.pem
chmod 600 /etc/pihole/tls.pem
systemctl restart pihole-FTL
EOF
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/99-pihole.sh