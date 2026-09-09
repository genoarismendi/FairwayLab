import pyautogui
import time

# ===== CONFIG =====
DELAY_BEFORE_START = 5      # segundos para volver a la app
DELAY_BETWEEN_KEYS = 0.15   # velocidad de escritura
DELAY_AFTER_VALUE = 0.2     # pequeña pausa después de cada número
# ===================

print(f"Starting in {DELAY_BEFORE_START} seconds...")
time.sleep(DELAY_BEFORE_START)

with open("scores.txt", "r") as f:
    values = [line.strip() for line in f if line.strip()]

print(f"Typing {len(values)} values...")

for value in values:
    # Escribir número
    pyautogui.write(value, interval=DELAY_BETWEEN_KEYS)
    time.sleep(DELAY_AFTER_VALUE)

    # Tap para ir al siguiente campo
    pyautogui.press("tab")  # <-- Si TAB funciona en tu UI
    # Si no funciona TAB, comenta esa línea y usa click:
    # pyautogui.click()

print("Done.")