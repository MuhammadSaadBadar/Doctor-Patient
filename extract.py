import os
import re

def extract_strings_from_files(directory):
    strings = set()
    string_pattern = re.compile(r"'([^']*)'")
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                    matches = string_pattern.findall(content)
                    for match in matches:
                        # Filter out basic non-UI strings
                        if len(match) > 2 and ' ' in match and not match.startswith('package:') and not match.startswith('/'):
                            strings.add(match)
    return sorted(list(strings))

screens_dir = r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\appointments\screens'
strings = extract_strings_from_files(screens_dir)
for s in strings:
    print(s)
