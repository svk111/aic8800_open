#!/bin/sh
set +e

echo "[aic8800] === START ==="

# 1. Прошивки
echo "[aic8800] Copying firmware..."
cp -f /drv/fw/* /lib/firmware/ 2>/dev/null && echo "[aic8800] ✓ Firmware OK"

# 2. Очистка старых модулей
echo "[aic8800] Cleaning old modules..."
rmmod aic8800_fdrv 2>/dev/null || true
rmmod aic_load_fw 2>/dev/null || true
sleep 2

# 3. Загрузка модулей
echo "[aic8800] Loading kernel modules..."
insmod /drv/aic_load_fw.ko 2>&1 || true
sleep 1
insmod /drv/aic8800_fdrv.ko 2>&1 || true
sleep 3

# 4. 🔑 БИНДИНГ USB (полный nsenter + fallback)
echo "[aic8800] Attempting USB bind via host namespaces..."
nsenter --target 1 --mount --uts --ipc --net --pid -- \
  /bin/sh -c 'echo "368b 8d81" > /sys/bus/usb/drivers/aic8800_fdrv/new_id' 2>&1 || \
  echo "[aic8800] Note: nsenter blocked, try 'insmod new_id=0x368b,0x8d81' if bind fails"

sleep 4

# 5. Проверка
echo "[aic8800] Interfaces: $(ip link 2>/dev/null | grep -oE 'wlan[0-9]+|wl[a-z0-9]+' | head -1 || echo 'none')"
echo "[aic8800] === ALIVE ==="

# Держим контейнер запущенным
exec tail -f /dev/null
