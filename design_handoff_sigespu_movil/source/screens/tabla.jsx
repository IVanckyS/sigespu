// Tabla — table-of-records mobile view (cards + filter sheet + detail sheet)
function ScreenTabla() {
  const rows = [
    { tipo: 'Vandalismo',   name: 'Daño paradero',          sector: 'S-3',    addr: 'Vista Hermosa 1050',         fecha: '2026-04-23', estado: 'Activo',     reg: { i: 'PC', name: 'P. Castro',    color: '#A855F7' }, selected: true },
    { tipo: 'Árbol caído',  name: 'Árbol caído sobre calzada', sector: 'S-2', addr: 'Los Aromos 380',             fecha: '2026-04-23', estado: 'Activo',     reg: { i: 'RS', name: 'R. Sepúlveda', color: '#16A34A' } },
    { tipo: 'Robo',         name: 'Robo con intimidación',  sector: 'Centro', addr: 'Carlos Cousiño 340',          fecha: '2026-04-22', estado: 'Activo',     reg: { i: 'RS', name: 'R. Sepúlveda', color: '#DC2626' } },
    { tipo: 'Poste caído',  name: 'Poste eléctrico inclinado', sector: 'S-5', addr: 'Monseñor Fuenzalida 1020',    fecha: '2026-04-22', estado: 'Activo',     reg: { i: 'CM', name: 'C. Muñoz',     color: '#F97316' } },
    { tipo: 'Robo',         name: 'Robo en vivienda',       sector: 'S-2',    addr: 'Los Aromos 512',             fecha: '2026-04-21', estado: 'En revisión',reg: { i: 'RS', name: 'R. Sepúlveda', color: '#DC2626' } },
    { tipo: 'Cable colgando', name: 'Cable telefónico colgando', sector: 'Centro', addr: 'Matta esq. Caupolicán', fecha: '2026-04-21', estado: 'Activo',     reg: { i: 'RS', name: 'R. Sepúlveda', color: '#CA8A04' } },
    { tipo: 'Accidente',    name: 'Colisión vehicular',     sector: 'Centro', addr: 'Av. Pedro Aguirre Cerda 850', fecha: '2026-04-20', estado: 'Cerrado',    reg: { i: 'CM', name: 'C. Muñoz',     color: '#F97316' } },
  ];

  const cats = [
    { id: 'total', label: 'Total', count: 33, active: true, color: SG.ink },
    { id: 'zonas', label: 'Zonas peligro', count: 5, color: SG.red },
    { id: 'pat',   label: 'Patentes', count: 5, color: SG.orange },
    { id: 'infra', label: 'Infra.', count: 9, color: '#2563EB' },
    { id: 'otros', label: 'Otros', count: 14, color: SG.gray },
  ];

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
      <AppTopBar exportAction={{ label: 'Exportar PDF', icon: 'pdf', sub: 'Tabla · 7 registros filtrados' }}/>

      <div style={{ flex: 1, overflow: 'auto', padding: '12px 14px 100px' }}>
        <Hero
          kicker="Vista · Registro de elementos"
          kickerIcon="table"
          title="Tabla de datos"
          subtitle="Todos los elementos georreferenciados. Filtrable por tipo, sector y estado."
          stats={[
            { value: 33, label: 'Total registros' },
            { value: 4,  label: 'Sectores' },
            { value: 27, label: 'Activos' },
            { value: 0,  label: 'Esta semana' },
          ]}
          variant="dark"
          cornerPattern="lines"
        />

        {/* Search + filter chips row */}
        <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
          <div style={{
            flex: 1, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'flex', alignItems: 'center',
            gap: 7, padding: '0 12px',
          }}>
            <Icon name="search" size={15} color={SG.ink3}/>
            <span style={{ fontSize: 12.5, color: SG.ink3, fontFamily: SG.font }}>Nombre, dirección, RUT…</span>
          </div>
          <button style={{
            width: 40, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'grid', placeItems: 'center',
            color: SG.ink2, position: 'relative',
          }}>
            <Icon name="filter" size={17}/>
            <span style={{
              position: 'absolute', top: 4, right: 4, width: 7, height: 7,
              borderRadius: 99, background: SG.orange,
            }}/>
          </button>
          <button style={{
            width: 40, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'grid', placeItems: 'center',
            color: SG.ink2,
          }}>
            <Icon name="sortDn" size={17}/>
          </button>
        </div>

        {/* Active filters preview */}
        <div style={{ display: 'flex', gap: 6, marginTop: 10, overflowX: 'auto' }}>
          {[
            { k: 'Tipo', v: 'Todos' },
            { k: 'Sector', v: 'Todos' },
            { k: 'Estado', v: 'Todos' },
            { k: 'Fecha', v: 'Cualquiera' },
            { k: 'Registrado', v: 'Todos' },
          ].map(f => (
            <div key={f.k} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5, padding: '5px 10px',
              borderRadius: 999, background: '#fff', border: `1px solid ${SG.border}`,
              fontSize: 11, fontWeight: 500, color: SG.ink2, fontFamily: SG.font,
              whiteSpace: 'nowrap', flexShrink: 0,
            }}>
              <span style={{ color: SG.ink3 }}>{f.k}:</span>
              <span style={{ color: SG.ink, fontWeight: 600 }}>{f.v}</span>
              <Icon name="chevDn" size={11}/>
            </div>
          ))}
        </div>

        {/* Category pills */}
        <div style={{ display: 'flex', gap: 6, marginTop: 12, overflowX: 'auto' }}>
          {cats.map(c => (
            <div key={c.id} style={{
              display: 'inline-flex', alignItems: 'center', gap: 6, padding: '7px 11px',
              borderRadius: 999, background: c.active ? '#fff' : 'transparent',
              border: c.active ? `1px solid ${SG.ink}` : `1px solid ${SG.border}`,
              fontFamily: SG.font, flexShrink: 0,
            }}>
              <span style={{ width: 7, height: 7, borderRadius: 99, background: c.color, display: 'inline-block' }}/>
              <span style={{ fontSize: 11.5, fontWeight: 600, color: c.active ? SG.ink : SG.ink2 }}>{c.label}</span>
              <span style={{
                fontSize: 10.5, fontWeight: 700, color: SG.ink3,
                background: SG.graySoft, padding: '1px 6px', borderRadius: 999,
              }}>{c.count}</span>
            </div>
          ))}
        </div>

        {/* Sort indicator + count */}
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          marginTop: 12, padding: '0 2px', fontFamily: SG.font,
        }}>
          <div style={{ fontSize: 11.5, color: SG.ink3 }}>Mostrando <b style={{ color: SG.ink }}>7</b> de 33</div>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: 11.5, color: SG.ink2 }}>
            Fecha <Icon name="arrowDn" size={11}/>
          </div>
        </div>

        {/* Record cards list */}
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {rows.map((r, i) => (
            <RecordCard key={i} row={r}/>
          ))}
        </div>
      </div>

      <BottomTabs active="tabla"/>

      {/* Popup: tap-to-open detail (shown on top of everything in this screen) */}
      <BottomSheet height={510}>
        <div style={{ padding: '6px 16px 10px', display: 'flex', alignItems: 'center', gap: 8 }}>
          <TypeBadge type="Vandalismo"/>
          <SectorBadge code="S-3"/>
          <div style={{ flex: 1 }}/>
          <button style={{
            width: 30, height: 30, borderRadius: 8, border: `1px solid ${SG.border}`,
            background: '#fff', color: SG.ink2, display: 'grid', placeItems: 'center',
          }}><Icon name="close" size={14}/></button>
        </div>
        <div style={{ height: 150, position: 'relative', overflow: 'hidden' }}>
          <MiniMap pinColor="#A855F7"/>
          <button style={{
            position: 'absolute', right: 10, top: 10,
            padding: '6px 10px', borderRadius: 8, border: 'none',
            background: 'rgba(255,255,255,0.95)', color: SG.ink, fontWeight: 600, fontSize: 11,
            display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: SG.font,
            boxShadow: SG.shadowSm,
          }}><Icon name="eye" size={12}/> Abrir en mapa</button>
        </div>
        <div style={{ padding: '12px 16px 16px', overflow: 'auto', flex: 1 }}>
          <div style={{ fontSize: 16, fontWeight: 700, color: SG.ink, letterSpacing: -0.2, lineHeight: 1.2 }}>
            Daño paradero
          </div>
          <div style={{ marginTop: 6, display: 'flex', alignItems: 'center', gap: 6 }}>
            <StatusBadge status="Activo"/>
            <span style={{ fontSize: 11, color: SG.ink3 }}>· ID #R-2026-0423</span>
          </div>

          <div style={{
            marginTop: 12, display: 'grid', gridTemplateColumns: '92px 1fr', gap: '7px 12px',
            fontSize: 12, fontFamily: SG.font,
          }}>
            <div style={{ color: SG.ink3 }}>Dirección</div>
            <div style={{ color: SG.ink, fontWeight: 600 }}>Vista Hermosa 1050</div>
            <div style={{ color: SG.ink3 }}>Coordenadas</div>
            <div style={{ color: SG.ink, fontWeight: 600, fontFamily: SG.fontDisplay, fontSize: 11.5 }}>-37.0876, -73.1543</div>
            <div style={{ color: SG.ink3 }}>Sector</div>
            <div><SectorBadge code="S-3"/> <span style={{ color: SG.ink2, fontSize: 11.5, marginLeft: 4 }}>Mixto Los Aromos</span></div>
            <div style={{ color: SG.ink3 }}>Fecha</div>
            <div style={{ color: SG.ink, fontWeight: 600 }}>23 abr 2026 · 14:22</div>
            <div style={{ color: SG.ink3 }}>Registrado por</div>
            <div style={{ color: SG.ink, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <span style={{
                width: 18, height: 18, borderRadius: 99, background: '#A855F7',
                color: '#fff', fontSize: 9, fontWeight: 700, display: 'inline-grid', placeItems: 'center',
              }}>PC</span>
              P. Castro · Inspector
            </div>
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
            }}><Icon name="pencil" size={13} color="#fff"/> Editar registro</button>
          </div>
        </div>
      </BottomSheet>
    </div>
  );
}

function RecordCard({ row }) {
  return (
    <div style={{
      position: 'relative',
      background: row.selected ? '#FFF8F2' : '#fff',
      border: `1px solid ${row.selected ? '#F9D2BA' : SG.border}`,
      borderRadius: 12, padding: '11px 12px 11px 14px',
      fontFamily: SG.font, overflow: 'hidden',
    }}>
      {row.selected && (
        <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: SG.orange }}/>
      )}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <TypeBadge type={row.tipo}/>
        <SectorBadge code={row.sector}/>
        <div style={{ flex: 1 }}/>
        <StatusBadge status={row.estado}/>
      </div>
      <div style={{
        marginTop: 7, fontSize: 13.5, fontWeight: 600, color: SG.ink,
        letterSpacing: -0.1, lineHeight: 1.3,
      }}>{row.name}</div>
      <div style={{ marginTop: 3, display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: SG.ink3 }}>
        <Icon name="pin" size={12}/>
        <span>{row.addr}</span>
      </div>
      <div style={{
        marginTop: 8, display: 'flex', alignItems: 'center', gap: 8, fontSize: 11, color: SG.ink3,
      }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon name="calendar" size={11}/> {row.fecha}
        </span>
        <span style={{ color: SG.ink4 }}>·</span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
          <span style={{
            width: 18, height: 18, borderRadius: 99, background: row.reg.color,
            color: '#fff', fontSize: 9, fontWeight: 700, display: 'inline-grid', placeItems: 'center',
          }}>{row.reg.i}</span>
          <span style={{ color: SG.ink2, fontWeight: 500 }}>{row.reg.name}</span>
        </span>
      </div>
    </div>
  );
}

// Reusable horizontal section nav strip
function NavStrip({ active }) {
  const tabs = [
    { id: 'mapa', label: 'Mapa', icon: 'map' },
    { id: 'resumen', label: 'Resumen', icon: 'grid' },
    { id: 'tabla', label: 'Tabla', icon: 'table' },
    { id: 'scraping', label: 'Scraping', icon: 'download' },
    { id: 'usuarios', label: 'Usuarios', icon: 'users' },
    { id: 'actividades', label: 'Actividades', icon: 'kanban', badge: 12 },
  ];
  return (
    <div style={{
      display: 'flex', gap: 6, padding: '8px 14px 10px',
      overflowX: 'auto', background: '#fff', borderBottom: `1px solid ${SG.border}`,
      fontFamily: SG.font,
    }}>
      {tabs.map(t => {
        const a = active === t.id;
        return (
          <div key={t.id} style={{
            display: 'inline-flex', alignItems: 'center', gap: 5, padding: '6px 11px',
            borderRadius: 999, fontSize: 12, fontWeight: 600,
            background: a ? SG.orangeSoft : 'transparent',
            color: a ? SG.orange : SG.ink2,
            border: a ? `1px solid ${SG.orange}` : `1px solid ${SG.border}`,
            whiteSpace: 'nowrap', flexShrink: 0,
          }}>
            <Icon name={t.icon} size={13}/>
            {t.label}
            {t.badge && <span style={{
              background: SG.orange, color: '#fff', fontSize: 9.5, fontWeight: 700,
              padding: '0px 5px', borderRadius: 999, minWidth: 14, textAlign: 'center',
            }}>{t.badge}</span>}
          </div>
        );
      })}
    </div>
  );
}

// Mini map illustration
function MiniMap({ pinColor = SG.orange }) {
  return (
    <svg width="100%" height="130" viewBox="0 0 360 130" preserveAspectRatio="xMidYMid slice">
      <rect width="360" height="130" fill="#E5E1D8"/>
      {/* terrain */}
      <path d="M0 90 Q60 60 120 80 T240 70 T360 80 V130 H0 Z" fill="#D8DDD2"/>
      <path d="M0 110 Q80 85 160 100 T360 95 V130 H0 Z" fill="#C9D2C1"/>
      {/* roads */}
      <path d="M-10 70 Q90 50 200 60 T380 55" stroke="#fff" strokeWidth="6" fill="none"/>
      <path d="M40 -10 Q60 50 80 100 T120 200" stroke="#fff" strokeWidth="5" fill="none"/>
      <path d="M260 -10 Q255 50 280 90 T320 200" stroke="#fff" strokeWidth="5" fill="none"/>
      {/* labels */}
      <text x="20" y="40" fontSize="9" fill="#78716C" fontFamily={SG.font}>Vista Hermosa</text>
      <text x="220" y="115" fontSize="9" fill="#78716C" fontFamily={SG.font}>Carlos Cousiño</text>
      {/* pin */}
      <g transform="translate(180 60)">
        <circle r="14" fill={pinColor}/>
        <circle r="20" fill={pinColor} fillOpacity="0.25"/>
        <path d="M-4 -2h8v8h-8z" fill="#fff"/>
      </g>
    </svg>
  );
}

Object.assign(window, { ScreenTabla, NavStrip, MiniMap });
