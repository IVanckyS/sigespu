// Resumen — Dashboard / Summary mobile view
function ScreenResumen() {
  const kpis = [
    { icon: 'pin',  label: 'Reportes este mes',     value: '8',  trend: '+12% vs mes anterior',  tint: '#FFEDD5', ink: '#9A3412', dir: 'up' },
    { icon: 'warn', label: 'Zonas de peligro',      value: '5',  trend: '3 nuevas esta semana',  tint: '#FEE2E2', ink: '#991B1B', dir: 'up' },
    { icon: 'store',label: 'Patentes nuevas (mes)', value: '15', trend: 'scraping · hace 3h',    tint: '#DCFCE7', ink: '#166534', dir: 'flat' },
    { icon: 'house',label: 'Centros de acopio',     value: '3',  trend: 'Listos para emergencias', tint: '#DBEAFE', ink: '#1E40AF', dir: 'flat' },
    { icon: 'people',label:'Sedes comunitarias',    value: '3',  trend: 'Activas e identificadas', tint: '#F3E8FF', ink: '#6B21A8', dir: 'flat' },
  ];
  const sectors = [
    { code: 'S-2', name: 'Residencial Los Aromos', meta: '2 zonas · 3 reportes', pct: 60 },
    { code: 'S-3', name: 'Mixto Los Aromos',       meta: '1 zona · 2 reportes',  pct: 40 },
    { code: 'S-4', name: 'Equipamiento',           meta: '0 zonas · 0 reportes', pct: 0  },
    { code: 'S-5', name: 'Vivienda Periférica',    meta: '2 zonas · 1 reporte',  pct: 30 },
    { code: 'Centro', name: 'Centro Histórico Lota', meta: '2 zonas · 5 reportes', pct: 100 },
  ];
  // donut: 40 vandalismo, 40 robo, 20 accidente
  const donut = [
    { label: 'Vandalismo', value: 40, color: '#A855F7', count: 2 },
    { label: 'Robo',       value: 40, color: '#DC2626', count: 2 },
    { label: 'Accidente',  value: 20, color: '#F97316', count: 1 },
  ];

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
      <AppTopBar exportAction={{ label: 'Exportar PDF', icon: 'pdf', sub: 'Resumen operativo' }}/>

      <div style={{ flex: 1, overflow: 'auto', padding: '12px 14px 100px' }}>
        <Hero
          kicker="Vista · Resumen operativo"
          kickerIcon="grid"
          title="Dirección de Seguridad Pública"
          subtitle="Indicadores clave y últimos registros · Actualizado: 17 may 2026, 11:05"
          stats={[
            { value: 8, label: 'Reportes' },
            { value: 5, label: 'Zonas activas' },
            { value: 15, label: 'Patentes (mes)' },
            { value: 3, label: 'C. acopio' },
          ]}
          cornerPattern="tiles"
        />

        {/* KPI grid 2 cols */}
        <div style={{ marginTop: 16 }}>
          <SectionHead title="Indicadores" right="últimos 30 días"/>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {kpis.slice(0, 4).map((k, i) => (
              <Card key={i} pad={12}>
                <div style={{
                  width: 32, height: 32, borderRadius: 10, background: k.tint, color: k.ink,
                  display: 'grid', placeItems: 'center', marginBottom: 8,
                }}><Icon name={k.icon} size={17}/></div>
                <div style={{ fontSize: 10.5, color: SG.ink3, lineHeight: 1.25, minHeight: 26 }}>{k.label}</div>
                <div style={{ fontFamily: SG.fontDisplay, fontSize: 24, fontWeight: 700, color: SG.ink, letterSpacing: -0.5, marginTop: 2 }}>{k.value}</div>
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: 4, marginTop: 6,
                  fontSize: 10, color: k.dir === 'up' ? SG.red : k.dir === 'down' ? SG.green : SG.green, fontWeight: 600,
                }}>
                  <Icon name={k.dir === 'up' ? 'arrowSm' : k.dir === 'down' ? 'arrowSmDn' : 'arrowSm'} size={11}/>
                  {k.trend}
                </div>
              </Card>
            ))}
          </div>
          {/* 5th KPI full width */}
          <div style={{ marginTop: 10 }}>
            <Card pad={12}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <div style={{
                  width: 36, height: 36, borderRadius: 10, background: kpis[4].tint, color: kpis[4].ink,
                  display: 'grid', placeItems: 'center',
                }}><Icon name={kpis[4].icon} size={18}/></div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 11, color: SG.ink3 }}>{kpis[4].label}</div>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
                    <div style={{ fontFamily: SG.fontDisplay, fontSize: 22, fontWeight: 700, color: SG.ink, letterSpacing: -0.5 }}>{kpis[4].value}</div>
                    <div style={{ fontSize: 10.5, color: SG.green, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 3 }}>
                      <Icon name="arrowSm" size={11}/> {kpis[4].trend}
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          </div>
        </div>

        {/* Reportes por tipo donut */}
        <div style={{ marginTop: 18 }}>
          <SectionHead title="Reportes por tipo" right="últimos 30 días"/>
          <Card pad={14}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <Donut data={donut} size={130}/>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
                {donut.map((d, i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                    <span style={{ width: 9, height: 9, borderRadius: 99, background: d.color, flexShrink: 0 }}/>
                    <div style={{ flex: 1, fontSize: 12, color: SG.ink2, fontWeight: 500 }}>{d.label}</div>
                    <div style={{ fontSize: 12, color: SG.ink, fontWeight: 700, fontFamily: SG.fontDisplay }}>{d.count}</div>
                    <div style={{ fontSize: 10.5, color: SG.ink3, width: 30, textAlign: 'right' }}>{d.value}%</div>
                  </div>
                ))}
              </div>
            </div>
          </Card>
        </div>

        {/* Zonas por sector */}
        <div style={{ marginTop: 18 }}>
          <SectionHead title="Zonas por sector" right="Plan Regulador"/>
          <Card pad={4}>
            {sectors.map((s, i) => (
              <div key={s.code} style={{
                display: 'flex', alignItems: 'center', gap: 10, padding: '10px 10px',
                borderBottom: i < sectors.length - 1 ? `1px solid ${SG.border}` : 'none',
              }}>
                <SectorBadge code={s.code}/>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 12.5, fontWeight: 600, color: SG.ink, lineHeight: 1.2 }}>{s.name}</div>
                  <div style={{ fontSize: 10.5, color: SG.ink3, marginTop: 2 }}>{s.meta}</div>
                </div>
                <div style={{ width: 56, height: 6, borderRadius: 99, background: SG.graySoft, position: 'relative' }}>
                  <div style={{ position: 'absolute', inset: 0, width: `${s.pct}%`, background: SG.orange, borderRadius: 99 }}/>
                </div>
              </div>
            ))}
          </Card>
        </div>
      </div>

      <BottomTabs active="resumen"/>
    </div>
  );
}

// Donut chart — pure SVG
function Donut({ data, size = 120 }) {
  const r = size / 2 - 14;
  const cx = size / 2, cy = size / 2;
  const C = 2 * Math.PI * r;
  let offset = 0;
  const stroke = 18;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ flexShrink: 0 }}>
      <circle cx={cx} cy={cy} r={r} fill="none" stroke={SG.graySoft} strokeWidth={stroke}/>
      {data.map((d, i) => {
        const len = (d.value / 100) * C;
        const el = (
          <circle key={i} cx={cx} cy={cy} r={r} fill="none"
            stroke={d.color} strokeWidth={stroke}
            strokeDasharray={`${len} ${C - len}`}
            strokeDashoffset={-offset}
            transform={`rotate(-90 ${cx} ${cy})`}
            strokeLinecap="butt"
          />
        );
        offset += len;
        return el;
      })}
      <text x={cx} y={cy - 2} textAnchor="middle" fontSize="11" fill={SG.ink3} fontFamily={SG.font}>Total</text>
      <text x={cx} y={cy + 14} textAnchor="middle" fontSize="20" fontWeight="700" fill={SG.ink} fontFamily={SG.fontDisplay}>5</text>
    </svg>
  );
}

Object.assign(window, { ScreenResumen });
