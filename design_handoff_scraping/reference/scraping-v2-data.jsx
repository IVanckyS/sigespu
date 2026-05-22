/* ─────────── Scraping v2 · datos compartidos ─────────── */
/* Datos coherentes con la captura: 500 patentes, decretos #20XXXX,
   tipo COMER + clasificación "Datos sensibles", geocoding Alta/Fallo. */

const SC_PATENTES = [
  { dec:"#203217", fecha:"2025-12-15", tipo:"COMER", cls:"Datos sensibles", rut:"77.412.890-3", rs:"COMERCIALIZADORA VALMI LIMITADA",      giro:"PRODUCTOS TEXTILES MAYORISTAS",  dir:"SERRANO 921",            geo:"Alta"  },
  { dec:"#203222", fecha:"2025-11-17", tipo:"COMER", cls:"Datos sensibles", rut:"76.984.310-K", rs:"INMOBILIARIA JOSE CAMPOS EIRL",        giro:"INMOBILIARIA IMPORTANCIA…",      dir:"P. AGUIRRE CERDA 4628",  geo:"Fallo" },
  { dec:"#203220", fecha:"2025-11-17", tipo:"COMER", cls:"Datos sensibles", rut:"77.205.119-6", rs:"OUTLET CRISTIAN SPA",                  giro:"VENTA AL POR MENOR VESTUARIO",   dir:"SERRANO 624",            geo:"Alta"  },
  { dec:"#203214", fecha:"2025-11-10", tipo:"COMER", cls:"Datos sensibles", rut:"76.117.882-1", rs:"PANADERÍA EL PALOMO LIMITADA",         giro:"ELABORACIÓN DE PAN Y AFINES",    dir:"CAUPOLICÁN 1185",        geo:"Alta"  },
  { dec:"#203210", fecha:"2025-10-28", tipo:"COMER", cls:"Datos sensibles", rut:"19.337.220-8", rs:"MARÍA FERNANDA SOTO ÁLVAREZ",          giro:"SERVICIOS DE PELUQUERÍA",        dir:"P.A. CERDA 1204",        geo:"Alta"  },
  { dec:"#203207", fecha:"2025-10-22", tipo:"COMER", cls:"Datos sensibles", rut:"76.001.882-K", rs:"FERRETERÍA MAIPO HERMANOS LTDA.",      giro:"VENTA MATERIALES DE CONSTRUC.",  dir:"MATTA 980",              geo:"Alta"  },
  { dec:"#203202", fecha:"2025-10-15", tipo:"COMER", cls:"Datos sensibles", rut:"77.889.910-K", rs:"MINIMARKET LOTA ALTO LIMITADA",        giro:"MINIMARKET CON EXPENDIO",        dir:"CAUPOLICÁN 560",         geo:"Fallo" },
  { dec:"#203199", fecha:"2025-10-08", tipo:"COMER", cls:"Datos sensibles", rut:"13.456.789-1", rs:"JUAN PABLO CONTRERAS LÓPEZ",           giro:"CONTADOR AUDITOR",               dir:"SERRANO 485 OF. 301",    geo:"Alta"  },
  { dec:"#203195", fecha:"2025-10-02", tipo:"COMER", cls:"Datos sensibles", rut:"76.555.444-1", rs:"RESTAURANT EL MIRADOR SPA",            giro:"RESTAURANTE CON EXPENDIO",       dir:"LAUTARO 1140",           geo:"Alta"  },
  { dec:"#203190", fecha:"2025-09-25", tipo:"COMER", cls:"Datos sensibles", rut:"77.173.367-0", rs:"COMERCIAL Y SERVICIOS TRINUM SPA",     giro:"BODEGA VENTA AL POR MENOR",      dir:"VISTA HERMOSA 1199",     geo:"Alta"  },
  { dec:"#203186", fecha:"2025-09-19", tipo:"COMER", cls:"Datos sensibles", rut:"21.345.678-9", rs:"TALLER MECÁNICO HNOS. PÉREZ E.I.R.L.", giro:"REPARACIÓN DE VEHÍCULOS",        dir:"MARIANO EGAÑA 92",       geo:"Fallo" },
  { dec:"#203181", fecha:"2025-09-12", tipo:"COMER", cls:"Datos sensibles", rut:"9.876.543-2",  rs:"SOCIEDAD COMERCIAL DOÑA EMA LTDA.",    giro:"ALMACÉN DE ABARROTES",           dir:"P. A. CERDA 808 LOCAL B",geo:"Alta"  },
];

const SC_SOURCES = [
  { id:"patentes",       label:"Patentes comerciales",   short:"Patentes",  count:500, active:true,  ig:"164", last:"2026-04-24 03:02" },
  { id:"permisos",       label:"Permisos DOM",           short:"DOM",       count:0,   active:false, ig:"098", last:"2026-04-24 03:04" },
  { id:"decretos",       label:"Decretos de tránsito",   short:"Decretos",  count:0,   active:false, ig:"071", last:"2026-04-24 03:05" },
  { id:"organizaciones", label:"Organizaciones sociales",short:"Org.",      count:0,   active:false, ig:"044", last:"2026-04-24 03:06" },
];

/* Color helpers */
const SC_GEO_COLOR = {
  Alta:  { bg:"#DCFCE7", fg:"#15803D", dot:"#16A34A" },
  Media: { bg:"#FEF3C7", fg:"#92400E", dot:"#CA8A04" },
  Fallo: { bg:"#F5F5F4", fg:"#57534E", dot:"#A8A29E" },
};

window.ScrapingV2Data = { SC_PATENTES, SC_SOURCES, SC_GEO_COLOR };
