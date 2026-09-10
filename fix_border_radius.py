import os

def fix_border_radius(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'BorderRadius.only' in content:
        # replace exactly
        content = content.replace('BorderRadius.only', 'BorderRadiusDirectional.only')
        content = content.replace('topLeft:', 'topStart:')
        content = content.replace('topRight:', 'topEnd:')
        content = content.replace('bottomLeft:', 'bottomStart:')
        content = content.replace('bottomRight:', 'bottomEnd:')
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed BorderRadius in {filepath}")

lib_dir = r'c:\Users\HP\Desktop\Flutter\doctor\lib'
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            fix_border_radius(os.path.join(root, file))
