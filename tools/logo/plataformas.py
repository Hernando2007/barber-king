"""Iconos de Android, iOS y web generados a partir del logo."""

import json
import os

from logo.base import (
    ADAPTATIVO,
    APP,
    BLANCO,
    DENSIDADES,
    FONDO,
    NEGRO,
    RES,
    guardar,
    lienzo,
)

APP_IOS = os.path.join(APP, "ios")
APP_WEB = os.path.join(APP, "web")


def iconos_android():
    for densidad, tamano in DENSIDADES.items():
        guardar(
            lienzo(tamano, 0.14, NEGRO, FONDO + (255,)),
            os.path.join(RES, f"mipmap-{densidad}", "ic_launcher.png"),
        )

    # El plano frontal del icono adaptativo debe caber en el centro (66/108).
    for densidad, tamano in ADAPTATIVO.items():
        guardar(
            lienzo(tamano, 0.40, NEGRO),
            os.path.join(RES, f"drawable-{densidad}", "ic_launcher_foreground.png"),
        )
        guardar(
            lienzo(tamano, 0.40, BLANCO),
            os.path.join(RES, f"drawable-{densidad}", "ic_launcher_monochrome.png"),
        )

    carpeta = os.path.join(RES, "mipmap-anydpi-v26")
    os.makedirs(carpeta, exist_ok=True)
    adaptativo = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@drawable/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />\n'
        "</adaptive-icon>\n"
    )

    for nombre in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(carpeta, nombre), "w", encoding="utf-8") as archivo:
            archivo.write(adaptativo)

    colores = os.path.join(RES, "values", "colors.xml")
    with open(colores, "r", encoding="utf-8") as archivo:
        contenido = archivo.read()

    if "ic_launcher_background" not in contenido:
        contenido = contenido.replace(
            "</resources>",
            '    <color name="ic_launcher_background">#FFFFFFFF</color>\n</resources>',
        )
        with open(colores, "w", encoding="utf-8") as archivo:
            archivo.write(contenido)

    print("  iconos Android         5 clásicos + 10 adaptativos")


def iconos_ios():
    carpeta = os.path.join(
        APP_IOS, "Runner", "Assets.xcassets", "AppIcon.appiconset"
    )

    with open(os.path.join(carpeta, "Contents.json"), encoding="utf-8") as archivo:
        plan = json.load(archivo)

    total = 0

    for item in plan.get("images", []):
        if "filename" not in item:
            continue

        lado, escala = item["size"].split("x")[0], item["scale"].rstrip("x")
        tamano = max(1, int(round(float(lado) * float(escala))))
        guardar(
            lienzo(tamano, 0.16, NEGRO, FONDO + (255,)),
            os.path.join(carpeta, item["filename"]),
            solido=True,
        )
        total += 1

    print(f"  iconos iOS             {total} archivos")


def iconos_web():
    guardar(
        lienzo(64, 0.10, NEGRO, FONDO + (255,)),
        os.path.join(APP_WEB, "favicon.png"),
        solido=True,
    )

    for tamano in (192, 512):
        guardar(
            lienzo(tamano, 0.14, NEGRO, FONDO + (255,)),
            os.path.join(APP_WEB, "icons", f"Icon-{tamano}.png"),
            solido=True,
        )
        guardar(
            lienzo(tamano, 0.30, NEGRO, FONDO + (255,)),
            os.path.join(APP_WEB, "icons", f"Icon-maskable-{tamano}.png"),
            solido=True,
        )

    manifiesto = os.path.join(APP_WEB, "manifest.json")

    with open(manifiesto, encoding="utf-8") as archivo:
        datos = json.load(archivo)

    datos["name"] = "Barber King"
    datos["short_name"] = "Barber King"
    datos["description"] = "Gestión profesional para tu barbería"
    datos["background_color"] = "#070A12"
    datos["theme_color"] = "#070A12"

    with open(manifiesto, "w", encoding="utf-8") as archivo:
        json.dump(datos, archivo, indent=4, ensure_ascii=False)
        archivo.write("\n")

    print("  iconos web             5 archivos + manifest")
