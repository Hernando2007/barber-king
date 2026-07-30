INSERT INTO servicios (nombre, descripcion, precio, duracion)
VALUES
('Corte Clásico', 'Corte tradicional', 20000, 30),
('Fade', 'Corte Fade profesional', 30000, 45),
('Barba', 'Perfilado de barba', 15000, 20),
('Corte + Barba', 'Combo completo', 40000, 60),
('VIP', 'Servicio Premium', 60000, 90);



INSERT INTO barberos
(usuario_id, especialidad, experiencia, descripcion, disponible)
VALUES
(2,'Fade',5,'Especialista en Fade',true);



INSERT INTO citas
(cliente_id,barbero_id,servicio_id,fecha,hora,estado)
VALUES
(3,1,1,'2026-08-10','09:00:00','Pendiente'),
(3,1,2,'2026-08-11','10:00:00','Pendiente'),
(3,1,3,'2026-08-12','11:00:00','Completada');



INSERT INTO resenas
(cliente_id,barbero_id,cita_id,calificacion,comentario)
VALUES
(3,1,3,5,'Excelente servicio'),
(3,1,3,4,'Muy recomendado');