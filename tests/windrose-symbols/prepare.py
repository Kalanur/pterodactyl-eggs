"""Prepare a pinned test Dockerfile from the unmodified yolks#79 snapshot."""
import sys
from pathlib import Path

variant = sys.argv[1]
assert variant in ('baseline', 'stripped')
runtime = Path(__file__).parent / 'runtime'
text = (runtime / 'Dockerfile').read_text()
text = text.replace('debian:trixie-slim\n', 'debian:trixie-slim@sha256:d7e12182ce18b85b93007c1dedf31f2d29e01ccf3182cc4017c709b6259bc132\n')
if variant == 'stripped':
    anchor = ' AS windrose-upstream\n'
    assert text.count(anchor) == 1
    text = text.replace(anchor, anchor + '\nUSER root\n'
        '# Remove symbols before COPY so they never enter a runtime image layer.\n'
        'RUN rm -f /home/ue_user/app/R5/Binaries/Linux/*.debug \\\n'
        '    /home/ue_user/app/R5/Binaries/Linux/*.sym\n')
(runtime / 'Dockerfile.test').write_text(text)
