#!/usr/bin/env bash
# Выбор обоев через rofi -> палитра wallust -> заливка фона цветом из палитры
# Положи в ~/.local/bin/rofi-wall и сделай исполняемым: chmod +x

WALL_DIR="${WALL_DIR:-$HOME/Pictures/Wallpapers}"

# swww в новых версиях переименован в awww — поддерживаем оба варианта
SW=$(command -v swww || command -v awww)
DAEMON=$(command -v swww-daemon || command -v awww-daemon)

if [ -z "$SW" ]; then
    notify-send "rofi-wall" "swww/awww не найден"
    exit 1
fi

# Запускаем демон, если не запущен
pgrep -x "$(basename "$DAEMON")" >/dev/null || { "$DAEMON" & sleep 0.5; }

choice=$(
    find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.gif' -o -iname '*.webp' \) -printf '%P\n' | sort |
    while IFS= read -r f; do
        printf '%s\0icon\x1f%s/%s\n' "$f" "$WALL_DIR" "$f"
    done |
    rofi -dmenu -i -p "Обои" -show-icons \
        -theme-str 'window {width: 60%;} listview { columns: 5; lines: 2; } element { orientation: vertical; } element-icon { size: 10em; } element-text { enabled: false;} '
)

[ -z "$choice" ] && exit 0

# 1. Генерируем палитру и все шаблоны (rofi, mango, rootcolor и т.д.)
wallust run "$WALL_DIR/$choice"
gsettings set org.gnome.gedit.preferences.editor style-scheme-for-dark-theme-variant 'classic' && gsettings set org.gnome.gedit.preferences.editor style-scheme-for-dark-theme-variant 'wallust'

# 2. Заливаем фон сплошным цветом из палитры
"$SW" clear "$(cat ~/.cache/wallust/rootcolor)"

# 3. Применяем новые цвета в mangoWM
mmsg -d reload_config 2>/dev/null

# 4. Перезагрузка других программ (раскомментируй и подставь свои)
pkill -SIGUSR2 waybar 2>/dev/null
pkill -SIGUSR1 kitty 2>/dev/null
if pgrep -x nautilus >/dev/null; then
    nautilus -q
    sleep 0.5
    nautilus --new-window >/dev/null 2>&1 &
fi    
