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

# ==================== HUUEFI EXTENSION PRO ==================== #
# Продвинутая система для .HUUEFI файлов с детекцией и кэшированием

HUUEFI_CACHE_DIR="$HOME/.huuefi_cache"
mkdir -p "$HUUEFI_CACHE_DIR"

huuefi() {
    if [[ $# -eq 0 ]]; then
        echo "🌀 Использование: huuefi <file.HUUEFI> [аргументы]"
        echo "📁 Доступные .HUUEFI файлы:"
        lsd -la *.HUUEFI 2>/dev/null || echo "📭 Нет .HUUEFI файлов в текущей директории"
        return 1
    fi
    
    local file="$1"
    local absolute_path=$(realpath "$file" 2>/dev/null)
    
    if [[ ! -f "$file" && ! -f "$absolute_path" ]]; then
        echo "❌ Ошибка: Файл '$file' не найден!"
        echo "💡 Проверьте путь и наличие файла"
        return 1
    fi
    
    if [[ -f "$absolute_path" ]]; then
        file="$absolute_path"
    fi
    
    if [[ "$file" != *.HUUEFI ]]; then
        echo "❌ Ошибка: Файл должен иметь расширение .HUUEFI!"
        echo "💡 Переименуйте: mv '$file' '${file}.HUUEFI'"
        return 1
    fi

    echo "🔍 Анализ HUUEFI файла: $(basename "$file")"
    echo "📂 Путь: $(dirname "$file")"
    
    # Детекция режима с продвинутым анализом
    local mode=$(_huuefi_detect_mode "$file")
    local file_hash=$(sha256sum "$file" | cut -d' ' -f1)
    local cache_file="$HUUEFI_CACHE_DIR/$file_hash"
    
    echo "🎯 Режим: $mode"
    echo "📊 Размер: $(du -h "$file" | cut -f1)"
    echo "🆔 Хэш: ${file_hash:0:8}..."
    
    case "$mode" in
        "LIGHT")
            _huuefi_light_mode "$file" "$@"
            ;;
        "PRO_CPP")
            _huuefi_pro_mode "$file" "$cache_file" "$@"
            ;;
        "PRO_ASM")
            _huuefi_asm_mode "$file" "$cache_file" "$@"
            ;;
        "PRO_HYBRID")
            _huuefi_hybrid_mode "$file" "$cache_file" "$@"
            ;;
        *)
            echo "❌ Неизвестный режим или поврежденный файл!"
            return 1
            ;;
    esac
}

_huuefi_detect_mode() {
    local file="$1"
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    local second_line=$(sed -n '2p' "$file" 2>/dev/null)
    
    # Детекция по первовой строке и содержимому
    if [[ "$first_line" == "#!HUUEFI-PRO" ]]; then
        if grep -q "#include" "$file" || grep -q "using namespace" "$file"; then
            echo "PRO_CPP"
        elif grep -q "section .text" "$file" || grep -q "global _" "$file"; then
            echo "PRO_ASM"
        elif grep -q "asm(" "$file" || grep -q "__asm__" "$file"; then
            echo "PRO_HYBRID"
        else
            echo "PRO_CPP" # По умолчанию для PRO
        fi
    elif [[ "$first_line" == "#!/bin/bash" || "$first_line" == "#!/bin/sh" ]]; then
        echo "LIGHT"
    else
        # Автодетекция по содержимому
        if grep -q "#include" "$file" || grep -q "cout\|endl" "$file"; then
            echo "PRO_CPP"
        elif grep -q "mov\|eax\|int 0x80" "$file"; then
            echo "PRO_ASM"
        else
            echo "LIGHT" # По умолчанию
        fi
    fi
}

_huuefi_light_mode() {
    local file="$1"
    shift
    
    echo "🐧 LIGHT режим: Bash выполнение"
    echo "⏰ Запуск: $(date +%H:%M:%S)"
    echo "─"╌┄┈┉┉┈┄╌"─"╌┄┈┉┉┈┄╌"─"╌┄┈┉┉┈┄╌"─"
    
    local start_time=$(date +%s%N)
    bash "$file" "$@"
    local exit_code=$?
    local end_time=$(date +%s%N)
    
    local duration=$(( (end_time - start_time) / 1000000 ))
    echo "─"╌┄┈┉┉┈┄╌"─"╌┄┈┉┉┈┄╌"─"╌┄┈┉┉┈┄╌"─"
    echo "⏱️  Время выполнения: ${duration}ms"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "✅ Успешно завершено!"
    else
        echo "⚠️  Завершено с кодом ошибки: $exit_code"
    fi
    
    return $exit_code
}

_huuefi_pro_mode() {
    local file="$1"
    local cache_file="$2"
    shift 2
    
    echo "🔧 PRO режим: C++ компиляция"
    
    if [[ -f "$cache_file" && -x "$cache_file" ]]; then
        echo "📦 Использую кэшированную версию"
        "$cache_file" "$@"
        return $?
    fi
    
    local temp_dir=$(mktemp -d)
    local source_file="$temp_dir/source.cpp"
    local output_bin="$cache_file"
    
    # Извлекаем код (пропускаем первую строку если это HUUEFI-PRO)
    if [[ $(head -n 1 "$file") == "#!HUUEFI-PRO" ]]; then
        tail -n +2 "$file" > "$source_file"
    else
        cp "$file" "$source_file"
    fi
    
    echo "🔨 Компиляция C++ кода..."
    local compile_start=$(date +%s%N)
    
    if g++ -std=c++17 -O2 -o "$output_bin" "$source_file" -lstdc++fs 2>"$temp_dir/compile.log"; then
        local compile_end=$(date +%s%N)
        local compile_time=$(( (compile_end - compile_start) / 1000000 ))
        echo "✅ Успешно скомпилировано за ${compile_time}ms!"
        
        echo "🚀 Запуск программы..."
        "$output_bin" "$@"
        local exit_code=$?
    else
        echo "❌ Ошибка компиляции C++!"
        echo "📋 Лог ошибок:"
        cat "$temp_dir/compile.log"
        local exit_code=1
    fi
    
    rm -rf "$temp_dir"
    return $exit_code
}

_huuefi_asm_mode() {
    local file="$1"
    local cache_file="$2"
    shift 2
    
    echo "⚡ PRO режим: Pure ASM компиляция"
    
    if [[ -f "$cache_file" && -x "$cache_file" ]]; then
        echo "📦 Использую кэшированную версию"
        "$cache_file" "$@"
        return $?
    fi
    
    local temp_dir=$(mktemp -d)
    local source_file="$temp_dir/source.asm"
    local object_file="$temp_dir/source.o"
    
    # Извлекаем ASM код
    if [[ $(head -n 1 "$file") == "#!HUUEFI-PRO" ]]; then
        tail -n +2 "$file" > "$source_file"
    else
        cp "$file" "$source_file"
    fi
    
    echo "🔨 Ассемблирование..."
    
    if nasm -f elf64 -g "$source_file" -o "$object_file" 2>"$temp_dir/asm.log"; then
        if ld "$object_file" -o "$cache_file" 2>"$temp_dir/link.log"; then
            echo "✅ ASM успешно скомпилировано!"
            echo "🚀 Запуск программы..."
            "$cache_file" "$@"
            local exit_code=$?
        else
            echo "❌ Ошибка линковки ASM!"
            cat "$temp_dir/link.log"
            local exit_code=1
        fi
    else
        echo "❌ Ошибка ассемблирования!"
        cat "$temp_dir/asm.log"
        local exit_code=1
    fi
    
    rm -rf "$temp_dir"
    return $exit_code
}

_huuefi_hybrid_mode() {
    local file="$1"
    local cache_file="$2"
    shift 2
    
    echo "🎯 HYBRID режим: C++ с inline ASM"
    _huuefi_pro_mode "$file" "$cache_file" "$@"
}

newhuuefi() {
    if [[ $# -eq 0 ]]; then
        echo "🌀 Использование: newhuuefi <имя> [режим]"
        echo "   Режимы: light, pro-cpp, pro-asm, pro-hybrid"
        echo "   По умолчанию: light"
        return 1
    fi
    
    local filename="$1"
    local mode="${2:-light}"
    
    if [[ "$filename" != *.HUUEFI ]]; then
        filename="${filename}.HUUEFI"
    fi
    
    if [[ -f "$filename" ]]; then
        echo "❌ Файл '$filename' уже существует!"
        return 1
    fi
    
    case "$mode" in
        light|LIGHT)
            echo "🐧 Создаю LIGHT .HUUEFI файл"
            echo "#!/bin/bash" > "$filename"
            echo "# HUUEFI LIGHT mode - Bash script" >> "$filename"
            echo "# Created: $(date +"%Y-%m-%d %H:%M:%S")" >> "$filename"
            echo "" >> "$filename"
            echo "echo \"🚀 HUUEFI LIGHT режим работает!\"" >> "$filename"
            echo "echo \"Аргументы: \$@\"" >> "$filename"
            echo "echo \"Текущая папка: \$(pwd)\"" >> "$filename"
            echo "" >> "$filename"
            echo "# Добавьте ваши bash-команды ниже" >> "$filename"
            ;;
            
        pro-cpp|PRO-CPP)
            echo "🔧 Создаю PRO .HUUEFI файл (C++)"
            echo "#!HUUEFI-PRO" > "$filename"
            cat >> "$filename" << 'EOF'
// HUUEFI PRO режим - C++ с детекцией
// Компилируется в нативный бинарник

#include <iostream>
#include <vector>
#include <string>

using namespace std;

class HUUEFI_Program {
private:
    vector<string> args;
    
public:
    HUUEFI_Program(int argc, char* argv[]) {
        for (int i = 0; i < argc; ++i) {
            args.push_back(argv[i]);
        }
    }
    
    void run() {
        cout << "🚀 HUUEFI PRO C++ режим работает!" << endl;
        cout << "📊 Аргументов: " << args.size() - 1 << endl;
        cout << "💻 Платформа: ";
        
        // Детекция платформы через ASM
        #ifdef __linux__
            cout << "Linux x86_64" << endl;
        #elif _WIN32
            cout << "Windows" << endl;
        #else
            cout << "Unknown" << endl;
        #endif
        
        cout << "🕒 Время: " << __TIME__ << endl;
    }
    
    ~HUUEFI_Program() {
        cout << "✅ Программа завершена" << endl;
    }
};

int main(int argc, char* argv[]) {
    HUUEFI_Program program(argc, argv);
    program.run();
    
    // Inline ASM пример
    asm volatile (
        "mov $1, %%rax\n\t"
        "nop\n\t"
        : 
        : 
        : "%rax"
    );
    
    return 0;
}
EOF
            ;;
            
        pro-asm|PRO-ASM)
            echo "⚡ Создаю PRO .HUUEFI файл (Pure ASM)"
            echo "#!HUUEFI-PRO" > "$filename"
            cat >> "$filename" << 'EOF'
; HUUEFI PRO режим - Pure ASM
; NASM синтаксис

section .data
    hello db '🚀 HUUEFI Pure ASM режим работает!', 0xA
    hello_len equ $ - hello
    
    args_msg db '📊 Аргументов: ', 0
    args_len equ $ - args_msg

section .bss
    arg_count resb 1

section .text
    global _start

_start:
    ; Сохраняем количество аргументов
    pop rcx
    mov [arg_count], cl
    
    ; Выводим приветствие
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, hello
    mov rdx, hello_len
    syscall
    
    ; Выводим количество аргументов
    mov rax, 1
    mov rdi, 1
    mov rsi, args_msg
    mov rdx, args_len
    syscall
    
    ; Конвертируем число в ASCII и выводим
    mov al, [arg_count]
    dec al                      ; Убираем имя программы
    add al, '0'
    mov [arg_count], al
    
    mov rax, 1
    mov rdi, 1
    mov rsi, arg_count
    mov rdx, 1
    syscall
    
    ; Новая строка
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    ; Завершение программы
    mov rax, 60                 ; sys_exit
    xor rdi, rdi                ; код 0
    syscall

section .data
    newline db 0xA
EOF
            ;;
            
        pro-hybrid|PRO-HYBRID)
            echo "🎯 Создаю HYBRID .HUUEFI файл (C++ + ASM)"
            echo "#!HUUEFI-PRO" > "$filename"
            cat >> "$filename" << 'EOF'
// HUUEFI HYBRID режим - C++ с расширенным ASM

#include <iostream>
#include <cstdint>

using namespace std;

// ASM функции
extern "C" {
    uint64_t asm_get_timestamp();
    void asm_syscall(uint64_t code, uint64_t arg1, uint64_t arg2, uint64_t arg3);
}

class AdvancedHUUEFI {
private:
    int argc;
    char** argv;
    
public:
    AdvancedHUUEFI(int arg_count, char** arg_values) 
        : argc(arg_count), argv(arg_values) {}
    
    void demonstrate() {
        cout << "🎯 HUUEFI HYBRID режим запущен!" << endl;
        cout << "🔧 Аргументов: " << argc - 1 << endl;
        
        // Вызов ASM функции
        uint64_t timestamp = asm_get_timestamp();
        cout << "⏰ ASM timestamp: " << timestamp << endl;
        
        // Сложные вычисления
        perform_calculations();
    }
    
    void perform_calculations() {
        // Интенсивные вычисления с ASM вставками
        volatile double result = 0.0;
        
        for (int i = 0; i < 1000000; ++i) {
            // ASM вставка для быстрых вычислений
            asm volatile (
                "fldl %1\n\t"
                "fsin\n\t"
                "fstpl %0\n\t"
                : "=m" (result)
                : "m" (result)
            );
        }
        
        cout << "🧮 Результат вычислений: " << result << endl;
    }
};

int main(int argc, char* argv[]) {
    AdvancedHUUEFI program(argc, argv);
    program.demonstrate();
    return 0;
}

// ASM реализации
asm(
".global asm_get_timestamp\n"
"asm_get_timestamp:\n"
"    rdtsc\n"
"    shl $32, %rdx\n"
"    or %rdx, %rax\n"
"    ret\n"

".global asm_syscall\n"
"asm_syscall:\n"
"    mov %rcx, %r10\n"
"    mov %rdx, %r8\n"
"    mov %rsi, %r9\n"
"    mov %rdi, %rax\n"
"    syscall\n"
"    ret\n"
);
EOF
            ;;
            
        *)
            echo "❌ Неизвестный режим: $mode"
            return 1
            ;;
    esac
    
    chmod +x "$filename"
    echo "✅ Создан файл: $filename"
    echo "📏 Размер: $(du -h "$filename" | cut -f1)"
    echo "🚀 Запуск: huuefi $filename"
}

huuefi-batch() {
    if [[ $# -eq 0 ]]; then
        echo "🌀 Использование: huuefi-batch <файл1> <файл2> ..."
        return 1
    fi
    
    local converted=0
    local skipped=0
    
    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            echo "❌ Файл '$file' не найден, пропускаю..."
            ((skipped++))
            continue
        fi
        
        local huuefi_file="${file}.HUUEFI"
        if [[ -f "$huuefi_file" ]]; then
            echo "⚠️  Файл '$huuefi_file' уже существует, пропускаю..."
            ((skipped++))
            continue
        fi
        
        # Автодетекция типа файла
        if file "$file" | grep -q "C++ source"; then
            echo "#!HUUEFI-PRO" > "$huuefi_file"
            cat "$file" >> "$huuefi_file"
            echo "🔧 Создан PRO wrapper: $huuefi_file"
        elif file "$file" | grep -q "Bash script"; then
            echo "#!/bin/bash" > "$huuefi_file"
            cat "$file" >> "$huuefi_file"
            echo "🐧 Создан LIGHT wrapper: $huuefi_file"
        else
            echo "#!/bin/bash" > "$huuefi_file"
            echo "# Wrapped: $file" >> "$huuefi_file"
            echo "bash \"$(realpath "$file")\" \"\$@\"" >> "$huuefi_file"
            echo "📦 Создан базовый wrapper: $huuefi_file"
        fi
        
        chmod +x "$huuefi_file"
        ((converted++))
    done
    
    echo "✅ Готово! Создано: $converted, пропущено: $skipped"
}

huuefi-clean() {
    echo "🧹 Очистка кэша HUUEFI..."
    local cache_size=$(du -sh "$HUUEFI_CACHE_DIR" 2>/dev/null | cut -f1)
    rm -rf "$HUUEFI_CACHE_DIR"/*
    echo "✅ Кэш очищен (было: ${cache_size:-0B})"
}

huuefi-info() {
    echo "📊 HUUEFI System Information:"
    echo "═╌┄┈┉┉┈┄╌"═╌┄┈┉┉┈┄╌"═╌┄┈┉┉┈┄╌"═╌┄┈┉┉┈┄╌"═"
    echo "📁 Кэш: $HUUEFI_CACHE_DIR"
    echo "📏 Размер кэша: $(du -sh "$HUUEFI_CACHE_DIR" 2>/dev/null || echo "0B")"
    echo "🔧 Компиляторы:"
    which g++ >/dev/null 2>&1 && echo "   ✅ g++: $(g++ --version | head -n1)" || echo "   ❌ g++: не установлен"
    which nasm >/dev/null 2>&1 && echo "   ✅ nasm: $(nasm -v)" || echo "   ❌ nasm: не установлен"
    which ld >/dev/null 2>&1 && echo "   ✅ ld: GNU ld" || echo "   ❌ ld: не установлен"
}

# Автодополнение
_huuefi_autocomplete() {
    _files -g "*.HUUEFI"
}
compdef _huuefi_autocomplete huuefi

# Алиасы
alias .h='huuefi '
alias .n='newhuuefi '
alias .l='lsd -la *.HUUEFI 2>/dev/null || echo "📭 Нет .HUUEFI файлов"'
alias .e='nano '
alias .c='cat '
alias .clean='huuefi-clean'
alias .info='huuefi-info'

huuefi-help() {
    echo "🌈 HUUEFI EXTENSION COMMANDS:"
    echo "═╌┄┈┉┉┈┄╌═╌┄┈┉┉┈┄╌═╌┄┈┉┉┈┄╌═╌┄┈┉┉┈┄╌═"
    echo "  huuefi file.HUUEFI      - 🚀 Запустить HUUEFI файл"
    echo "  newhuuefi name [mode]   - 🛠️  Создать файл"
    echo "  huuefi-batch files      - 🔄 Создать обертки"
    echo "  huuefi-clean            - 🧹 Очистить кэш"
    echo "  huuefi-info             - 📊 Информация о системе"
    echo "  huuefi-help             - 📖 Справка"
    echo ""
    echo "📁 FILE MANAGEMENT ALIASES:"
    echo "  .l                     - 📋 Показать HUUEFI файлы"
    echo "  .e file.HUUEFI         - ✏️  Редактировать"
    echo "  .c file.HUUEFI         - 👀 Просмотреть"
    echo "  .h file.HUUEFI         - ⚡ Быстрый запуск"
    echo "  .clean                 - 🧹 Очистка кэша"
    echo "  .info                  - 📊 Информация"
    echo ""
    echo "🎯 РЕЖИМЫ РАБОТЫ:"
    echo "  🐧 LIGHT      - Bash скрипты"
    echo "  🔧 PRO-CPP    - C++ компиляция"
    echo "  ⚡ PRO-ASM    - Pure ASM"
    echo "  🎯 PRO-HYBRID - C++ с inline ASM"
    echo ""
    echo "💡 Автоматическая детекция режимов!"
    echo "   Система сама определит тип файла"
}

echo "🌀 HUUEFI PRO extension loaded! Type 'huuefi-help' for commands"
huuefi-info
