# auth-mailpit

DEV/STAGING Mail-Sandbox auf Basis von Mailpit fuer Auth- und Plattform-Tests.

## Zweck / Boundary
- Lokaler SMTP-Fangdienst fuer DEV/LOCAL/STAGING.
- Kein Production-MTA, kein MX, kein externer Mailversand.
- Keine Provider-Secrets in diesem Repo speichern.

## Aktueller Stand (2026-02-12 15:32:39 CET)
- Container `auth-mailpit-stack-auth-mailpit-1` laeuft `healthy`.
- UI-Check `http://127.0.0.1:8025/` liefert `200`.
- SMTP-Sink ist lokal auf Port `1025` aktiv.

## Security Contract
- Mailpit ist nur Sandbox, nicht fuer echten Versand.
- SMTP-Auth im DEV-Modus (`MP_SMTP_AUTH_ACCEPT_ANY=1`) ist nicht production-tauglich.
- UI in Staging nicht public exponieren (nur internal/allowlist).

## Ops
### Start
```bash
cd /home/devops/auth-mailpit
docker compose up -d
docker compose ps
```

UI: `http://localhost:8025`  
SMTP sink: `localhost:1025`

### Health
```bash
docker compose ps
curl -I http://127.0.0.1:8025
```

Erwartung: Service ist `healthy`, UI liefert `200` oder `302`.

## DoD Checks
```bash
swaks \
  --server 127.0.0.1:1025 \
  --from no-reply@local.dev \
  --to qa@local.dev \
  --header "Subject: Mailpit smoke" \
  --body "mailpit smoke"
```

Erwartung: SMTP `250 Ok`, Mail erscheint in der UI.

## Service Integration Contract
Fuer lokale Services (auth/profile/worker):
```env
SMTP_HOST=auth-mailpit
SMTP_PORT=1025
SMTP_SECURE=false
SMTP_FROM=no-reply@pfad-des-paradoxons.local
```

## Provider Switch (ohne Code-Refactor)
Nur ENV/Secrets umstellen:
```env
SMTP_HOST=smtp.<provider>
SMTP_PORT=587
SMTP_SECURE=true
SMTP_USER_FILE=/run/secrets/smtp_user
SMTP_PASS_FILE=/run/secrets/smtp_password
SMTP_FROM=no-reply@your-domain.tld
```

### Logs / Stop / Reset
```bash
# Logs
docker compose logs -f auth-mailpit
tail -f data/mailpit.log

# Stop
docker compose down

# Reset persisted inbox
rm -f data/mailpit.db data/mailpit.log
```

## Guardrails
- `auth-mailpit` bleibt DEV/STAGING-only.
- Keine produktiven SMTP-Credentials im Repo.
- Mail-Inhalte koennen PII enthalten, Zugriff strikt begrenzen.
