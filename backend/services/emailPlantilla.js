export const ASUNTO = "Código de recuperación";

export const contenido = (codigo) => ({
    text: `
Tu código de recuperación es:

${codigo}

Este código expira en 15 minutos.
`,
    html: `
<div style="font-family:Arial,sans-serif;max-width:600px;margin:auto;padding:20px;">
    <h2>Recuperación de contraseña</h2>
    <p>Has solicitado recuperar tu contraseña.</p>
    <p>Utiliza el siguiente código:</p>
    <div style="font-size:32px;font-weight:bold;letter-spacing:8px;padding:20px;background:#f5f5f5;text-align:center;border-radius:8px;">
        ${codigo}
    </div>
    <p style="margin-top:20px;">Este código expira en <strong>15 minutos</strong>.</p>
    <p>Si no solicitaste este cambio, puedes ignorar este mensaje.</p>
</div>
`,
});
