# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=( 
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# ==================== HUUEFI EXTENSION CONFIG ===================#
# Ваше собственное расширение .HUUEFI для универсальных скриптов
# ================================================================#

# Функция для запуска HUUEFI файлов

huuefi() {
    if [[ $# -eq 0 ]]; then
        echo "🌀 Использование: huuefi <file.HUUEFI> [аргументы]"
        echo "📁 Доступные .HUUEFI файлы:"
        lsd -la *.HUUEFI 2>/dev/null || echo "📭 Нет .HUUEFI файлов"
        return 1
    fi
    
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Ошибка: Файл '$file' не найден!"
        return 1
    fi
    
    if [[ "$file" != *.HUUEFI ]]; then
        echo "❌ Ошибка: Файл должен иметь расширение .HUUEFI!"
        return 1
    fi
    
    bash "$@"
}

newhuuefi() {
    if [[ $# -eq 0 ]]; then
        echo "🌀 Использование: newhuuefi <имя_файла>"
        return 1
    fi
    
    local filename="$1"
    if [[ "$filename" != *.HUUEFI ]]; then
        filename="${filename}.HUUEFI"
    fi
    
    if [[ -f "$filename" ]]; then
        echo "❌ Ошибка: Файл '$filename' уже существует!"
        return 1
    fi
    
    touch "$filename"
    chmod +x "$filename"
    echo "✅ Создан пустой файл: $filename"
}

huuefi-batch() {
    if [[ $# -eq 0 ]]; then
        echo "🌀 Использование: huuefi-batch <файл1> <файл2> ..."
        return 1
    fi
    
    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            echo "❌ Файл '$file' не найден, пропускаю..."
            continue
        fi
        
        local huuefi_file="${file}.HUUEFI"
        if [[ -f "$huuefi_file" ]]; then
            echo "⚠️  Файл '$huuefi_file' уже существует, пропускаю..."
            continue
        fi
        
        echo "#!/bin/bash" > "$huuefi_file"
        echo "bash \"$(realpath "$file")\" \"\$@\"" >> "$huuefi_file"
        chmod +x "$huuefi_file"
        echo "✅ Создан HUUEFI wrapper: $huuefi_file"
    done
}

_huuefi_autocomplete() {
    _files -g "*.HUUEFI"
}

compdef _huuefi_autocomplete huuefi

alias .h='huuefi '
alias .n='newhuuefi '
alias .l='lsd -la *.HUUEFI 2>/dev/null || echo "📭 Нет .HUUEFI файлов"'
alias .e='nano '
alias .c='cat '

huuefi-help() {
    echo "🌈 HUUEFI EXTENSION COMMANDS:"
    echo "═╌┄┈┉┉┈┄╌═╌┄┈┉┉┈┄╌═╌┄┈┉┉┈┄╌═╌┄┈┉┉┈┄╌═"
    echo "  huuefi file.HUUEFI      - 🚀 Запустить HUUEFI файл"
    echo "  newhuuefi name          - 🛠️  Создать новый HUUEFI файл"
    echo "  huuefi-batch file1 file2 - 🔄 Создать HUUEFI обертки"
    echo "  huuefi-help             - 📖 Показать эту справку"
    echo ""
    echo "📁 FILE MANAGEMENT:"
    echo "  .l                     - 📋 Показать все HUUEFI файлы"
    echo "  .e file.HUUEFI         - ✏️  Редактировать HUUEFI файл"
    echo "  .c file.HUUEFI         - 👀 Просмотреть HUUEFI файл"
    echo "  .h file.HUUEFI         - ⚡ Быстрый запуск (алиас)"
    echo ""
    echo "💡 HUUEFI файлы работают в:"
    echo "   🐧 Linux: ./file.HUUEFI или huuefi file.HUUEFI"
    echo "   🪟 Windows: file.HUUEFI (через CMD или PowerShell)"
}

echo "🌀 HUUEFI extension loaded! Type 'huuefi-help' for commands"
