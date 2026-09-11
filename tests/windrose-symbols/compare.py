import json
import os
from pathlib import Path

root = Path('results')
before = json.loads((root / 'baseline/payload.json').read_text())
after = json.loads((root / 'stripped/payload.json').read_text())
symbols = {p: v for p, v in before['files'].items()
           if Path(p).parent.as_posix() == 'R5/Binaries/Linux'
           and Path(p).suffix in ('.debug', '.sym')}
assert symbols, 'Baseline contained no symbols; cannot validate removal'
retained = {p: v for p, v in before['files'].items() if p not in symbols}
assert after['files'] == retained, 'Retained files differ or symbols remain'
assert before['symlinks'] == after['symlinks'], 'Payload symlinks changed'
assert before['payload_bytes'] - after['payload_bytes'] == sum(v['bytes'] for v in symbols.values())
sizes = {v: json.loads((root / v / 'image.json').read_text())[0]['Size'] for v in ('baseline', 'stripped')}
assert sizes['stripped'] < sizes['baseline'], 'Image did not shrink'
report = '# Windrose symbol comparison\n\n'
report += '| Measurement (bytes) | Baseline | Stripped | Saved |\n|---|---:|---:|---:|\n'
for label, a, b in [('Docker image, uncompressed', sizes['baseline'], sizes['stripped']),
                    ('Payload regular-file bytes', before['payload_bytes'], after['payload_bytes'])]:
    report += f'| {label} | {a} | {b} | {a-b} |\n'
report += '\nRemoved files:\n\n' + ''.join(f'- `{p}`: {v["bytes"]} bytes\n' for p, v in sorted(symbols.items()))
report += '\nPASS: all retained payload files have identical SHA-256 hashes; symlinks are identical.\n'
report += '\nPterodactyl server start, client connection, save/restart and image-switch tests are still pending.\n'
Path('comparison.md').write_text(report)
if os.getenv('GITHUB_STEP_SUMMARY'):
    with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as stream:
        stream.write(report)
print(report)
