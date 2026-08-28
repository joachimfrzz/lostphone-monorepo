#!/usr/bin/env python3
"""Moniteur tablette v2 : RELAIS du flux video MJPEG de SideTap/WDA (port 9100,
celui qui est fluide sur le PC) vers le reseau local, pour la tablette.
Lecture seule : ne fait que recopier le flux d'ecran, aucun controle possible.
Ecoute sur 0.0.0.0:8781 -> sur la tablette : http://192.168.1.25:8781
Fallback automatique : si le flux video ne passe pas sur le navigateur de la
tablette, la page bascule toute seule sur des captures 1x/seconde.
"""
import http.server, socketserver, socket, urllib.request, json, base64

MJPEG = ("127.0.0.1", 9100)   # flux video WDA (fluide)
WDA = "http://127.0.0.1:8100"  # fallback captures
PORT = 8781

PAGE = b"""<!doctype html><html><head><meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1">
<title>Moniteur Lost Phone</title>
<style>
  html,body{margin:0;background:#111;height:100%;display:flex;flex-direction:column;
    align-items:center;justify-content:center;font-family:system-ui;color:#8fef9f}
  #s{max-height:96vh;max-width:96vw;object-fit:contain;border-radius:18px;
    box-shadow:0 0 40px #000;background:#000}
  #t{position:fixed;top:8px;left:8px;font-size:12px;opacity:.7}
</style></head><body>
<div id=t>surveillance directe (lecture seule) - flux video</div>
<img id=s src="/stream">
<script>
  // Si le flux video ne demarre pas en 6s (navigateur incompatible MJPEG),
  // on bascule sur des captures rafraichies chaque seconde.
  const img=document.getElementById('s'), t=document.getElementById('t');
  let ok=false, poll=null;
  img.addEventListener('load',()=>{ok=true});
  function fallback(){
    if(ok||poll)return;
    t.textContent='surveillance directe (lecture seule) - mode captures ~1 img/s';
    poll=setInterval(()=>{img.src='/shot?'+Date.now()},1000);
  }
  img.addEventListener('error',fallback);
  setTimeout(fallback,6000);
</script></body></html>"""


class H(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.0"
    def log_message(self, *a): pass

    def do_GET(self):
        if self.path.startswith("/stream"):
            self.relay_stream()
        elif self.path.startswith("/shot"):
            self.one_shot()
        else:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(PAGE)

    def relay_stream(self):
        """Recopie brute du flux MJPEG 9100 vers le client."""
        try:
            s = socket.create_connection(MJPEG, timeout=8)
        except Exception:
            self.send_response(503); self.end_headers(); return
        try:
            s.sendall(b"GET / HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: keep-alive\r\n\r\n")
            s.settimeout(15)
            first = s.recv(65536)
            if not first:
                self.send_response(503); self.end_headers(); return
            if first.startswith(b"HTTP/1."):
                # Le serveur MJPEG parle deja HTTP : on retransmet tel quel.
                self.wfile.write(first)
            else:
                # Flux brut : on fabrique l'en-tete HTTP multipart nous-memes.
                self.wfile.write(
                    b"HTTP/1.0 200 OK\r\n"
                    b"Content-Type: multipart/x-mixed-replace; boundary=--BoundaryString\r\n"
                    b"Cache-Control: no-store\r\nConnection: close\r\n\r\n")
                self.wfile.write(first)
            while True:
                data = s.recv(65536)
                if not data:
                    break
                self.wfile.write(data)
        except Exception:
            pass
        finally:
            try: s.close()
            except Exception: pass

    def one_shot(self):
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


socketserver.ThreadingTCPServer.allow_reuse_address = True
socketserver.ThreadingTCPServer.daemon_threads = True
print(f"Moniteur v2 pret (relais flux video).")
print(f"Sur la tablette : http://192.168.1.25:{PORT}")
with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), H) as httpd:
    httpd.serve_forever()
