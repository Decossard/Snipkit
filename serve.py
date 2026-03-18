import os
import sys

os.chdir('/Users/hyaaddecossard/Documents/Claude Code/snipkit/build/web')

from http.server import HTTPServer, SimpleHTTPRequestHandler

port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
print(f'Serving on http://localhost:{port}', flush=True)
HTTPServer(('', port), SimpleHTTPRequestHandler).serve_forever()
