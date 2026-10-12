#!/bin/bash
# Wi-Fi меню для rofi на базе NetworkManager (nmcli)

term="kitty"   # терминал для nmtui

wifi_on=false
[ "$(nmcli radio wifi)" = "enabled" ] && wifi_on=true

if $wifi_on; then toggle="Выключить Wi-Fi"; else toggle="Включить Wi-Fi"; fi

labels=("$toggle" "Открыть nmtui")
ssids=("" "")
secs=("" "")

if $wifi_on; then
  nmcli device wifi rescan 2>/dev/null
  declare -A seen
  while IFS=: read -r inuse signal sec ssid; do
    [ -z "$ssid" ] && continue
    [ -n "${seen[$ssid]}" ] && continue
    seen[$ssid]=1
    mark="  "; [ "$inuse" = "*" ] && mark="* "
    lock=""; [ -n "$sec" ] && lock="  (пароль)"
    labels+=("${mark}${ssid}  ${signal}%${lock}")
    ssids+=("$ssid")
    secs+=("$sec")
  done < <(nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID device wifi list)
fi

idx=$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i -format i -p "")
[ -z "$idx" ] && exit 0

case "$idx" in
  0)
    if $wifi_on; then nmcli radio wifi off; else nmcli radio wifi on; fi
    ;;
  1)
    exec $term -e nmtui
    ;;
  *)
    ssid="${ssids[$idx]}"
    sec="${secs[$idx]}"

    # Если сеть уже сохранена, подключаемся без пароля
    if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
      out=$(nmcli connection up id "$ssid" 2>&1)
    elif [ -n "$sec" ]; then
      pass=$(rofi -dmenu -password -p "Пароль" -theme-str 'listview { lines: 0; }')
      [ -z "$pass" ] && exit 0
      out=$(nmcli device wifi connect "$ssid" password "$pass" 2>&1)
    else
      out=$(nmcli device wifi connect "$ssid" 2>&1)
    fi

    if [ $? -eq 0 ]; then
      command -v notify-send >/dev/null && notify-send "Wi-Fi" "Подключено: $ssid"
    else
      command -v notify-send >/dev/null && notify-send "Wi-Fi" "Не удалось подключиться: $out"
    fi
    ;;
esac
