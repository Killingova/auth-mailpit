SHELL := /bin/bash

.PHONY: mailpit-up mailpit-down mailpit-ps mailpit-logs mailpit-health mailpit-reset

mailpit-up:
	docker compose up -d

mailpit-down:
	docker compose down

mailpit-ps:
	docker compose ps

mailpit-logs:
	docker compose logs -f auth-mailpit

mailpit-health:
	curl -fsS -I http://127.0.0.1:8025

mailpit-reset: mailpit-down
	rm -f data/mailpit.db data/mailpit.log
	@echo "mailpit state reset"
