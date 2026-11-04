"""Marcas que se entregan dentro de la app, los correos y el paquete de Figma."""

import os

from logo.base import APP, BLANCO, DORADO, NEGRO, RAIZ, guardar, lienzo

CORREO = os.path.join(RAIZ, "backend", "public")
FIGMA = os.path.join(RAIZ, "design", "figma", "marca")

VARIANTES = {"negro": NEGRO, "blanco": BLANCO, "dorado": DORADO}


def marca_app():
    for nombre, color in VARIANTES.items():
        guardar(
            lienzo(512, 0.06, color),
            os.path.join(APP, "assets", "logo", f"logo_{nombre}.png"),
        )

    print("  marca de la app        3 archivos")


def recurso_correo():
    """Logo blanco sobre transparente para las plantillas de correo."""
    for nombre in ("blanco", "negro"):
        guardar(
            lienzo(256, 0.06, VARIANTES[nombre]),
            os.path.join(CORREO, f"logo-{nombre}.png"),
        )

    print("  recursos de correo     2 archivos")


def marca_figma():
    """PNG de 512 px para arrastrar a Figma y recortados de 240 px para incrustar."""
    for nombre, color in VARIANTES.items():
        guardar(lienzo(512, 0.06, color), os.path.join(FIGMA, f"logo-{nombre}.png"))
        guardar(lienzo(240, 0.04, color), os.path.join(FIGMA, f"emblema-{nombre}.png"))

    print("  marca para Figma       6 archivos")
