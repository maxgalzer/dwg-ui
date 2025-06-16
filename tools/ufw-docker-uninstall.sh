#!/bin/bash
set -e

echo "=== Проверка статуса контейнера wg-easy ==="
if ! docker ps | grep -q wg-easy; then
  echo "❌ Контейнер wg-easy не запущен. Запускаем..."
  docker start wg-easy
else
  echo "✅ Контейнер wg-easy уже запущен."
fi

echo -e "\n=== Проверка проброса порта 51821 ==="
if ! docker inspect wg-easy | grep -q '"HostPort": "51821"'; then
  echo "❌ Порт 51821 не проброшен. Контейнер нужно пересоздать с параметром -p 51821:51821"
  exit 1
else
  echo "✅ Порт 51821 проброшен."
fi

echo -e "\n=== Проверка, слушает ли порт ==="
LISTEN_LINE=$(ss -tuln | grep ':51821' || true)
if [[ -z "$LISTEN_LINE" ]]; then
  echo "❌ Порт 51821 не слушается. Что-то не так с контейнером."
  exit 1
fi

if echo "$LISTEN_LINE" | grep -q '127.0.0.1'; then
  echo "⚠️  Порт слушается только на localhost. Интерфейс не доступен извне."
  echo "Нужно пересобрать контейнер с публичным пробросом порта (0.0.0.0:51821)"
  exit 1
else
  echo "✅ Порт слушается глобально: $(echo "$LISTEN_LINE")"
fi

echo -e "\n=== Проверка правил UFW ==="
if sudo ufw status | grep -q 51821; then
  echo "✅ Правило для порта 51821 уже существует."
else
  echo "🔧 Добавляем правило: sudo ufw allow 51821/tcp"
  sudo ufw allow 51821/tcp
fi

echo -e "\n=== Финальная проверка ==="
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "🎯 Если всё прошло успешно, теперь интерфейс wg-easy доступен по:"
echo "👉 http://$SERVER_IP:51821"
