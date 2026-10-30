const COLORES = {
    fondo: "#070A12",
    tarjeta: "#111824",
    superficie: "#172033",
    borde: "#26324A",
    oro: "#D6B25E",
    oroOscuro: "#A9832F",
    blanco: "#F8FAFC",
    subtitulo: "#94A3B8",
    apagado: "#64748B",
};

export const escaparCorreo = (valor) =>
    String(valor ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");

export const codigoCorreo = (codigo) => `
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:6px 0 4px;">
    <tr>
        <td align="center" style="padding:22px 16px;background:${COLORES.superficie};border:1px solid ${COLORES.oroOscuro};border-radius:16px;">
            <span style="font-family:'Courier New',Courier,monospace;font-size:34px;font-weight:700;letter-spacing:10px;color:${COLORES.oro};">${codigo}</span>
        </td>
    </tr>
</table>`;

export const notaCorreo = (texto, color = COLORES.oro) => `
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:10px 0 24px;">
    <tr>
        <td style="padding:14px 16px;background:${COLORES.superficie};border-left:3px solid ${color};border-radius:0 12px 12px 0;font-family:'Segoe UI',Arial,sans-serif;font-size:13px;line-height:1.6;color:${COLORES.subtitulo};">
            ${texto}
        </td>
    </tr>
</table>`;

export const listaCorreo = (items) => `
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 20px;">
    ${items
        .map(
            (item) => `
    <tr>
        <td width="26" valign="top" style="padding:7px 0;font-family:Arial,sans-serif;font-size:15px;line-height:1.5;color:${COLORES.oro};">&#10022;</td>
        <td style="padding:7px 0;font-family:'Segoe UI',Arial,sans-serif;font-size:14px;line-height:1.55;color:${COLORES.subtitulo};">${item}</td>
    </tr>`
        )
        .join("")}
</table>`;

export const textoCorreo = (texto) =>
    `<p style="margin:0 0 16px;font-family:'Segoe UI',Arial,sans-serif;font-size:15px;line-height:1.65;color:${COLORES.subtitulo};">${texto}</p>`;

export const disenoCorreo = ({ titulo, contenido, nota = "", pie = "" }) => {
    const anio = new Date().getFullYear();

    return `<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Barber King</title>
</head>
<body style="margin:0;padding:0;background:${COLORES.fondo};">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:${COLORES.fondo};padding:32px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:${COLORES.tarjeta};border:1px solid ${COLORES.borde};border-radius:24px;overflow:hidden;">
                    <tr>
                        <td style="height:4px;background:${COLORES.oro};font-size:0;line-height:0;">&nbsp;</td>
                    </tr>
                    <tr>
                        <td align="center" style="padding:36px 36px 6px;">
                            <table role="presentation" cellpadding="0" cellspacing="0" align="center">
                                <tr>
                                    <td width="52" height="52" align="center" valign="middle" style="width:52px;height:52px;background:${COLORES.oro};border-radius:16px;font-family:Arial,sans-serif;font-size:26px;line-height:52px;color:${COLORES.fondo};">&#9986;</td>
                                </tr>
                            </table>
                            <div style="margin-top:14px;font-family:'Poppins','Segoe UI',Arial,sans-serif;font-size:20px;font-weight:800;letter-spacing:5px;color:${COLORES.blanco};">BARBER KING</div>
                            <div style="margin-top:6px;font-family:Arial,sans-serif;font-size:10px;letter-spacing:3px;color:${COLORES.oroOscuro};">CORTE &middot; ESTILO &middot; EXPERIENCIA</div>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" style="padding:22px 36px 0;">
                            <h1 style="margin:0;font-family:'Poppins','Segoe UI',Arial,sans-serif;font-size:26px;line-height:1.3;font-weight:700;color:${COLORES.blanco};">${titulo}</h1>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:22px 36px 8px;">${contenido}</td>
                    </tr>
                    ${nota ? `<tr><td style="padding:0 36px;">${nota}</td></tr>` : ""}
                    <tr>
                        <td style="padding:10px 36px 36px;">
                            <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="padding-top:18px;border-top:1px solid ${COLORES.borde};font-family:'Segoe UI',Arial,sans-serif;font-size:12px;line-height:1.6;color:${COLORES.apagado};text-align:center;">
                                        ${pie || "Recibes este correo porque tienes una cuenta en Barber King."}
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;">
                    <tr>
                        <td align="center" style="padding:18px 12px;font-family:Arial,sans-serif;font-size:11px;line-height:1.6;color:${COLORES.apagado};">
                            &copy; ${anio} Barber King. Todos los derechos reservados.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>`;
};
