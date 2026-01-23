#!/usr/bin/env bash
set -euo pipefail

log() { echo -e "\n[INFO] $1"; }
warn() { echo -e "\n[WARN] $1"; }
err() { echo -e "\n[ERROR] $1" >&2; }

if [[ "${EUID}" -ne 0 ]]; then
  err "Запусти скрипт з правами root: sudo ./install_dev_tools.sh"
  exit 1
fi

if [[ ! -f /etc/debian_version ]]; then
  err "Скрипт підтримує лише Ubuntu/Debian (apt)."
  exit 1
fi

log "Початок встановлення DevOps інструментів: Docker, Docker Compose, Python3 (3.9+), Django (pip у venv)"

APT_UPDATED=0
apt_update_once() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    log "apt-get update..."
    apt-get update -y
    APT_UPDATED=1
  fi
}
install_packages() {
  apt_update_once
  apt-get install -y "$@"
}
command_exists() { command -v "$1" >/dev/null 2>&1; }

# ========= Docker =========
if command_exists docker; then
  log "Docker вже встановлений: $(docker --version)"
else
  log "Встановлюю Docker (docker.io)..."
  install_packages docker.io
  systemctl enable --now docker >/dev/null 2>&1 || true
  log "Docker встановлено: $(docker --version)"
fi

# ========= Docker Compose (v1) =========
if command_exists docker-compose; then
  log "Docker Compose вже встановлений: $(docker-compose --version)"
else
  log "Встановлюю Docker Compose (docker-compose)..."
  install_packages docker-compose
  log "Docker Compose встановлено: $(docker-compose --version)"
fi

# ========= Python =========
if command_exists python3; then
  log "Python3 вже встановлений: $(python3 --version)"
else
  log "Встановлюю Python3..."
  install_packages python3
  log "Python3 встановлено: $(python3 --version)"
fi

# Перевірка 3.9+
PY_OK="$(python3 - <<'PY'
import sys
print("1" if (sys.version_info.major, sys.version_info.minor) >= (3, 9) else "0")
PY
)"
if [[ "$PY_OK" != "1" ]]; then
  warn "Поточний python3 нижчий за 3.9. Спробую встановити python3.9 (якщо доступний)..."
  install_packages python3.9 python3.9-venv python3.9-distutils || true
  if command_exists python3.9; then
    log "python3.9 встановлено: $(python3.9 --version)"
  else
    warn "python3.9 недоступний у репозиторії. Продовжую з поточним python3."
  fi
fi

# ========= pip + venv support =========
if command_exists pip3; then
  log "pip3 вже встановлений: $(pip3 --version | head -n 1)"
else
  log "Встановлюю pip3..."
  install_packages python3-pip
  log "pip3 встановлено: $(pip3 --version | head -n 1)"
fi

# Важливо для PEP 668: ставимо Django через pip у virtualenv
log "Перевіряю підтримку venv..."
install_packages python3-venv

VENV_DIR="/opt/devops-venv"
DJANGO_PY="${VENV_DIR}/bin/python"
DJANGO_PIP="${VENV_DIR}/bin/pip"
DJANGO_ADMIN="${VENV_DIR}/bin/django-admin"

if [[ -x "$DJANGO_PY" ]] && "$DJANGO_PY" -c "import django" >/dev/null 2>&1; then
  DJ_VER="$("$DJANGO_PY" -c "import django; print(django.get_version())")"
  log "Django вже встановлений у venv (${VENV_DIR}): ${DJ_VER}"
else
  log "Створюю virtualenv у ${VENV_DIR} і встановлюю Django через pip..."
  python3 -m venv "$VENV_DIR"
  "$DJANGO_PIP" install --upgrade pip
  "$DJANGO_PIP" install django
  DJ_VER="$("$DJANGO_PY" -c "import django; print(django.get_version())")"
  log "Django встановлено у venv: ${DJ_VER}"
fi

# Зручно: зробити django-admin доступним як команда в системі (не обов’язково, але корисно)
if [[ -x "$DJANGO_ADMIN" ]]; then
  ln -sf "$DJANGO_ADMIN" /usr/local/bin/django-admin
fi

log "Готово ✅"
log "Перевірка версій:"
echo " - Docker:         $(docker --version 2>/dev/null || true)"
echo " - Docker Compose: $(docker-compose --version 2>/dev/null || true)"
echo " - Python:         $(python3 --version 2>/dev/null || true)"
echo " - Django (venv):  $("$DJANGO_PY" -c 'import django; print(django.get_version())' 2>/dev/null || true)"
