#!/bin/bash
yum update -y
cat > /opt/app.py <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello from the App Tier on 8080")
HTTPServer(("", 8080), H).serve_forever()
PY
nohup python3 /opt/app.py &
