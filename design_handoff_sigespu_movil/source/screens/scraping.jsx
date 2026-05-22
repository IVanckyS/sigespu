// Scraping — Public transparency data scraping mobile view
function ScreenScraping() {
  const rows = [
    { dec: '#1852', fecha: '2026-03-30', tipo: 'Comercial', rut: '77.173.367-0', razon: 'COMERCIAL Y SERVICIOS TRINUM SPA', giro: 'Bodega venta al por mayor', addr: 'Vista Hermosa 1199', geo: 'Alta', selected: true },
    { dec: '#1837', fecha: '2026-03-22', tipo: 'MEF',       rut: '19.876.543-2', razon: 'MARÍA FERNANDA SOTO ÁLVAREZ',     giro: 'Servicios de peluquería',      addr: 'P.A. Cerda 1204', geo: 'Alta' },
    { dec: '#1819', fecha: '2026-03-15', tipo: 'Alcoholes', rut: '77.889.910-K', razon: 'MINIMARKET LOTA ALTO LIMITADA',  giro: 'Minimarket con expendio',      addr: 'Caupolicán 560',  geo: 'Alta' },
    { dec: '#1798', fecha: '2026-02-28', tipo: 'Profesional',rut:'13.456.789-1', razon: 'JUAN PABLO CONTRERAS LEÓN',     giro: 'Contador auditor',             addr: 'Serrano 485 of. 301', geo: 'Media' },
    { dec: '#1776', fecha: '2026-02-18', tipo: 'Comercial', rut: '9.876.543-2',  razon: 'SOCIEDAD COMERCIAL DOÑA RAQUEL',giro: 'Almacén de abarrotes',         addr: 'P. A. Cerda 808 Local B', geo: 'Alta' },
    { dec: '#1754', fecha: '2026-02-10', tipo: 'Comercial', rut: '76.111.222-3', razon: 'DISTRIBUIDORA Y COMERCIAL SUR', giro: 'Venta de frutas y verduras',   addr: 'Los Aromos 290',  geo: 'Alta' },
  ];

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
      <AppTopBar exportAction={{ label: 'Exportar PDF', icon: 'pdf', sub: 'Scraping · 15 patentes' }}/>

      <div style={{ flex: 1, overflow: 'auto', padding: '12px 14px 100px' }}>
        <Hero
          kicker="Fuente · lotatransparente.cl"
          kickerIcon="download"
          title="Datos de Transparencia Pública"
          subtitle="Ley 20.285 · Patentes, permisos, decretos y organizaciones"
          stats={[
            { value: 15, label: 'Patentes' },
            { value: 8,  label: 'Permisos' },
            { value: 6,  label: 'Tránsito' },
            { value: 8,  label: 'Orgs.' },
          ]}
          cornerPattern="download"
        />

        {/* Source meta */}
        <div style={{ marginTop: 10, display: 'flex', gap: 6, fontSize: 11, color: SG.ink3, fontFamily: SG.font, flexWrap: 'wrap' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            <Icon name="clock" size={11}/> Última extracción: hace 3h
          </span>
          <span style={{ color: SG.ink4 }}>·</span>
          <span style={{ color: SG.green, fontWeight: 600 }}>● Operativo</span>
        </div>

        {/* Sub-tabs: source datasets */}
        <div style={{ display: 'flex', gap: 6, marginTop: 12, overflowX: 'auto' }}>
          {[
            { id: 'pat', label: 'Patentes comerciales', count: 15, active: true },
            { id: 'per', label: 'Permisos DOM',          count: 8 },
            { id: 'dec', label: 'Decretos tránsito',     count: 6 },
            { id: 'org', label: 'Organizaciones',        count: 8 },
          ].map(t => (
            <div key={t.id} style={{
              display: 'inline-flex', alignItems: 'center', gap: 6, padding: '7px 11px',
              borderRadius: 999,
              background: t.active ? SG.ink : '#fff',
              color: t.active ? '#fff' : SG.ink2,
              border: t.active ? `1px solid ${SG.ink}` : `1px solid ${SG.border}`,
              fontSize: 12, fontWeight: 600, fontFamily: SG.font, flexShrink: 0, whiteSpace: 'nowrap',
            }}>
              {t.label}
              <span style={{
                fontSize: 10.5, fontWeight: 700,
                padding: '1px 6px', borderRadius: 999,
                background: t.active ? 'rgba(255,255,255,0.18)' : SG.graySoft,
                color: t.active ? '#fff' : SG.ink3,
              }}>{t.count}</span>
            </div>
          ))}
        </div>

        {/* Filter row */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 7, marginTop: 12 }}>
          {[
            { k: 'Año', v: 'Todos' },
            { k: 'Mes', v: 'Todos' },
            { k: 'Geocoding', v: 'Todos' },
          ].map(f => (
            <div key={f.k} style={{
              padding: '7px 10px', borderRadius: 10, background: '#fff',
              border: `1px solid ${SG.border}`, fontFamily: SG.font,
            }}>
              <div style={{ fontSize: 9.5, color: SG.ink3, textTransform: 'uppercase', letterSpacing: 0.4, fontWeight: 700 }}>{f.k}</div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 1 }}>
                <span style={{ fontSize: 12, color: SG.ink, fontWeight: 600 }}>{f.v}</span>
                <Icon name="chevDn" size={11} color={SG.ink3}/>
              </div>
            </div>
          ))}
        </div>

        {/* search */}
        <div style={{
          marginTop: 8, height: 40, borderRadius: 11, background: '#fff',
          border: `1px solid ${SG.border}`, display: 'flex', alignItems: 'center',
          gap: 7, padding: '0 12px',
        }}>
          <Icon name="search" size={15} color={SG.ink3}/>
          <span style={{ fontSize: 12.5, color: SG.ink3, fontFamily: SG.font }}>Razón social, RUT, dirección…</span>
        </div>

        {/* Results banner */}
        <div style={{
          marginTop: 10, padding: '8px 12px', borderRadius: 10,
          background: SG.orangeSoft, border: `1px solid #F9D2BA`,
          display: 'flex', alignItems: 'center', gap: 8, fontFamily: SG.font,
        }}>
          <span style={{
            width: 22, height: 22, borderRadius: 99, background: SG.orange,
            color: '#fff', display: 'grid', placeItems: 'center', flexShrink: 0,
          }}><Icon name="check" size={12} color="#fff"/></span>
          <div style={{ flex: 1, fontSize: 12, color: SG.ink2 }}>
            Resultados: <b style={{ color: SG.ink }}>15</b> de <b style={{ color: SG.ink }}>15</b>
          </div>
        </div>

        {/* Scraper actions */}
        <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
          <button style={{
            flex: 1, height: 40, borderRadius: 11, border: 'none',
            background: SG.orange, color: '#fff', fontWeight: 600, fontFamily: SG.font, fontSize: 12.5,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}><Icon name="refresh" size={14} color="#fff"/> Scrapear ahora</button>
          <button style={{
            flex: 1, height: 40, borderRadius: 11, border: `1px solid ${SG.orange}`,
            background: '#fff', color: SG.orange, fontWeight: 600, fontFamily: SG.font, fontSize: 12.5,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}><Icon name="cloud" size={14}/> Scrapear todo</button>
        </div>

        {/* List */}
        <div style={{
          marginTop: 14, display: 'flex', flexDirection: 'column', gap: 8,
        }}>
          {rows.map((r, i) => (
            <ScrapeRow key={i} row={r}/>
          ))}
        </div>
      </div>

      <BottomTabs active="scraping"/>

      {/* Popup: tap-to-open detail */}
      <BottomSheet height={520}>
        <div style={{ padding: '6px 16px 10px', display: 'flex', alignItems: 'center', gap: 8 }}>
          <Pill bg={SG.orangeSoft} fg={SG.orange}>Patente comercial</Pill>
          <Pill bg={SG.greenSoft} fg={SG.greenInk} dot>Geocoding: Alta</Pill>
          <div style={{ flex: 1 }}/>
          <button style={{
            width: 30, height: 30, borderRadius: 8, border: `1px solid ${SG.border}`,
            background: '#fff', color: SG.ink2, display: 'grid', placeItems: 'center',
          }}><Icon name="close" size={14}/></button>
        </div>
        <div style={{ height: 150, position: 'relative', overflow: 'hidden' }}>
          <MiniMap pinColor={SG.orange}/>
          <button style={{
            position: 'absolute', right: 10, top: 10,
            padding: '6px 10px', borderRadius: 8, border: 'none',
            background: 'rgba(255,255,255,0.95)', color: SG.ink, fontWeight: 600, fontSize: 11,
            display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: SG.font,
            boxShadow: SG.shadowSm,
          }}><Icon name="edit" size={12}/> Editar ubicación</button>
        </div>
        <div style={{ padding: '12px 16px 16px', overflow: 'auto', flex: 1 }}>
          <div style={{ fontSize: 15, fontWeight: 700, color: SG.ink, letterSpacing: -0.2, lineHeight: 1.25 }}>
            COMERCIAL Y SERVICIOS TRINUM SPA
          </div>
          <div style={{ marginTop: 4, fontSize: 12, color: SG.ink2 }}>
            Bodega venta al por mayor
          </div>

          <div style={{
            marginTop: 12, display: 'grid', gridTemplateColumns: '92px 1fr', gap: '7px 12px',
            fontSize: 12, fontFamily: SG.font,
          }}>
            <div style={{ color: SG.ink3 }}># Decreto</div>
            <div style={{ color: SG.orange, fontWeight: 700 }}>#1852</div>
            <div style={{ color: SG.ink3 }}>Fecha</div>
            <div style={{ color: SG.ink, fontWeight: 600 }}>30 mar 2026</div>
            <div style={{ color: SG.ink3 }}>RUT</div>
            <div style={{ color: SG.ink, fontWeight: 600 }}>77.173.367-0</div>
            <div style={{ color: SG.ink3 }}>Dirección</div>
            <div style={{ color: SG.ink, fontWeight: 600 }}>Vista Hermosa 1199</div>
            <div style={{ color: SG.ink3 }}>Coordenadas</div>
            <div style={{ color: SG.ink, fontWeight: 600, fontFamily: SG.fontDisplay, fontSize: 11.5 }}>-37.0894, -73.1612</div>
            <div style={{ color: SG.ink3 }}>Fuente</div>
            <div style={{ color: SG.ink2, fontSize: 11.5 }}>lotatransparente.cl · hace 3h</div>
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 16 }}>
            <button style={{
              flex: 1, height: 40, borderRadius: 10, border: `1px solid ${SG.border}`,
              background: '#fff', color: SG.ink, fontWeight: 600, fontSize: 12.5,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}><Icon name="map" size={14}/> Ver en mapa</button>
            <button style={{
              flex: 1, height: 40, borderRadius: 10, border: 'none',
              background: SG.orange, color: '#fff', fontWeight: 600, fontSize: 12.5,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}><Icon name="edit" size={13} color="#fff"/> Editar ubicación</button>
          </div>
        </div>
      </BottomSheet>
    </div>
  );
}

function ScrapeRow({ row }) {
  const geoColor = row.geo === 'Alta' ? { bg: SG.greenSoft, fg: SG.greenInk }
                  : row.geo === 'Media' ? { bg: SG.yellowSoft, fg: SG.yellowInk }
                  : { bg: SG.redSoft, fg: SG.redInk };
  return (
    <div style={{
      position: 'relative',
      background: row.selected ? '#FFF8F2' : '#fff',
      border: `1px solid ${row.selected ? '#F9D2BA' : SG.border}`,
      borderRadius: 12, padding: '11px 12px 12px 14px',
      fontFamily: SG.font, overflow: 'hidden',
    }}>
      {row.selected && (
        <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: SG.orange }}/>
      )}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ fontSize: 13, fontWeight: 700, color: SG.orange, fontFamily: SG.fontDisplay }}>{row.dec}</span>
        <span style={{ fontSize: 11, color: SG.ink3 }}>· {row.fecha}</span>
        <div style={{ flex: 1 }}/>
        <Pill bg={geoColor.bg} fg={geoColor.fg} dot>{row.geo}</Pill>
      </div>
      <div style={{
        marginTop: 6, fontSize: 13, fontWeight: 700, color: SG.ink,
        letterSpacing: -0.1, lineHeight: 1.3,
      }}>{row.razon}</div>
      <div style={{ marginTop: 3, fontSize: 11.5, color: SG.ink2 }}>{row.giro}</div>
      <div style={{
        marginTop: 8, display: 'flex', flexWrap: 'wrap', gap: 8, fontSize: 11, color: SG.ink3,
        alignItems: 'center',
      }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <span style={{
            padding: '1px 7px', borderRadius: 6, background: SG.graySoft,
            color: SG.ink2, fontWeight: 600, fontSize: 10.5,
          }}>{row.tipo}</span>
        </span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          RUT <b style={{ color: SG.ink2 }}>{row.rut}</b>
        </span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon name="pin" size={11}/> {row.addr}
        </span>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenScraping });
