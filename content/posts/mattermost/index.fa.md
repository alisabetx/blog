---
title: "راه‌اندازی پیام‌رسان Mattermost"
slug: "mattermost"
date: 2026-02-13T14:00:00+03:30
lastmod: 2026-04-24T14:30:00+03:30
tags: ["mattermost", "مترموست"]
description: "راه‌اندازی پیام‌رسان Mattermost برای استفاده خانوادگی، دوستانه و کاری در روزهای قطعی اینترنت"
---

## ماجرا چیه؟

می‌خواهیم Mattermost را طوری آماده کنیم که اگر سرور داخل ایران به اینترنت بین‌المللی وصل نبود، باز هم بتوانیم آن را راه بیندازیم.

ایده ساده است:

1. روی لپتاپ، داخل WSL، یک باندل کامل می‌سازیم.
2. داخل باندل، پکیج‌های deb لازم، ایمیج‌های Docker، فایل compose و اسکریپت نصب را می‌گذاریم.
3. باندل را با `scp` می‌بریم روی سرور ایران.
4. روی سرور ایران، بدون نیاز به Docker Hub و بدون نیاز به repoهای اینترنتی، Mattermost را اجرا می‌کنیم.

در این آموزش فرض می‌کنیم لپتاپ به اینترنت بین‌المللی دسترسی دارد، ولی سرور ایران ممکن است نداشته باشد.

## یک نکته خیلی مهم قبل از شروع

نسخه Ubuntu داخل WSL باید با نسخه Ubuntu روی سرور یکی باشد. معماری هم باید یکی باشد. مثلا اگر سرور `Ubuntu 22.04 amd64` است، بهتر است WSL هم `Ubuntu 22.04 amd64` باشد.

روی WSL بزن:

```bash
lsb_release -a
dpkg --print-architecture
```

روی سرور هم بزن:

```bash
lsb_release -a
dpkg --print-architecture
```

اگر نسخه Ubuntu یا architecture یکی نبود، باندل apt ممکن است درست کار نکند.

## پیش‌نیاز روی WSL

اول وارد WSL شو. اگر Docker داخل WSL کار نمی‌کند، ساده‌ترین راه این است که Docker Desktop را روی ویندوز نصب کنی و integration مربوط به همان distro را فعال کنی.

بررسی:

```bash
docker version
docker compose version
```

اگر `docker` کار نکرد، اول Docker را برای WSL درست کن. بدون Docker نمی‌توانیم ایمیج‌ها را pull و save کنیم.

چند ابزار پایه را هم نصب می‌کنیم:

```bash
sudo apt-get update
sudo apt-get install -y apt-utils ca-certificates curl rsync tar gzip openssl
```

`apt-ftparchive` اسم پکیج نیست. با نصب `apt-utils` در دسترس قرار می‌گیرد.

بررسی:

```bash
command -v apt-ftparchive
```

اگر خروجی نداشت:

```bash
sudo apt-get install --reinstall -y apt-utils
dpkg -L apt-utils | grep apt-ftparchive
```

## تنظیم نسخه‌ها

برای نصب آفلاین، بهتر است از `latest` استفاده نکنیم. نسخه‌ها را مشخص می‌کنیم تا بعدا هم بدانیم دقیقا چه چیزی نصب شده.

```bash
export MATTERMOST_IMAGE="mattermost/mattermost-team-edition:10.5"
export POSTGRES_IMAGE="postgres:16-alpine"
export BUNDLE_DIR="$HOME/mattermost-offline-bundle"
```

اگر خواستی نسخه Mattermost را عوض کنی، همینجا عوضش کن.

## ساخت ساختار باندل روی WSL

```bash
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/apt-repo/partial"
cd "$BUNDLE_DIR"
chmod 755 "$BUNDLE_DIR" "$BUNDLE_DIR/apt-repo" "$BUNDLE_DIR/apt-repo/partial"
```

## دانلود پکیج‌های deb لازم

اینجا فقط چیزهایی را می‌گیریم که برای نصب و اجرا لازم داریم، نه کل پکیج‌های نصب‌شده روی سیستم را.

```bash
cd "$BUNDLE_DIR"
sudo apt-get clean
rm -f apt-repo/*.deb

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y --download-only install \
  -o Dir::Cache::archives="$BUNDLE_DIR/apt-repo" \
  docker.io \
  docker-compose-v2 \
  ca-certificates \
  curl \
  ufw \
  rsync \
  apt-utils
```

بررسی:

```bash
ls -1 "$BUNDLE_DIR"/apt-repo/*.deb 2>/dev/null | wc -l
```

اگر عدد 0 بود، یعنی debها دانلود نشده‌اند. در این حالت معمولا مشکل از repo، شبکه یا یکی نبودن نسخه Ubuntu است.

## ساخت APT repo آفلاین

```bash
cd "$BUNDLE_DIR/apt-repo"
apt-ftparchive packages . > Packages
gzip -kf Packages
```

بررسی:

```bash
ls -lh "$BUNDLE_DIR"/apt-repo/Packages*
```

باید حداقل `Packages` و `Packages.gz` را ببینی.

## pull کردن ایمیج‌های Docker

اینجا هنوز روی WSL هستیم و اینترنت بین‌المللی داریم.

```bash
docker pull "$POSTGRES_IMAGE"
docker pull "$MATTERMOST_IMAGE"
```

بررسی:

```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

## ذخیره ایمیج‌ها داخل باندل

```bash
docker save -o "$BUNDLE_DIR/docker-images.tar" \
  "$POSTGRES_IMAGE" \
  "$MATTERMOST_IMAGE"
```

بررسی:

```bash
ls -lh "$BUNDLE_DIR/docker-images.tar"
```

## ساخت پسورد دیتابیس

یک پسورد برای PostgreSQL می‌سازیم و داخل فایل `.env` می‌گذاریم. این فایل همراه باندل به سرور منتقل می‌شود.

```bash
cd "$BUNDLE_DIR"
POSTGRES_PASSWORD_VALUE="$(openssl rand -base64 32 | tr -d '\n')"
cat > .env <<EOF
POSTGRES_USER=mmuser
POSTGRES_PASSWORD=$POSTGRES_PASSWORD_VALUE
POSTGRES_DB=mattermost
MATTERMOST_IMAGE=$MATTERMOST_IMAGE
POSTGRES_IMAGE=$POSTGRES_IMAGE
EOF
chmod 600 .env
```

بررسی:

```bash
ls -lh "$BUNDLE_DIR/.env"
```

## ساخت فایل compose

```bash
cat > "$BUNDLE_DIR/compose.yaml" <<'EOF'
services:
  mm-db:
    image: ${POSTGRES_IMAGE}
    container_name: mm-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - mm-db-data:/var/lib/postgresql/data

  mm-app:
    image: ${MATTERMOST_IMAGE}
    container_name: mm-app
    restart: unless-stopped
    depends_on:
      - mm-db
    ports:
      - "8065:8065"
    environment:
      MM_SQLSETTINGS_DRIVERNAME: postgres
      MM_SQLSETTINGS_DATASOURCE: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@mm-db:5432/${POSTGRES_DB}?sslmode=disable&connect_timeout=10
    volumes:
      - mm-app-config:/mattermost/config
      - mm-app-data:/mattermost/data
      - mm-app-logs:/mattermost/logs
      - mm-app-plugins:/mattermost/plugins
      - mm-app-client-plugins:/mattermost/client/plugins

volumes:
  mm-db-data:
  mm-app-config:
  mm-app-data:
  mm-app-logs:
  mm-app-plugins:
  mm-app-client-plugins:
EOF
```

بررسی:

```bash
ls -lh "$BUNDLE_DIR/compose.yaml"
```

## ساخت اسکریپت نصب آفلاین

این اسکریپت روی سرور ایران اجرا می‌شود. سورس‌های اینترنتی apt را موقتاً کنار می‌گذارد، repo آفلاین داخل باندل را فعال می‌کند، Docker را از همان debها نصب می‌کند، ایمیج‌ها را load می‌کند و Mattermost را بالا می‌آورد.

```bash
cat > "$BUNDLE_DIR/install-offline.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR="$(cd "$(dirname "$0")" && pwd)"
APT_REPO_DIR="$BUNDLE_DIR/apt-repo"
DOCKER_TAR="$BUNDLE_DIR/docker-images.tar"
COMPOSE_FILE="$BUNDLE_DIR/compose.yaml"
ENV_FILE="$BUNDLE_DIR/.env"

echo "[1/9] Sanity checks..."
test -d "$APT_REPO_DIR"
test -f "$APT_REPO_DIR/Packages.gz"
test -f "$DOCKER_TAR"
test -f "$COMPOSE_FILE"
test -f "$ENV_FILE"

echo "[2/9] Fix permissions for _apt sandbox..."
chmod 755 /opt || true
chmod 755 "$BUNDLE_DIR" "$APT_REPO_DIR" || true
mkdir -p "$APT_REPO_DIR/partial"
chmod 755 "$APT_REPO_DIR/partial" || true

echo "[3/9] Configure APT to use offline repo..."
mkdir -p /etc/apt/sources.list.d /etc/apt/disabled-sources
cat > /etc/apt/sources.list.d/offline-bundle.list <<EOL
deb [trusted=yes] file:$APT_REPO_DIR ./
EOL

echo "[4/9] Disable online APT sources..."
find /etc/apt/sources.list.d -maxdepth 1 -type f \
  ! -name "offline-bundle.list" \
  -exec mv -v {} /etc/apt/disabled-sources/ \; 2>/dev/null || true

test -f /etc/apt/sources.list && mv -v /etc/apt/sources.list /etc/apt/disabled-sources/sources.list.bak 2>/dev/null || true

echo "[5/9] APT update from offline repo..."
apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update

echo "[6/9] Install required packages from offline repo..."
DEBIAN_FRONTEND=noninteractive apt-get -y install \
  docker.io \
  docker-compose-v2 \
  ca-certificates \
  curl \
  ufw \
  rsync \
  apt-utils

systemctl enable --now docker

echo "[7/9] Load Docker images..."
docker load -i "$DOCKER_TAR"

echo "[8/9] Start Mattermost..."
cd "$BUNDLE_DIR"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d

echo "[9/9] Open firewall port if ufw is active..."
if command -v ufw >/dev/null 2>&1; then
  ufw allow 8065 || true
  ufw reload || true
fi

echo "Done."
EOF

chmod +x "$BUNDLE_DIR/install-offline.sh"
```

## تست کامل بودن باندل قبل از tar

```bash
cd "$BUNDLE_DIR"

test -f apt-repo/Packages.gz
test -f docker-images.tar
test -f compose.yaml
test -f install-offline.sh
test -f .env

ls -1 apt-repo/*.deb 2>/dev/null | wc -l
ls -lh apt-repo/Packages.gz
ls -lh docker-images.tar
ls -lh compose.yaml
ls -lh install-offline.sh
ls -lh .env
```

مطمئن شو ایمیج‌ها روی WSL وجود دارند:

```bash
docker image inspect "$POSTGRES_IMAGE" >/dev/null
docker image inspect "$MATTERMOST_IMAGE" >/dev/null
```

## خروجی گرفتن tar نهایی

```bash
cd "$HOME"
tar -czf mattermost-offline-bundle.tar.gz mattermost-offline-bundle
ls -lh "$HOME/mattermost-offline-bundle.tar.gz"
```

محتوای tar را هم چک کن:

```bash
tar -tzf "$HOME/mattermost-offline-bundle.tar.gz" | grep -E 'docker-images.tar|compose.yaml|install-offline.sh|apt-repo/Packages.gz|\.env'
```

خب. حالا یک فایل داریم که می‌توانیم روی سرور ایران استفاده کنیم.

## انتقال فایل به سرور ایران

روی WSL:

```bash
scp -P PORT "$HOME/mattermost-offline-bundle.tar.gz" root@SERVER_IP:/root/
```

به جای `PORT` پورت SSH و به جای `SERVER_IP` آی‌پی سرور را بگذار.

## بازکردن فایل روی سرور

از اینجا به بعد روی سرور ایران هستیم.

```bash
ssh -p PORT root@SERVER_IP

cd /root
tar -xzf mattermost-offline-bundle.tar.gz
```

## انتقال باندل به /opt

```bash
rm -rf /opt/mattermost-offline-bundle
mkdir -p /opt/mattermost-offline-bundle
rsync -a /root/mattermost-offline-bundle/ /opt/mattermost-offline-bundle/

chown -R root:root /opt/mattermost-offline-bundle
chmod 755 /opt
chmod -R a+rX /opt/mattermost-offline-bundle
chmod 600 /opt/mattermost-offline-bundle/.env
```

از اینجا به بعد با `/opt/mattermost-offline-bundle` کار می‌کنیم.

## اجرای نصب آفلاین

```bash
cd /opt/mattermost-offline-bundle
./install-offline.sh
```

اگر این مرحله درست انجام شود، نباید به Docker Hub یا repoهای آنلاین Ubuntu نیاز داشته باشی.

## تست نهایی

بررسی کانتینرها:

```bash
docker ps
```

باید ببینی:

```text
mm-db
mm-app
```

اگر ندیدی، اول کانتینرهای متوقف‌شده را هم ببین:

```bash
docker ps -a
```

بعد لاگ‌ها را چک کن:

```bash
cd /opt/mattermost-offline-bundle
docker compose --env-file .env -f compose.yaml logs --tail=100
```

اگر اصلاً `mm-db` و `mm-app` ساخته نشده‌اند، یعنی `compose.yaml` داخل باندل نبوده، ایمیج‌ها load نشده‌اند، یا `docker compose` درست اجرا نشده است.

تست HTTP:

```bash
curl -I http://127.0.0.1:8065
```

اگر 200 یا 302 گرفتی، یعنی Mattermost جواب می‌دهد.

## دسترسی از بیرون

در مرورگر:

```text
http://SERVER_IP:8065
```

اگر صفحه باز نشد، این‌ها را چک کن:

```bash
ss -lntp | grep 8065
ufw status
```

همچنین در پنل VPS مطمئن شو پورت 8065 بسته نشده باشد.

## خطاهای رایج

### خطای Unable to locate package apt-ftparchive

`apt-ftparchive` پکیج جدا نیست. این دستور با `apt-utils` نصب می‌شود.

در WSL بزن:

```bash
sudo apt-get update
sudo apt-get install -y apt-utils
command -v apt-ftparchive
```

### Docker داخل WSL کار نمی‌کند

بررسی:

```bash
docker version
```

اگر به Docker daemon وصل نشد، Docker Desktop را روی ویندوز نصب کن و WSL integration را برای همان distro فعال کن.

### روی سرور، apt دنبال اینترنت می‌گردد

یعنی سورس‌های آنلاین کامل غیرفعال نشده‌اند یا `offline-bundle.list` درست ساخته نشده است.

بررسی:

```bash
cat /etc/apt/sources.list.d/offline-bundle.list
ls /etc/apt/sources.list.d/
apt-get update
```

در خروجی `apt-get update` باید فقط مسیر `file:/opt/mattermost-offline-bundle/apt-repo` را ببینی.

### mm-db و mm-app را نمی‌بینم

اول ببین کانتینرها اصلاً ساخته شده‌اند یا نه:

```bash
docker ps -a
```

بعد لاگ بگیر:

```bash
cd /opt/mattermost-offline-bundle
docker compose --env-file .env -f compose.yaml logs --tail=100
```

اگر image پیدا نشد، یعنی `docker load -i docker-images.tar` درست انجام نشده است.

### نسخه Ubuntu در WSL و سرور فرق دارد

در این حالت ممکن است debها نصب نشوند. بهتر است WSL را با همان نسخه Ubuntu سرور بسازی و باندل را دوباره تولید کنی.

{{< edit >}}

# منابع {#references}
[Mattermost](https://mattermost.com/)
