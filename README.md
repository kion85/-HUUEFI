(типо README)








- привет -
создал специально для тех кто любит сидеть в терминале
- скрипт работает к примеру что huuefi-help и к моему пример будет 




🌈 HUUEFI EXTENSION COMMANDS:



 
  huuefi file.HUUEFI      - 🚀 Запустить HUUEFI файл
  newhuuefi name          - 🛠️  Создать новый HUUEFI файл
  huuefi-batch file1 file2 - 🔄 Создать HUUEFI обертки
  huuefi-help             - 📖 Показать эту справку

📁 FILE MANAGEMENT:
  .l                     - 📋 Показать все HUUEFI файлы
  .e file.HUUEFI         - ✏️  Редактировать HUUEFI файл
  .c file.HUUEFI         - 👀 Просмотреть HUUEFI файл
  .h file.HUUEFI         - ⚡ Быстрый запуск (алиас)

💡 HUUEFI файлы работают в:
   🐧 Linux: ./file.HUUEFI или huuefi file.HUUEFI
   🪟 Windows: file.HUUEFI (через CMD или PowerShell) 
- где file указать имя HUUEFI 
- для виндовс сами делайте,я делают под линукс,т.к установлен дистрибутив (городо написал с уверенностью наверное)
- удачи,тк никого кто на винде сидит обидеть не хотел;(




- П.С-
- использует аналогию баша и пайтон скрипта  (иметь пайтон скрипт не обязательно)
- код к примеру
- #!/bin/bash
echo "🎮 Игровой HUUEFI лаунчер:"

# Выбор игры
echo "1. Minecraft"
echo "2. Counter-Strike 2" 
echo "3. Dota 2"

read -p "Выберите игру [1-3]: " choice

case $choice in
    1) minecraft-launcher & ;;
    2) steam steam://rungameid/730 & ;;  # CS2
    3) steam steam://rungameid/570 & ;;  # Dota 2
    *) echo "❌ Неверный выбор" ;;
esac 
- пишем newhuuefi "имя файла например file"
- далее .e file.HUUEFI
- ставляем ранее код нажимаешь cntr x и сохраняем
- удачи в использовании
