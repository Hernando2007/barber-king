"""Utilidades comunes para generar las marcas del logo de Barber King."""

import os

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
APP = os.path.join(RAIZ, "frontend", "barber_king_app")
RES = os.path.join(APP, "android", "app", "src", "main", "res")
LOGO_FUENTE = os.path.join(RAIZ, "design", "logo", "original.png")

NEGRO = (10, 12, 18)
BLANCO = (248, 250, 252)
DORADO = (214, 178, 94)
FONDO = (255, 255, 255)

DENSIDADES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}

ADAPTATIVO = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}

RUTA = 256


def marca(color):
    """Recorta el logo y lo devuelve como marca RGBA del color dado."""
    from PIL import Image

    gris = Image.open(LOGO_FUENTE).convert("L")

    lut = [
        0 if p >= 245 else min(255, int((245 - p) * 255 / 200))
        for p in range(RUTA)
    ]
    recortada = gris.point(lut, "L").getbbox()
    alpha = gris.point(lut, "L").crop(recortada)

    salida = Image.new("RGBA", alpha.size, color + (0,))
    salida.putalpha(alpha)
    return salida


def lienzo(tamano, relleno, color, fondo=None):
    """Dibuja la marca centrada dentro de un lienzo cuadrado."""
    from PIL import Image

    simbolo = marca(color)
    relacion = (tamano * (1 - relleno)) / max(simbolo.size)
    nuevo = simbolo.resize(
        (
            max(1, int(simbolo.width * relacion)),
            max(1, int(simbolo.height * relacion)),
        ),
        Image.LANCZOS,
    )

    canvas = Image.new("RGBA", (tamano, tamano), fondo or (0, 0, 0, 0))
    canvas.paste(
        nuevo,
        ((tamano - nuevo.width) // 2, (tamano - nuevo.height) // 2),
        nuevo,
    )
    return canvas


def guardar(imagen, ruta, solido=False):
    from PIL import Image

    os.makedirs(os.path.dirname(ruta), exist_ok=True)

    if solido:
        fondo = Image.new("RGB", imagen.size, FONDO)
        fondo.paste(imagen.convert("RGBA"), (0, 0), imagen.convert("RGBA"))
        fondo.save(ruta, "PNG", optimize=True)
    else:
        imagen.save(ruta, "PNG", optimize=True)

    return ruta
