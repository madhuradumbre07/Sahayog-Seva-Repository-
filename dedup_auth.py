# -*- coding: utf-8 -*-
import re

path = r'c:\Users\Saakshi18\OneDrive\Desktop\Saakshi\Flutter\lib\l10n\auth_strings.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
current_lang = None
seen_keys_for_lang = set()

for line in lines:
    m_lang = re.match(r"\s*'([a-z]{2})':\s*\{", line)
    if m_lang:
        current_lang = m_lang.group(1)
        seen_keys_for_lang = set()
        new_lines.append(line)
        continue
    
    m_key = re.match(r"\s*'([a-zA-Z0-9_]+)':", line)
    if m_key and current_lang:
        key = m_key.group(1)
        if key in seen_keys_for_lang:
            # Skip duplicate key line
            continue
        seen_keys_for_lang.add(key)
        new_lines.append(line)
    else:
        new_lines.append(line)

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Successfully deduplicated auth_strings.dart keys!")
