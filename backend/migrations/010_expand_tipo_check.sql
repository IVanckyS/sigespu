ALTER TABLE puntos_interes
  DROP CONSTRAINT IF EXISTS puntos_interes_tipo_check;

ALTER TABLE puntos_interes
  ADD CONSTRAINT puntos_interes_tipo_check CHECK (tipo IN (
    'centro_acopio','sede_comunitaria','infraestructura',
    'luminaria','camara_cctv',
    'arbol_caido','poste_caido','sector_sin_luz','cable_colgando',
    'semaforo_dañado','socavon','fuga_agua','microbasural','otro',
    'reporte_robo','reporte_vandalismo','reporte_accidente',
    'reporte_violencia','reporte_drogas','reporte_riña',
    'reporte_emergencia_medica','reporte_incendio','reporte_otro'
  ));
