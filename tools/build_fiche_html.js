const fs = require("fs");
const md = fs.readFileSync("FICHES-VERIFICATION-APPS.md", "utf8");
const esc = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const inline = s => esc(s)
  .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
  .replace(/`(.+?)`/g, "<code>$1</code>")
  .replace(/^\[QUESTION\]/, '<span class="tag">QUESTION</span>');

const lines = md.split("\n");
let html = "", inList = false, inTable = false, section = 0, appOpen = false, toc = [];
const closeList = () => { if (inList) { html += "</ul>"; inList = false; } };
const closeTable = () => { if (inTable) { html += "</tbody></table>"; inTable = false; } };
const closeApp = () => { if (appOpen) { html += "</section>"; appOpen = false; } };

for (let i = 0; i < lines.length; i++) {
  const l = lines[i];
  if (/^\|/.test(l)) {
    closeList();
    if (/^\|[\s-|]+\|$/.test(l)) continue;
    const cells = l.split("|").slice(1, -1).map(c => inline(c.trim()));
    if (!inTable) { html += `<table><thead><tr>${cells.map(c => `<th>${c}</th>`).join("")}</tr></thead><tbody>`; inTable = true; }
    else html += `<tr>${cells.map(c => `<td>${c}</td>`).join("")}</tr>`;
    continue;
  }
  closeTable();
  if (/^---\s*$/.test(l)) { closeList(); continue; }
  let m;
  if ((m = l.match(/^# (.*)/))) {
    closeList(); closeApp();
    const t = m[1];
    if (/^\d+\.\s/.test(t) || /^0\.\s/.test(t)) {
      const id = "app" + (++section);
      const [, num, rest] = t.match(/^(\d+)\.\s(.*)$/);
      const [name, status] = rest.split(" — ");
      toc.push({ id, num, name, status });
      html += `<section class="app" id="${id}"><div class="apphead"><label class="check"><input type="checkbox" data-id="${id}"><span></span></label><div><div class="num">APP ${num}</div><h2>${inline(name)}</h2>${status ? `<div class="status">${inline(status)}</div>` : ""}</div></div>`;
      appOpen = true;
    } else if (i === 0) {
      html += `<header class="hero"><div class="kicker">Lost Phone · Campagne D84</div><h1>${inline(t.replace(/^FICHES DE VÉRIFICATION — /, "Fiches de vérification<br>"))}</h1></header>`;
    } else {
      html += `<h1 class="part">${inline(t)}</h1>`;
    }
    continue;
  }
  if ((m = l.match(/^## (.*)/))) {
    closeList();
    const t = m[1];
    if (/^\d+\.\s/.test(t)) {
      closeApp();
      const id = "app" + (++section);
      const [, num, rest] = t.match(/^(\d+)\.\s(.*)$/);
      const [name, ...st] = rest.split(" — ");
      const status = st.join(" — ");
      toc.push({ id, num, name, status });
      html += `<section class="app" id="${id}"><div class="apphead"><label class="check"><input type="checkbox" data-id="${id}"><span></span></label><div><div class="num">APP ${num}</div><h2>${inline(name)}</h2>${status ? `<div class="status">${inline(status)}</div>` : ""}</div></div>`;
      appOpen = true;
    } else html += `<h3>${inline(t)}</h3>`;
    continue;
  }
  if ((m = l.match(/^- (.*)/))) {
    if (!inList) { html += "<ul>"; inList = true; }
    html += `<li>${inline(m[1])}</li>`; continue;
  }
  closeList();
  if (!l.trim()) continue;
  if ((m = l.match(/^\*\*(.+?)\*\*\s*:?\s*(.*)$/)) && m[1].length < 40) {
    html += `<div class="axis"><span class="axislabel">${esc(m[1])}</span><p>${inline(m[2])}</p></div>`; continue;
  }
  html += `<p>${inline(l)}</p>`;
}
closeList(); closeTable(); closeApp();

const tocHtml = toc.map(t => `<a href="#${t.id}" data-toc="${t.id}"><span class="tn">${t.num}</span><span>${inline(t.name)}</span></a>`).join("");

const page = `<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Fiches de vérification — 28 apps</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--bg:#f4f5f7;--card:#fff;--ink:#111;--muted:#6b7280;--line:#e5e7eb;--blue:#0a84ff;--green:#34c759;--orange:#ff9f0a;--red:#ff3b30}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font-family:Inter,-apple-system,system-ui,sans-serif;font-size:16px;line-height:1.5;-webkit-font-smoothing:antialiased}
.wrap{max-width:820px;margin:0 auto;padding:0 18px 80px}
.hero{padding:40px 0 24px}.kicker{font-size:12px;font-weight:700;letter-spacing:.14em;text-transform:uppercase;color:var(--blue)}
.hero h1{font-size:34px;line-height:1.1;font-weight:800;margin:8px 0 0;letter-spacing:-.02em}
h1.part{font-size:14px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin:40px 0 12px;padding-top:24px;border-top:1px solid var(--line)}
h3{font-size:15px;font-weight:700;margin:20px 0 8px}
p{margin:6px 0}code{background:#eef0f3;padding:1px 6px;border-radius:6px;font-size:.9em}
ul{margin:6px 0 10px;padding-left:20px}li{margin:4px 0}li::marker{color:var(--blue)}
table{width:100%;border-collapse:collapse;background:var(--card);border-radius:14px;overflow:hidden;margin:10px 0 18px;font-size:14px;box-shadow:0 1px 2px rgba(0,0,0,.05)}
th,td{padding:10px 12px;text-align:left;border-bottom:1px solid var(--line);vertical-align:top}th{background:#fafafa;font-weight:600;color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.06em}tr:last-child td{border-bottom:0}
.toc{background:var(--card);border-radius:16px;padding:8px 4px;margin:18px 0 8px;box-shadow:0 1px 2px rgba(0,0,0,.05)}
.toc a{display:flex;align-items:center;gap:12px;padding:10px 14px;color:var(--ink);text-decoration:none;font-weight:500;border-radius:10px}.toc a:active{background:#f0f1f3}
.toc a.done{color:var(--muted);text-decoration:line-through}.toc .tn{width:28px;height:28px;border-radius:8px;background:#eef3ff;color:var(--blue);font-weight:700;font-size:13px;display:grid;place-items:center;flex:none}
.progress{position:sticky;top:0;z-index:5;background:rgba(244,245,247,.9);backdrop-filter:blur(10px);padding:10px 0;font-size:13px;font-weight:600;color:var(--muted)}
.bar{height:6px;background:var(--line);border-radius:3px;overflow:hidden;margin-top:6px}.bar i{display:block;height:100%;width:0;background:var(--green);transition:width .3s}
.app{background:var(--card);border-radius:18px;padding:18px 18px 8px;margin:14px 0;box-shadow:0 1px 2px rgba(0,0,0,.05);scroll-margin-top:70px}
.app.done{opacity:.55}.apphead{display:flex;gap:14px;align-items:flex-start;margin-bottom:6px}
.apphead h2{font-size:22px;margin:0;font-weight:800;letter-spacing:-.01em}.num{font-size:11px;font-weight:700;letter-spacing:.12em;color:var(--blue)}
.status{font-size:13px;color:var(--muted);margin-top:4px}
.check input{display:none}.check span{display:block;width:30px;height:30px;border-radius:10px;border:2px solid #cfd3d9;position:relative;flex:none;margin-top:6px}
.check input:checked+span{background:var(--green);border-color:var(--green)}.check input:checked+span::after{content:"";position:absolute;left:10px;top:5px;width:7px;height:13px;border:solid #fff;border-width:0 3px 3px 0;transform:rotate(45deg)}
.axis{margin:12px 0;padding:10px 12px;border-left:3px solid var(--blue);background:#f8faff;border-radius:0 10px 10px 0}.axis p{margin:2px 0 0;font-size:15px}
.axislabel{font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--blue)}
.tag{display:inline-block;background:#fff4e5;color:#b45309;font-size:11px;font-weight:700;padding:2px 8px;border-radius:999px;margin-right:6px}
.app .axis:nth-of-type(1){border-color:var(--blue)}
@media (max-width:480px){.hero h1{font-size:28px}.apphead h2{font-size:19px}body{font-size:15px}}
</style></head><body><div class="wrap">
${html.replace('<header class="hero">', '<header class="hero">').replace('</header>', `</header><div class="progress"><span id="pc">0 / ${toc.length} apps cochées</span><div class="bar"><i id="pb"></i></div></div><nav class="toc">${tocHtml}</nav>`)}
</div>
<script>
const K="lp-fiches-v1";let mem={};const store={get(){try{return JSON.parse(localStorage.getItem(K)||"{}")}catch(e){return mem}},set(v){mem=v;try{localStorage.setItem(K,JSON.stringify(v))}catch(e){}}};const st=store.get();
const boxes=[...document.querySelectorAll('input[type=checkbox]')];
function paint(){let n=0;boxes.forEach(b=>{const id=b.dataset.id;b.checked=!!st[id];if(b.checked)n++;document.getElementById(id).classList.toggle("done",b.checked);const t=document.querySelector('[data-toc="'+id+'"]');t&&t.classList.toggle("done",b.checked)});document.getElementById("pc").textContent=n+" / "+boxes.length+" apps cochées";document.getElementById("pb").style.width=(100*n/boxes.length)+"%"}
boxes.forEach(b=>b.addEventListener("change",()=>{st[b.dataset.id]=b.checked;store.set(st);paint()}));paint();
</script></body></html>`;
fs.writeFileSync("fiches-verification.html", page);
console.log("apps:", toc.length, "html:", page.length);
