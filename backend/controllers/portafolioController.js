import {
    borrarMiFoto,
    fotosPublicas,
    misFotos,
    subirFotos,
} from "../services/portafolioService.js";
import { httpError } from "../utils/httpError.js";

const idPositivo = (valor, mensaje) => {
    const id = Number(valor);

    if (!Number.isInteger(id) || id <= 0) {
        throw httpError(400, mensaje);
    }

    return id;
};

// La galería pública: cualquiera ve el trabajo del barbero.
export const fotosDelBarbero = async (req, res, next) => {
    try {
        const barberoId = idPositivo(req.params.barberoId, "Barbero no válido.");
        const fotos = await fotosPublicas(barberoId);

        return res.status(200).json({
            success: true,
            total: fotos.length,
            data: fotos,
        });
    } catch (error) {
        next(error);
    }
};

export const misFotosController = async (req, res, next) => {
    try {
        const fotos = await misFotos(req.usuario);

        return res.status(200).json({
            success: true,
            total: fotos.length,
            data: fotos,
        });
    } catch (error) {
        next(error);
    }
};

export const subirMisFotos = async (req, res, next) => {
    try {
        const fotos = await subirFotos(req.usuario, req.files);

        return res.status(201).json({
            success: true,
            total: fotos.length,
            data: fotos,
            message: "Fotos publicadas en tu portafolio.",
        });
    } catch (error) {
        next(error);
    }
};

export const borrarMiFotoController = async (req, res, next) => {
    try {
        const fotoId = idPositivo(req.params.fotoId, "Foto no válida.");
        const foto = await borrarMiFoto(req.usuario, fotoId);

        return res.status(200).json({
            success: true,
            data: foto,
            message: "Foto eliminada.",
        });
    } catch (error) {
        next(error);
    }
};
