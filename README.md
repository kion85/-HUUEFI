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






#!/bin/bash
echo "🚀 Начало работы!"
echo "Текущая папка: $(pwd)"
echo ""

echo "📁 Содержимое папки:"
ls -la
echo ""

echo "🐍 Запускаю Python скрипт:"
python3 -c "print('Привет из Python!')"
echo ""

echo "✅ Готово!"












- пишем newhuuefi "имя файла например file"
- далее .e file.HUUEFI
- ставляем ранее код нажимаешь ctrl x и сохраняем
- удачи в использовании
