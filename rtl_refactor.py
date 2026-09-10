import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # 1. Alignment to AlignmentDirectional
    alignment_map = {
        r'Alignment\.centerLeft': r'AlignmentDirectional.centerStart',
        r'Alignment\.centerRight': r'AlignmentDirectional.centerEnd',
        r'Alignment\.topLeft': r'AlignmentDirectional.topStart',
        r'Alignment\.topRight': r'AlignmentDirectional.topEnd',
        r'Alignment\.bottomLeft': r'AlignmentDirectional.bottomStart',
        r'Alignment\.bottomRight': r'AlignmentDirectional.bottomEnd',
    }
    for old, new in alignment_map.items():
        content = re.sub(old, new, content)

    # 2. EdgeInsets.only
    # Find all EdgeInsets.only(...) calls
    def edge_insets_replacer(match):
        args = match.group(1)
        if 'left:' in args or 'right:' in args:
            args = args.replace('left:', 'start:').replace('right:', 'end:')
            return f"EdgeInsetsDirectional.only({args})"
        return match.group(0)

    content = re.sub(r'EdgeInsets\.only\(([^)]*)\)', edge_insets_replacer, content)

    # 3. BorderRadius.only
    # Only in chat_bubble.dart to be safe, but can do broadly.
    if 'chat_bubble.dart' in filepath or 'BorderRadius.only' in content:
        def border_radius_replacer(match):
            args = match.group(1)
            if any(k in args for k in ['topLeft:', 'topRight:', 'bottomLeft:', 'bottomRight:']):
                args = args.replace('topLeft:', 'topStart:')
                args = args.replace('topRight:', 'topEnd:')
                args = args.replace('bottomLeft:', 'bottomStart:')
                args = args.replace('bottomRight:', 'bottomEnd:')
                return f"BorderRadiusDirectional.only({args})"
            return match.group(0)
            
        content = re.sub(r'BorderRadius\.only\(([^)]*)\)', border_radius_replacer, content)

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

lib_dir = r'c:\Users\HP\Desktop\Flutter\doctor\lib'
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
