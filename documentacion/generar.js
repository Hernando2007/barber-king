// Genera las pantallas señalizadas del manual de usuario y exporta los tres PDF.
//
//   node documentacion/generar.js          -> solo las SVG anotadas
//   node documentacion/generar.js --pdf    -> además convierte los HTML a PDF
const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const RAIZ = path.resolve(__dirname, "..");
const SALIDA_FIGMA = path.join(RAIZ, "design", "figma", "salida");
const IMAGENES = path.join(__dirname, "imagenes");
const PDFS = path.join(__dirname, "pdf");
const EDGE =
  "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe";
const MARCAS = require("./marcas");

fs.mkdirSync(IMAGENES, { recursive: true });
fs.mkdirSync(PDFS, { recursive: true });

const imagenes = Object.keys(MARCAS);
for (const id of imagenes) {
  const origen = path.join(SALIDA_FIGMA, `${id}.svg`);
  if (!fs.existsSync(origen)) {
    console.error(`✗ Falta la pantalla ${id}.svg (ejecuta node design/figma/generar.js)`);
    process.exitCode = 1;
    continue;
  }
  const svg = fs.readFileSync(origen, "utf8");
  const alto = Number((svg.match(/height="(\d+)"/) || [])[1] || 844);
  const { anotaciones } = require(path.join(RAIZ, "design", "figma", "sistema", "anotaciones"));
  const capa = anotaciones(
    MARCAS[id].map(({ n, x, y, apunta }) => ({ n, x, y, apunta })),
    { alto }
  );
  fs.writeFileSync(path.join(IMAGENES, `${id}.svg`), svg.replace(/<\/svg>\s*$/, `${capa}</svg>`));
  console.log(`✓ ${id}.svg señalada (${MARCAS[id].length} pasos)`);
}

if (!process.argv.includes("--pdf")) {
  console.log("\nSin PDF (usa --pdf para convertir los manuales).");
  process.exit(process.exitCode || 0);
}

const manuales = ["manual-usuario", "manual-tecnico", "manual-instalacion"];
for (const nombre of manuales) {
  const html = path.join(__dirname, `${nombre}.html`);
  if (!fs.existsSync(html)) {
    console.error(`✗ No existe ${nombre}.html`);
    continue;
  }
  const destino = path.join(PDFS, `${nombre}.pdf`);
  try {
    execFileSync(
      EDGE,
      [
        "--headless=new",
        "--disable-gpu",
        "--no-first-run",
        `--user-data-dir=C:/Users/SISTEMAS/AppData/Local/Temp/bk-pdf-${nombre}-${Date.now()}`,
        "--no-pdf-header-footer",
        `--print-to-pdf=${destino}`,
        `file:///${html.replace(/\\/g, "/")}`,
      ],
      { timeout: 180000, stdio: "pipe" }
    );
    const kb = Math.round(fs.statSync(destino).size / 1024);
    console.log(`✓ ${nombre}.pdf (${kb} KB)`);
  } catch (error) {
    console.error(`✗ ${nombre}: ${String(error.stderr || error.message).slice(0, 300)}`);
    process.exitCode = 1;
  }
}
