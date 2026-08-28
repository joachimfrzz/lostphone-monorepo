#!/usr/bin/env python3
"""Moniteur leger pour tablette : sert une page web qui affiche l'ecran de l'iPhone,
rafraichi ~1x/seconde (leger, contrairement au flux MJPEG brut). Lecture seule :
il ne fait que RELAYER les captures de WDA (loopback), aucun controle possible depuis ici.
Ecoute sur 0.0.0.0:8781 -> accessible depuis la tablette sur le meme Wi-Fi.
"""
import http.server, socketserver, urllib.request, json, base64

WDA = "http://127.0.0.1:8100"
PORT = 8781

PAGE = b"""<!doctype html><html><head><meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1">
<title>Moniteur Lost Phone</title>
<style>
  html,body{margin:0;background:#111;height:100%;display:flex;flex-direction:column;
    align-items:center;justify-content:center;font-family:system-ui;color:#8fef9f}
  #s{max-height:96vh;max-width:96vw;object-fit:contain;border-radius:18px;
    box-shadow:0 0 40px #000}
  #t{position:fixed;top:8px;left:8px;font-size:12px;opacity:.7}
</style></head><body>
<div id=t>surveillance en direct (lecture seule) - ~1 img/s</div>
<img id=s src="/shot">
<script>
  const img=document.getElementById('s');
  setInterval(()=>{img.src='/shot?'+Date.now()},1000);
</script></body></html>"""

class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        if self.path.startswith("/shot"):
            try:
                r = urllib.request.urlopen(WDA + "/screenshot", timeout=10)
                png = base64.b64decode(json.loads(r.read().decode())["value"])
                self.send_response(200)
                self.send_header("Content-Type", "image/png")
                self.send_header("Cache-Control", "no-store")
                self.end_headers()
                self.wfile.write(png)
            except Exception as e:
                self.send_response(503); self.end_headers()
                try: self.wfile.write(str(e).encode())
                except Exception: pass
        else:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(PAGE)

socketserver.ThreadingTCPServer.allow_reuse_address = True
print(f"Moniteur pret. Sur la tablette, ouvre : http://<IP-du-PC>:{PORT}")
print(f"(IP du PC vue tout a l'heure : 192.168.1.25 -> http://192.168.1.25:{PORT})")
with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), H) as httpd:
    httpd.serve_forever()
