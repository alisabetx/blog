---
title: "راه‌اندازی پیام‌رسان Mattermost"
slug: "mattermost"
date: 2026-02-13T14:00:00+03:30
lastmod: 2026-02-13T14:00:00+03:30
tags: ["mattermost", "مترموست"]
description: "راه‌اندازی پیام‌رسان Mattermost برای استفاده خانوادگی، دوستانه و کاری در روزهای قطعی اینترنت"
---

## خرید سرور!
## ورود به سرور

```bash
ssh -p PORT root@SERVER_IP
```

## آپدیت کامل سیستم

این مرحله باعث می‌شود باندلِ apt-repo جدیدترین نسخه‌های پکیج‌ها را داشته باشد.

```bash
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y autoremove --purge
```

## ساخت ساختار باندل

```bash
mkdir -p /opt/mattermost-offline-bundle/apt-repo/partial
cd /opt/mattermost-offline-bundle
chmod 755 /opt /opt/mattermost-offline-bundle /opt/mattermost-offline-bundle/apt-repo
chmod 755 /opt/mattermost-offline-bundle/apt-repo/partial
```

## گرفتن لیست پکیج‌ها

### لیست کل پکیج‌های نصب‌شده

```bash
cd /opt/mattermost-offline-bundle
dpkg-query -W -f='${binary:Package}\n' > pkglist.installed.txt
```

### دانلود deb ها داخل apt-repo

```bash
cd /opt/mattermost-offline-bundle
mkdir -p apt-repo/partial
chmod 755 /opt /opt/mattermost-offline-bundle /opt/mattermost-offline-bundle/apt-repo apt-repo/partial

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get -y --download-only install \
  --reinstall \
  -o Dir::Cache::archives="$(pwd)/apt-repo" \
  $(cat pkglist.installed.txt)
```

بررسی:

```bash
ls -1 /opt/mattermost-offline-bundle/apt-repo/*.deb 2>/dev/null | wc -l
```

اگر 0 بود، یعنی download واقعاً انجام نشده (یا شبکه/ریپو مشکل دارد).

## ساخت APT repo آفلاین

```bash
cd /opt/mattermost-offline-bundle/apt-repo
apt-get update
apt-get install -y apt-utils

apt-ftparchive packages . > Packages
gzip -kf Packages
```

بررسی:

```bash
ls -lh /opt/mattermost-offline-bundle/apt-repo/Packages*
```

## نصب Docker/Compose روی سرور

```bash
apt-get update
apt-get install -y docker.io docker-compose-v2 ca-certificates curl
systemctl enable --now docker
```

## تنظیم Docker registry mirror

```bash
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.arvancloud.ir",
    "https://mirror-docker.runflare.com",
    "https://docker.iranserver.com",
    "https://registry.docker.ir"
  ]
}
EOF

systemctl restart docker
```

### افزایش تایم اوت

```bash
export DOCKER_CLIENT_TIMEOUT=600
export COMPOSE_HTTP_TIMEOUT=600
```

اگر باز هم timeout داد، IPv6 را موقتاً خاموش کن

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
systemctl restart docker
```

### pull کردن ایمیج‌های داکر

```bash
docker pull postgres:16-alpine
docker pull mattermost/mattermost-team-edition:latest
```

## ذخیره ایمیج‌ها داخل باندل

اول مطمئن بشیم ایمیج‌ها موجودند:

```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

بعد save:

```bash
docker save -o /opt/mattermost-offline-bundle/docker-images.tar \
  postgres:16-alpine \
  mattermost/mattermost-team-edition:latest
```

بررسی:

```bash
ls -lh /opt/mattermost-offline-bundle/docker-images.tar
```

## ساخت اسکریپت نصب

این نسخه هم `.list` و هم `.sources` را غیرفعال می‌کند، و repo را درست می‌شناسد.

```bash
cat > /opt/mattermost-offline-bundle/install-offline.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR="$(cd "$(dirname "$0")" && pwd)"
APT_REPO_DIR="$BUNDLE_DIR/apt-repo"
DOCKER_TAR="$BUNDLE_DIR/docker-images.tar"
COMPOSE_FILE="$BUNDLE_DIR/compose.yaml"

echo "[1/8] Sanity checks..."
test -d "$APT_REPO_DIR"
test -f "$COMPOSE_FILE"
test -f "$DOCKER_TAR"

echo "[2/8] Fix permissions for _apt sandbox..."
chmod 755 /opt /opt/mattermost-offline-bundle /opt/mattermost-offline-bundle/apt-repo || true
mkdir -p "$APT_REPO_DIR/partial"
chmod 755 "$APT_REPO_DIR/partial" || true

echo "[3/8] Configure APT to use offline repo (file:)..."
mkdir -p /etc/apt/sources.list.d
cat > /etc/apt/sources.list.d/offline-bundle.list <<EOL
deb [trusted=yes] file:$APT_REPO_DIR ./
EOL

echo "[4/8] Disable ALL online APT sources (.list and .sources)..."
mkdir -p /etc/apt/disabled-sources
find /etc/apt/sources.list.d -maxdepth 1 -type f \
  ! -name "offline-bundle.list" \
  -exec mv -v {} /etc/apt/disabled-sources/ \; 2>/dev/null || true

test -f /etc/apt/sources.list && mv -v /etc/apt/sources.list /etc/apt/disabled-sources/sources.list.bak 2>/dev/null || true

echo "[5/8] APT update from offline repo..."
apt-get update

echo "[6/8] Reinstall required packages from offline repo..."
DEBIAN_FRONTEND=noninteractive apt-get -y install --reinstall \
  docker.io docker-compose-v2 ca-certificates curl

systemctl enable --now docker

echo "[7/8] Load Docker images..."
docker load -i "$DOCKER_TAR"

echo "[8/8] Start Mattermost..."
cd "$BUNDLE_DIR"
docker compose -f "$COMPOSE_FILE" up -d

echo "Done."
EOF

chmod +x /opt/mattermost-offline-bundle/install-offline.sh
```

## تست کامل بودن باندل قبل از tar

```bash
cd /opt/mattermost-offline-bundle
ls -1 apt-repo/*.deb 2>/dev/null | wc -l
ls -lh apt-repo/Packages.gz
ls -lh docker-images.tar
```

اگر `docker-images.tar` وجود نداشت، یعنی دانلود ایمیج های داکر به درستی انجام نشده.
اگر `.deb` کم بود، یعنی دانلود پکیج ها به درستی انجام نشده.

## خروجی گرفتن tar نهایی

```bash
cd /opt
tar -czf mattermost-offline-bundle.tar.gz mattermost-offline-bundle
ls -lh /opt/mattermost-offline-bundle.tar.gz
```

## دانلود روی لپتاپ

```bash
scp -P PORT root@SERVER_IP:/opt/mattermost-offline-bundle.tar.gz .
```

خب. حالا یه فایل داریم که میتونیم بعدا ازش استفاده کنیم.

## انتقال فایل به سرور جدید

روی لپتاپ:

```bash
scp -P PORT mattermost-offline-bundle.tar.gz root@SERVER_IP:/root/
```

## بازکردن فایل روی سرور

```bash
ssh -p PORT root@SERVER_IP

cd /root
tar -xzf mattermost-offline-bundle.tar.gz
```

## انتقال باندل

```bash
mkdir -p /opt/mattermost-offline-bundle
rsync -a /root/mattermost-offline-bundle/ /opt/mattermost-offline-bundle/

chown -R root:root /opt/mattermost-offline-bundle
chmod 755 /opt
chmod -R a+rX /opt/mattermost-offline-bundle
```

از اینجا به بعد با `/opt/mattermost-offline-bundle` کار می‌کنیم.

## اصلاح apt-repo

برو داخل repo:

```bash
cd /opt/mattermost-offline-bundle/apt-repo
```

بررسی:

```bash
ls | grep Packages
```

### اگر فقط `Packages.gz` داری:

```bash
zcat Packages.gz > Packages
```

### اگر هیچ Packages نداری:

```bash
apt-get install -y apt-utils apt-ftparchive
apt-ftparchive packages . > Packages
gzip -kf Packages
```

## غیرفعال کردن همه سورس‌های اینترنتی

```bash
mkdir -p /etc/apt/disabled-sources

find /etc/apt/sources.list.d -maxdepth 1 -type f -name "*.sources" -exec mv {} /etc/apt/disabled-sources/ \;

find /etc/apt/sources.list.d -maxdepth 1 -type f -name "*.list" ! -name "offline-bundle.list" -exec mv {} /etc/apt/disabled-sources/ \;

test -f /etc/apt/sources.list && mv /etc/apt/sources.list /etc/apt/disabled-sources/
```

## تنظیم APT فقط روی file:

```bash
cat > /etc/apt/sources.list.d/offline-bundle.list <<EOF
deb [trusted=yes] file:/opt/mattermost-offline-bundle/apt-repo ./
EOF
```

پاکسازی کش:

```bash
apt-get clean
rm -rf /var/lib/apt/lists/*
```

## تست APT آفلاین

```bash
apt-get update
```

اگر فقط `file:/opt/...` دیدی و هیچ `http://ubuntu...` ندیدی، یعنی همه چی اوکیه.

## اجرای نصب آفلاین

برو به باندل:

```bash
cd /opt/mattermost-offline-bundle
chmod +x install-offline.sh
./install-offline.sh
ufw allow 8065
ufw reload
```

## تست نهایی

بررسی کانتینرها:

```bash
docker ps
```

باید ببینی:

```
mm-db
mm-app
```

تست HTTP:

```bash
curl -I http://127.0.0.1:8065
```

اگر 200 گرفتی، یعنی همه چی اوکیه.

## دسترسی از بیرون

در مرورگر:

```
http://SERVER_IP:8065
```

{{< edit >}}

# منابع {#references}
[Mattermost](https://mattermost.com/)
