// Actividades — Kanban → mobile (column switcher + cards stream)
function ScreenActividades() {
  const columns = [
    {
      id: 'planificado', label: 'Planificado', count: 4, color: '#2563EB', bg: '#EFF6FF',
      cards: [
        { tipo: 'Reunión',      sector: 'S-2', title: 'Mesa territorial Lota Bajo · Comerciantes Pedro Aguirre Cerda', date: '18 may', time: '09:00', part: 0, where: 'Pedro Aguirre Cerda 302, Lota Bajo' },
        { tipo: 'Capacitación', sector: 'S-3', title: 'Capacitación inspectores · Uso de SIGESPU móvil',                date: '20 may', time: '10:00', part: 0, where: 'Edificio Consistorial · Sala Cuncos' },
        { tipo: 'Operativo',    sector: 'S-4', title: 'Operativo conjunto Carabineros · Sector Plaza de Armas',         date: '22 may', time: '22:00', part: 0, where: 'Sin ubicación' },
        { tipo: 'Evento',       sector: 'Centro', title: 'Feria del Adulto Mayor · Plaza Matías Cousiño',               date: '2 jun',  time: '10:00', part: 0, where: 'Plaza Matías Cousiño, Lota Alto' },
      ],
    },
    {
      id: 'en-curso', label: 'En curso', count: 3, color: SG.orange, bg: SG.orangeSoft,
      cards: [
        { tipo: 'Operativo', sector: 'S-2',    title: 'Patrullaje preventivo · Sector estación de servicio Copec', date: '10 may', time: '20:00', part: 0, where: 'Av. Carlos Cousiño 1820, Lota Bajo' },
        { tipo: 'Evento',    sector: 'Centro', title: 'Semana de la Seguridad Comunitaria · Talleres en juntas de vecinos', date: '11 may', time: '18:00', part: 0, where: 'Múltiples sedes · 6 sectores' },
        { tipo: 'Reunión',   sector: 'S-3',    title: 'Comité Sectorial S-3 · Junta de Vecinos La Cima',           date: '12 may', time: '19:00', part: 0, where: 'Sede social calle Galvarino 412' },
      ],
    },
    {
      id: 'completado', label: 'Completado', count: 3, color: SG.green, bg: SG.greenSoft,
      cards: [
        { tipo: 'Operativo',    sector: 'S-5',    title: 'Operativo fiscalización patentes alcoholes · Sector Lota Alto', date: '18 abr', time: '20:00', part: 0, where: 'Av. Pedro Aguirre Cerda · S-5' },
        { tipo: 'Capacitación', sector: 'Centro', title: 'Capacitación Defensa Civil · Primeros auxilios',                 date: '22 abr', time: '09:00', part: 0, where: 'Bomberos 2ª Compañía Lota' },
        { tipo: 'Reunión',      sector: 'S-1',    title: 'Reunión con Director DIDECO · Plan Calle Segura 2026',           date: '28 abr', time: '11:00', part: 0, where: 'Alcaldía · Sala de Directorio' },
      ],
    },
    {
      id: 'archivado', label: 'Archivado', count: 2, color: SG.gray, bg: SG.graySoft,
      cards: [
        { tipo: 'Reunión', sector: 'S-6',    title: 'Mesa Barrio Seguro · Diciembre',                        date: '18 dic', time: '18:00', part: 0, where: 'Sede J.V. Lota Verde Sur' },
        { tipo: 'Evento',  sector: 'Centro', title: 'Aniversario 145 años · Acto cívico Plaza de Armas',     date: '5 ene',  time: '11:00', part: 0, where: 'Plaza de Armas Lota' },
      ],
    },
  ];

  // For mobile, show first column as primary + peek of next 2 below.
  const [primary, ...rest] = columns;

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
      <AppTopBar exportAction={{ label: 'Exportar JSON', icon: 'pdf', sub: 'Actividades · 12 totales' }}/>

      <div style={{ flex: 1, overflow: 'auto', padding: '12px 14px 100px' }}>
        {/* Toolbar / hero compact */}
        <div style={{
          borderRadius: 16, background: `linear-gradient(135deg, ${SG.ink} 0%, #292524 100%)`,
          color: '#fff', padding: '14px 14px 12px', position: 'relative', overflow: 'hidden',
          fontFamily: SG.font,
        }}>
          <div style={{ position: 'absolute', top: 10, right: 10, opacity: 0.45 }}>
            <svg width="54" height="54" viewBox="0 0 54 54">
              <rect x="0"  y="0"  width="14" height="46" rx="3" fill="rgba(255,255,255,0.18)"/>
              <rect x="20" y="0"  width="14" height="30" rx="3" fill="rgba(255,255,255,0.18)"/>
              <rect x="40" y="0"  width="14" height="36" rx="3" fill="rgba(255,255,255,0.18)"/>
            </svg>
          </div>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '4px 9px', background: 'rgba(255,255,255,0.12)', borderRadius: 999,
            fontSize: 10, fontWeight: 700, letterSpacing: 0.5, textTransform: 'uppercase',
          }}>
            <Icon name="kanban" size={12}/> Tablero kanban
          </div>
          <div style={{
            fontFamily: SG.fontDisplay, fontSize: 22, fontWeight: 700, lineHeight: 1.1,
            letterSpacing: -0.4, marginTop: 8,
          }}>Actividades municipales</div>
          <div style={{ fontSize: 11.5, opacity: 0.8, marginTop: 4 }}>12 actividades · 4 estados</div>
          <div style={{
            marginTop: 12, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6,
          }}>
            {columns.map(c => (
              <div key={c.id} style={{
                padding: '8px 8px', borderRadius: 9, background: 'rgba(255,255,255,0.08)',
                border: '1px solid rgba(255,255,255,0.10)',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <span style={{ width: 6, height: 6, borderRadius: 99, background: c.color }}/>
                  <span style={{ fontSize: 9.5, opacity: 0.75, textTransform: 'uppercase', letterSpacing: 0.3, fontWeight: 700 }}>{c.label}</span>
                </div>
                <div style={{ fontFamily: SG.fontDisplay, fontSize: 20, fontWeight: 700, marginTop: 4 }}>{c.count}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Search + filters */}
        <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
          <div style={{
            flex: 1, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'flex', alignItems: 'center',
            gap: 7, padding: '0 12px',
          }}>
            <Icon name="search" size={15} color={SG.ink3}/>
            <span style={{ fontSize: 12.5, color: SG.ink3, fontFamily: SG.font }}>Buscar actividades…</span>
          </div>
          <button style={{
            width: 40, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'grid', placeItems: 'center',
            color: SG.ink2,
          }}><Icon name="filter" size={17}/></button>
        </div>

        <div style={{ display: 'flex', gap: 6, marginTop: 8, overflowX: 'auto' }}>
          {[
            { k: 'Tipo', v: 'Todos' },
            { k: 'Depto.', v: 'Todos' },
            { k: 'Fecha', v: 'Cualquiera' },
          ].map(f => (
            <div key={f.k} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5, padding: '5px 10px',
              borderRadius: 999, background: '#fff', border: `1px solid ${SG.border}`,
              fontSize: 11, color: SG.ink2, fontFamily: SG.font,
              whiteSpace: 'nowrap', flexShrink: 0, fontWeight: 500,
            }}>
              <span style={{ color: SG.ink3 }}>{f.k}:</span>
              <span style={{ color: SG.ink, fontWeight: 600 }}>{f.v}</span>
              <Icon name="chevDn" size={11}/>
            </div>
          ))}
        </div>

        {/* Column switcher (segmented) */}
        <div style={{
          marginTop: 14, padding: 4, background: '#F1ECE3', borderRadius: 12,
          display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 4, fontFamily: SG.font,
        }}>
          {columns.map((c, i) => {
            const a = i === 0;
            return (
              <button key={c.id} style={{
                padding: '7px 4px', borderRadius: 9, border: 'none',
                background: a ? '#fff' : 'transparent',
                color: a ? SG.ink : SG.ink3,
                fontSize: 11.5, fontWeight: 700,
                boxShadow: a ? SG.shadowSm : 'none',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 1,
              }}>
                <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                  <span style={{ width: 6, height: 6, borderRadius: 99, background: c.color }}/>
                  {c.label}
                </span>
                <span style={{ fontSize: 9.5, color: SG.ink3, fontWeight: 600 }}>{c.count} act.</span>
              </button>
            );
          })}
        </div>

        {/* Active column heading + new btn */}
        <div style={{
          marginTop: 14, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          fontFamily: SG.font,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 8, height: 8, borderRadius: 99, background: primary.color }}/>
            <span style={{ fontSize: 14, fontWeight: 700, color: SG.ink, letterSpacing: -0.1 }}>{primary.label}</span>
            <span style={{
              fontSize: 11, fontWeight: 700, color: SG.ink3,
              background: SG.graySoft, padding: '1px 7px', borderRadius: 999,
            }}>{primary.count}</span>
          </div>
          <button style={{
            height: 32, padding: '0 11px', borderRadius: 9, border: 'none',
            background: SG.orange, color: '#fff', fontWeight: 600, fontSize: 11.5,
            display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: SG.font,
          }}><Icon name="plus" size={13} color="#fff"/> Nueva</button>
        </div>

        {/* Cards stream for active column */}
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {primary.cards.map((c, i) => <ActivityCard key={i} card={c} accent={primary.color}/>)}
          <button style={{
            padding: '10px', borderRadius: 11, border: `1.5px dashed ${SG.borderStrong}`,
            background: 'transparent', color: SG.ink3, fontWeight: 600, fontFamily: SG.font, fontSize: 12,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}><Icon name="plus" size={13}/> Agregar actividad</button>
        </div>

        {/* Peek of other columns */}
        <div style={{ marginTop: 18 }}>
          <SectionHead title="Otros estados" right="Desliza para ver más"/>
          <div style={{
            display: 'flex', gap: 10, overflowX: 'auto', paddingBottom: 4,
            margin: '0 -14px', padding: '0 14px 4px',
          }}>
            {rest.map(col => (
              <div key={col.id} style={{
                minWidth: 260, maxWidth: 260, padding: 12, borderRadius: 13,
                background: col.bg, border: `1px solid ${SG.border}`, flexShrink: 0,
              }}>
                <div style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  marginBottom: 10, fontFamily: SG.font,
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <span style={{ width: 7, height: 7, borderRadius: 99, background: col.color }}/>
                    <span style={{ fontSize: 11.5, fontWeight: 700, color: SG.ink, textTransform: 'uppercase', letterSpacing: 0.3 }}>{col.label}</span>
                    <span style={{
                      fontSize: 10.5, fontWeight: 700, color: SG.ink3,
                      background: 'rgba(255,255,255,0.7)', padding: '1px 6px', borderRadius: 999,
                    }}>{col.count}</span>
                  </div>
                  <Icon name="plus" size={14} color={SG.ink3}/>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
                  {col.cards.slice(0, 2).map((c, i) => <MiniActivityCard key={i} card={c}/>)}
                  {col.cards.length > 2 && (
                    <div style={{
                      padding: '7px 9px', fontSize: 11, color: SG.ink3, fontFamily: SG.font,
                      textAlign: 'center', fontWeight: 600,
                    }}>+ {col.cards.length - 2} más</div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <BottomTabs active="actividades"/>
    </div>
  );
}

function ActivityCard({ card, accent }) {
  return (
    <div style={{
      position: 'relative', background: '#fff', borderRadius: 12,
      border: `1px solid ${SG.border}`, padding: '11px 12px 11px 14px',
      fontFamily: SG.font, overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: accent }}/>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <TypeBadge type={card.tipo}/>
        <div style={{ flex: 1 }}/>
        <SectorBadge code={card.sector}/>
      </div>
      <div style={{
        marginTop: 7, fontSize: 13, fontWeight: 600, color: SG.ink,
        letterSpacing: -0.1, lineHeight: 1.3,
      }}>{card.title}</div>
      <div style={{
        marginTop: 7, display: 'flex', alignItems: 'center', gap: 10, fontSize: 11, color: SG.ink3,
        flexWrap: 'wrap',
      }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon name="calendar" size={11}/> {card.date}
        </span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon name="clock" size={11}/> {card.time}
        </span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon name="people" size={11}/> {card.part} part.
        </span>
      </div>
      <div style={{
        marginTop: 5, display: 'inline-flex', alignItems: 'center', gap: 4,
        fontSize: 11, color: card.where === 'Sin ubicación' ? SG.ink4 : SG.ink2,
        fontStyle: card.where === 'Sin ubicación' ? 'italic' : 'normal',
      }}>
        <Icon name="pin" size={11}/> {card.where}
      </div>
    </div>
  );
}

function MiniActivityCard({ card }) {
  return (
    <div style={{
      background: '#fff', borderRadius: 9, padding: '8px 10px',
      border: `1px solid ${SG.border}`, fontFamily: SG.font,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <TypeBadge type={card.tipo}/>
        <div style={{ flex: 1 }}/>
        <SectorBadge code={card.sector}/>
      </div>
      <div style={{
        marginTop: 6, fontSize: 11.5, fontWeight: 600, color: SG.ink, lineHeight: 1.3,
        display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden',
      }}>{card.title}</div>
      <div style={{ marginTop: 5, fontSize: 10, color: SG.ink3, display: 'flex', gap: 6 }}>
        <span>{card.date}</span><span>·</span><span>{card.time}</span>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenActividades });
