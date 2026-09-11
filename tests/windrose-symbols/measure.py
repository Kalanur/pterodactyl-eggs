"""Run inside the test image; record logical payload bytes and retained hashes."""
import hashlib
import json
import os
from pathlib import Path

root = Path('/opt/windrose')
files, links = {}, {}
for folder, directories, names in os.walk(root, followlinks=False):
    for name in directories + names:
        path = Path(folder) / name
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            links[relative] = os.readlink(path)
        elif path.is_file():
            with path.open('rb') as stream:
                digest = hashlib.file_digest(stream, 'sha256').hexdigest()
            files[relative] = {'bytes': path.stat().st_size, 'sha256': digest}
print(json.dumps({'payload_bytes': sum(x['bytes'] for x in files.values()),
                  'files': files, 'symlinks': links}, sort_keys=True))
