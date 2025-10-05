#!/bin/bash
# Script to fix Unicode/UTF-8 display in bash on Linux servers
# This fixes the escaped character display like $'\320\236...'

echo "🔧 Fixing Unicode/UTF-8 display in bash..."

# Backup existing bashrc
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up existing ~/.bashrc"
fi

# Add Unicode configuration to bashrc
cat >> ~/.bashrc << 'EOF'

# Unicode/UTF-8 Configuration for proper character display
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LESSCHARSET=utf-8
export TERM=xterm-256color

# Better ls aliases for Unicode support
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Force UTF-8 for specific commands if needed
alias lsu='LC_ALL=en_US.UTF-8 ls -la'

# Enable better glob patterns
shopt -s globstar 2>/dev/null

EOF

echo "✅ Added Unicode configuration to ~/.bashrc"

# Check if locales are generated
echo "🔍 Checking available locales..."
if ! locale -a | grep -q "en_US.utf8\|en_US.UTF-8"; then
    echo "⚠️  en_US.UTF-8 locale not found. Generating..."
    
    # For Debian/Ubuntu systems
    if command -v locale-gen >/dev/null 2>&1; then
        sudo locale-gen en_US.UTF-8
        echo "✅ Generated en_US.UTF-8 locale"
    else
        echo "❌ locale-gen not found. You may need to install locales package:"
        echo "   sudo apt-get update && sudo apt-get install -y locales"
    fi
else
    echo "✅ en_US.UTF-8 locale is available"
fi

# Update system locale
if [ -f /etc/default/locale ]; then
    sudo cp /etc/default/locale /etc/default/locale.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up /etc/default/locale"
fi

sudo tee /etc/default/locale > /dev/null << 'EOF'
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

echo "✅ Updated system-wide locale settings"

# Test Unicode support
echo ""
echo "🧪 Testing Unicode display..."
echo "Test string: Тест файл Дубляж Оригинал субтитры"
printf "Unicode codepoints: \u0422\u0435\u0441\u0442 \u0444\u0430\u0439\u043b\n"

# Create test file to verify
touch "Тест_файл_Unicode.txt"
echo "✅ Created test file: Тест_файл_Unicode.txt"

echo ""
echo "🎯 Configuration complete! Please:"
echo "   1. Run: source ~/.bashrc"
echo "   2. Or restart your SSH session"
echo "   3. Test with: ls -la Тест*"
echo ""
echo "Expected result: Files should display with proper Cyrillic characters"
echo "Instead of: \$'\\320\\242\\320\\265\\321\\201\\321\\202'..."

# Show current locale status
echo ""
echo "📊 Current locale status:"
locale