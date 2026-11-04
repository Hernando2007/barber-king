#!/usr/bin/env python3
"""Genera todos los archivos del logo de Barber King a partir del original.

Uso:  python tools/generar_logo.py [ruta-logo.png]

Crea las marcas transparentes de la app, los iconos de Android (clásico,
adaptativo y monocromo), los de iOS, los de web, los recursos de correo y
las marcas del paquete de Figma.
"""

import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from logo.base import LOGO_FUENTE
from logo.entregables import marca_app, marca_figma, recurso_correo
from logo.plataformas import iconos_android, iconos_ios, iconos_web


def main():
    if len(sys.argv) > 1:
        shutil.copyfile(sys.argv[1], LOGO_FUENTE)

    if not os.path.exists(LOGO_FUENTE):
        raise SystemExit(f"Falta el logo original en {LOGO_FUENTE}")

    marca_app()
    iconos_android()
    iconos_ios()
    iconos_web()
    recurso_correo()
    marca_figma()
    print("Listo.")


if __name__ == "__main__":
    main()
