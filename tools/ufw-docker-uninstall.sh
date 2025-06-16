#!/bin/bash
export LC_CTYPE=en_US.UTF-8

# Цвета для вывода
GREEN='\e[32m'
YELLOW='\e[33m'
NC='\e[0m'

echo -e "${YELLOW}Откат изменений ufw-docker...${NC}"

# Проверка наличия UFW
if ! command -v ufw &> /dev/null; then
    echo -e "${RED}UFW не установлен. Нечего откатывать.${NC}"
    exit 1
fi

# Удаляем специфичные правила (если они были)
sudo ufw route delete allow proto tcp from 10.10.10.0/24 to any port 51821
sudo ufw route delete allow proto tcp from 10.10.10.0/24 to any port 80

echo -e "${GREEN}Удалены ограничения на трафик от внутренней сети.${NC}"

# Разрешаем открытый доступ к 51821 и (опционально) 80
sudo ufw allow 51821/tcp
# sudo ufw allow 80/tcp  # раскомментируй, если нужен доступ к AGH

echo -e "${GREEN}Порт 51821 теперь открыт для всех. Осторожно!${NC}"

# Перезапуск UFW
sudo ufw disable
sudo ufw --force enable

echo -e "${GREEN}UFW перезапущен с новыми (более открытыми) правилами.${NC}"
