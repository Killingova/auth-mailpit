# auth-mailpit

DEV/STAGING Mail-Sandbox auf Basis von Mailpit fuer Auth- und Plattform-Tests.

## Aktueller Stand (2026-02-12 14:37:47 CET)
- Container `auth-mailpit-stack-auth-mailpit-1` laeuft `healthy`.
- UI-Check `http://127.0.0.1:8025/` liefert `200`.
- SMTP-Sink ist lokal auf Port `1025` aktiv.

## Boundary
- Nur fuer `DEV/LOCAL/STAGING`.
- Kein Production-MTA, kein MX, kein externer Mailversand.
- Keine Provider-Secrets in diesem Repo speichern.

## Start
```bash
cd /home/devops/auth-mailpit
docker compose up -d
docker compose ps
```

UI: `http://localhost:8025`  
SMTP sink: `localhost:1025`

## Health
```bash
docker compose ps
curl -I http://127.0.0.1:8025
```

Erwartung: Service ist `healthy`, UI liefert `200` oder `302`.

## Smoke Test (SMTP)
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

## Ops
```bash
# Logs
docker compose logs -f auth-mailpit
tail -f data/mailpit.log

# Stop
docker compose down

# Reset persisted inbox
rm -f data/mailpit.db data/mailpit.log
```

## Security Notes
- `MP_SMTP_AUTH_ACCEPT_ANY=1` ist nur fuer DEV gesetzt.
- In Staging UI nicht public exponieren (internal-only oder allowlist).
- Mail-Inhalte koennen PII enthalten; Zugriff entsprechend einschraenken.
- Keine Redirect-Open-URI Muster in Verify/Magic-Links zulassen (Service-seitig).
