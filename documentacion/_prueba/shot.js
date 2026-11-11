// Captura de control: convierte los SVG anotados a PNG para revisarlos a ojo.
const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const EDGE = "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe";
const SALIDA = "C:/barber-king/documentacion/_prueba/png";
fs.mkdirSync(SALIDA, { recursive: true });

const origenes = process.argv[2] || "C:/barber-king/design/figma/salida";
const ids = process.argv.slice(3);

for (const id of ids) {
  const svg = fs.readFileSync(path.join(origenes, `${id}.svg`), "utf8");
  const alto = Number((svg.match(/height="(\d+)"/) || [])[1] || 844);
  const html = path.join(SALIDA, `${id}.html`);
  fs.writeFileSync(
    html,
    `<body style="margin:0;background:#000"><img src="${path.join(origenes, id + ".svg").replace(/\\/g, "/")}" style="display:block;width:390px;height:${alto}px"></body>`
  );
  try {
    execFileSync(
      EDGE,
      [
        "--headless=new",
        "--disable-gpu",
        "--no-first-run",
        `--user-data-dir=C:/Users/SISTEMAS/AppData/Local/Temp/bk-shot-${Date.now()}`,
        `--window-size=390,${alto}`,
        "--hide-scrollbars",
        `--screenshot=C:/barber-king/documentacion/_prueba/png/${id}.png`,
        `file:///${html.replace(/\\/g, "/")}`,
      ],
      { timeout: 70000, stdio: "pipe" }
    );
    console.log("ok", id);
  } catch (error) {
    console.log("FALLO", id, String(error.stderr || error).slice(0, 200));
  }
}
