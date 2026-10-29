const fs = require("fs");
const path = require("path");
const { W, H } = require("./sistema/tokens");
const pantallas = require("./pantallas");
const hoja = require("./sistema/hoja");

const salida = path.join(__dirname, "salida");
fs.mkdirSync(salida, { recursive: true });

fs.writeFileSync(
  path.join(salida, "00-sistema-diseno.svg"),
  `<svg xmlns="http://www.w3.org/2000/svg" width="${hoja.W}" height="${hoja.H}" viewBox="0 0 ${hoja.W} ${hoja.H}">${hoja.render()}</svg>`
);
console.log("✓ 00-sistema-diseno.svg — Sistema de diseño");

for (const pantalla of pantallas) {
  const archivo = path.join(salida, `${pantalla.id}.svg`);
  const alto = pantalla.alto || H;
  fs.writeFileSync(
    archivo,
    `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${alto}" viewBox="0 0 ${W} ${alto}">${pantalla.render()}</svg>`
  );
  console.log(`✓ ${pantalla.id}.svg — ${pantalla.nombre}`);
}

const tarjetas = pantallas
  .map(
    (p) => `    <figure>
      <img src="salida/${p.id}.svg" alt="${p.nombre}" width="${W}" height="${p.alto || H}">
      <figcaption><strong>${p.nombre}</strong><span>${p.rol}</span></figcaption>
    </figure>`
  )
  .join("\n");

const html = `<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>Barber King · Pantallas</title>
<style>
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body { margin: 0; padding: 48px 32px 64px; background: #070A12; font-family: Poppins, Arial, sans-serif; color: #F8FAFC; }
  header { max-width: 1320px; margin: 0 auto 36px; }
  h1 { margin: 0 0 6px; font-size: 28px; letter-spacing: -0.4px; }
  p { margin: 0; color: #94A3B8; font-size: 13px; }
  main { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 28px 24px; max-width: 1320px; margin: 0 auto; }
  figure { margin: 0; }
  img { display: block; width: 100%; height: auto; border-radius: 18px; border: 1px solid #26324A; background: #070A12; }
  figcaption { display: flex; justify-content: space-between; gap: 12px; padding: 12px 4px 0; font-size: 12px; }
  figcaption span { color: #D6B25E; }
  .sistema { max-width: 1320px; margin: 0 auto 44px; }
  .sistema img { display: block; width: 100%; height: auto; border-radius: 18px; border: 1px solid #26324A; }
  .sistema p { padding: 12px 4px 0; }
</style>
</head>
<body>
<header>
  <h1>Barber King · ${pantallas.length} pantallas</h1>
  <p>Mockups 390 × 844 · importar los SVG a Figma</p>
</header>
<section class="sistema">
  <img src="salida/00-sistema-diseno.svg" alt="Sistema de diseño">
  <p>Sistema de diseño · colores, tipografía y componentes</p>
</section>
<main>
${tarjetas}
</main>
</body>
</html>`;

fs.writeFileSync(path.join(__dirname, "index.html"), html);
console.log(`✓ index.html (${pantallas.length} pantallas)`);
