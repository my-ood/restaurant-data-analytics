from pathlib import Path

def print_tree(root, prefix=''):
    for path in sorted(Path(root).iterdir()):
        if path.name.startswith('__'): continue
        if path.is_dir():
            print(f"{prefix}├── {path.name}/")
            print_tree(path, prefix + "│   ")
        else:
            print(f"{prefix}└── {path.name}")

print("models/")
print_tree("models", "├── ")
