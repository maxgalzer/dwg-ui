#!/bin/bash
set -e

PORT=51821

echo "🔓 Открываем порт $PORT для всего мира..."

# Разрешаем входящий трафик
sudo ufw allow $PORT/tcp
sudo ufw route allow proto tcp from any to any port $PORT
sudo ufw route allow in on any to any port $PORT proto tcp

# Применяем изменения
echo "♻️ Перезапускаем ufw..."
sudo ufw disable
sudo ufw --force enable

# Показываем IP
echo -e "\n🌍 Публичный IP:"
IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
echo "👉 http://$IP:$PORT"

# Проверка — слушается ли порт
echo -e "\n🎧 Проверяем, слушает ли порт:"
ss -tuln | grep ":$PORT" || echo "❌ Порт не слушается. Проверь wg-easy."

# Статус UFW
echo -e "\n🧱 Текущие правила UFW:"
sudo ufw status verbose

echo -e "\n✅ Всё готово. Пробуй открыть интерфейс в браузере: http://$IP:$PORT"
