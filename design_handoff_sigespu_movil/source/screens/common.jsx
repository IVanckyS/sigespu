// Shared tokens, primitives and chrome for SIGESPU mobile screens.
// All components attach to window so other Babel scripts can read them.

const SG = {
  // page
  bg: '#FAF7F2',           // warm offwhite page bg
  surface: '#FFFFFF',
  border: 'rgba(28,25,23,0.08)',
  borderStrong: 'rgba(28,25,23,0.14)',
  // ink
  ink: '#1C1917',
  ink2: '#44403C',
  ink3: '#78716C',
  ink4: '#A8A29E',
  // brand
  orange: '#EA580C',
  orangeDeep: '#C2410C',
  orangeSoft: '#FFF4EC',
  // status
  green: '#16A34A',
  greenSoft: '#DCFCE7',
  greenInk: '#166534',
  yellow: '#CA8A04',
  yellowSoft: '#FEF3C7',
  yellowInk: '#92400E',
  red: '#DC2626',
  redSoft: '#FEE2E2',
  redInk: '#991B1B',
  gray: '#6B7280',
  graySoft: '#F3F4F6',
  // sectors (S-2…S-5, Centro)
  sectors: {
    'S-2': { bg: '#DCFCE7', fg: '#166534' },
    'S-3': { bg: '#FEF3C7', fg: '#854D0E' },
    'S-4': { bg: '#FFEDD5', fg: '#9A3412' },
    'S-5': { bg: '#FCE7F3', fg: '#9D174D' },
    'Centro': { bg: '#F5F0E6', fg: '#78350F' },
  },
  // type chips (vandalismo/robo/etc)
  types: {
    Vandalismo:    { bg: '#F3E8FF', fg: '#6B21A8' },
    Robo:          { bg: '#FEE2E2', fg: '#991B1B' },
    'Árbol caído': { bg: '#DCFCE7', fg: '#166534' },
    'Poste caído': { bg: '#FFEDD5', fg: '#9A3412' },
    'Cable colgando': { bg: '#FEF3C7', fg: '#854D0E' },
    Accidente:     { bg: '#FFEDD5', fg: '#9A3412' },
    Reunión:       { bg: '#EDE9FE', fg: '#5B21B6' },
    Operativo:     { bg: '#FFEDD5', fg: '#9A3412' },
    Capacitación:  { bg: '#CCFBF1', fg: '#115E59' },
    Evento:        { bg: '#DCFCE7', fg: '#166534' },
  },
  // shadows
  shadowSm: '0 1px 2px rgba(28,25,23,0.04), 0 1px 1px rgba(28,25,23,0.03)',
  shadow:   '0 1px 3px rgba(28,25,23,0.06), 0 4px 12px rgba(28,25,23,0.04)',
  radius: { sm: 8, md: 12, lg: 16, xl: 20, pill: 9999 },
  font: '-apple-system, "SF Pro Text", "Helvetica Neue", system-ui, sans-serif',
  fontDisplay: '-apple-system, "SF Pro Display", "Helvetica Neue", system-ui, sans-serif',
};

// ─────────────────────────────────────────────────────────────
// Tiny SVG icon set (stroke-based, 1.6px). Pass {size, color}.
// ─────────────────────────────────────────────────────────────
function Icon({ name, size = 18, color = 'currentColor', strokeWidth = 1.6 }) {
  const p = { fill: 'none', stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    home: <path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1Z" {...p}/>,
    map: <><path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2-6-2Z" {...p}/><path d="M9 4v14M15 6v14" {...p}/></>,
    grid: <><rect x="3" y="3" width="7" height="7" rx="1" {...p}/><rect x="14" y="3" width="7" height="7" rx="1" {...p}/><rect x="3" y="14" width="7" height="7" rx="1" {...p}/><rect x="14" y="14" width="7" height="7" rx="1" {...p}/></>,
    table: <><rect x="3" y="4" width="18" height="16" rx="2" {...p}/><path d="M3 10h18M3 15h18M10 4v16" {...p}/></>,
    download: <><path d="M12 4v12m0 0-4-4m4 4 4-4M5 20h14" {...p}/></>,
    users: <><circle cx="9" cy="8" r="3.2" {...p}/><path d="M3.5 20c.6-3 3-5 5.5-5s4.9 2 5.5 5" {...p}/><circle cx="17" cy="9" r="2.6" {...p}/><path d="M15 14c2.5 0 4.5 1.6 5.2 4" {...p}/></>,
    kanban: <><rect x="3" y="4" width="6" height="16" rx="1.5" {...p}/><rect x="11" y="4" width="6" height="10" rx="1.5" {...p}/><rect x="19" y="4" width="2" height="14" rx="1" {...p}/></>,
    search: <><circle cx="11" cy="11" r="6" {...p}/><path d="m20 20-4.3-4.3" {...p}/></>,
    filter: <path d="M4 5h16l-6 8v6l-4-2v-4L4 5Z" {...p}/>,
    pin: <><path d="M12 22s7-6.5 7-12a7 7 0 0 0-14 0c0 5.5 7 12 7 12Z" {...p}/><circle cx="12" cy="10" r="2.5" {...p}/></>,
    warn: <><path d="M12 3 2.5 20h19L12 3Z" {...p}/><path d="M12 10v5M12 18v.5" {...p}/></>,
    store: <><path d="M4 9h16v11H4zM4 9l2-5h12l2 5" {...p}/><path d="M9 14h6" {...p}/></>,
    house: <path d="M3 11 12 4l9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1Z" {...p}/>,
    people: <><circle cx="9" cy="9" r="3" {...p}/><path d="M3 20c.7-3.4 3-5 6-5s5.3 1.6 6 5" {...p}/><circle cx="17" cy="7" r="2.5" {...p}/><path d="M15 13c2.5 0 5 1.4 5.5 4.5" {...p}/></>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2" {...p}/><path d="M3 10h18M8 3v4M16 3v4" {...p}/></>,
    clock: <><circle cx="12" cy="12" r="8.5" {...p}/><path d="M12 7v5l3.5 2" {...p}/></>,
    bell: <><path d="M6 16V11a6 6 0 0 1 12 0v5l1.5 2H4.5L6 16Z" {...p}/><path d="M10 21a2 2 0 0 0 4 0" {...p}/></>,
    plus: <path d="M12 5v14M5 12h14" {...p}/>,
    chev: <path d="m9 6 6 6-6 6" {...p}/>,
    chevDn: <path d="m6 9 6 6 6-6" {...p}/>,
    close: <path d="M6 6l12 12M18 6 6 18" {...p}/>,
    menu: <path d="M4 7h16M4 12h16M4 17h16" {...p}/>,
    arrowUp: <path d="M5 12l7-7 7 7M12 5v15" {...p}/>,
    arrowDn: <path d="M5 12l7 7 7-7M12 19V4" {...p}/>,
    arrowSm: <path d="M7 17 17 7M9 7h8v8" {...p}/>,
    arrowSmDn: <path d="M17 7 7 17M7 9v8h8" {...p}/>,
    shield: <path d="M12 3 4 6v6c0 4.5 3.3 7.8 8 9 4.7-1.2 8-4.5 8-9V6l-8-3Z" {...p}/>,
    logout: <><path d="M14 4h5a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1h-5" {...p}/><path d="M10 8 4 12l6 4M4 12h12" {...p}/></>,
    refresh: <path d="M4 12a8 8 0 0 1 14-5.3L21 8M20 12a8 8 0 0 1-14 5.3L3 16M21 4v4h-4M3 20v-4h4" {...p}/>,
    cloud: <><path d="M7 18a4 4 0 1 1 .8-7.9A6 6 0 0 1 18.5 12a3.5 3.5 0 1 1-.5 7H7Z" {...p}/></>,
    edit: <><path d="M4 20h4l10-10-4-4L4 16v4Z" {...p}/><path d="m13 6 4 4" {...p}/></>,
    trash: <><path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13" {...p}/></>,
    toggleOn: <><rect x="2" y="6" width="20" height="12" rx="6" fill={color} stroke="none"/><circle cx="16" cy="12" r="4" fill="#fff"/></>,
    pencil: <><path d="M4 20h4l10-10-4-4L4 16v4Z" {...p}/></>,
    dot: <circle cx="12" cy="12" r="3" fill={color} stroke="none"/>,
    flask: <><path d="M9 3h6M10 3v6L5 19a2 2 0 0 0 1.8 3h10.4A2 2 0 0 0 19 19l-5-10V3" {...p}/></>,
    bolt: <path d="m13 3-8 11h6l-1 7 8-11h-6l1-7Z" {...p}/>,
    moreH: <><circle cx="6" cy="12" r="1.5" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.5" fill={color} stroke="none"/><circle cx="18" cy="12" r="1.5" fill={color} stroke="none"/></>,
    moreV: <><circle cx="12" cy="6" r="1.5" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.5" fill={color} stroke="none"/><circle cx="12" cy="18" r="1.5" fill={color} stroke="none"/></>,
    check: <path d="m5 12 5 5 9-11" {...p}/>,
    sortDn: <><path d="M7 4v16m0 0-3-3m3 3 3-3M14 6h6M14 11h5M14 16h4M14 21h3" {...p}/></>,
    pdf: <><rect x="5" y="3" width="14" height="18" rx="2" {...p}/><path d="M9 12h6M9 16h6M9 8h3" {...p}/></>,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" {...p}/><circle cx="12" cy="12" r="2.8" {...p}/></>,
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block', flexShrink: 0 }}>
      {paths[name]}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Lota crest — small SVG mark
// ─────────────────────────────────────────────────────────────
function LotaCrest({ size = 28 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" style={{ display: 'block' }}>
      <rect width="32" height="32" rx="7" fill={SG.ink}/>
      <path d="M5 22h22" stroke={SG.orange} strokeWidth="2.2" strokeLinecap="round"/>
      <path d="M5 22c2-6 6-9 11-9s9 3 11 9" fill={SG.orange}/>
      <circle cx="22.5" cy="13" r="2" fill="#fff"/>
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Phone status bar (iOS-ish, but we draw it light/dark)
// ─────────────────────────────────────────────────────────────
function StatusBar({ dark = false, time = '11:05' }) {
  const c = dark ? '#fff' : SG.ink;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '14px 28px 6px', height: 44, boxSizing: 'border-box',
      fontFamily: SG.font, fontWeight: 600, fontSize: 15, color: c,
    }}>
      <span>{time}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <svg width="17" height="11" viewBox="0 0 17 11"><g fill={c}>
          <rect x="0" y="7" width="3" height="4" rx="0.6"/>
          <rect x="4.5" y="5" width="3" height="6" rx="0.6"/>
          <rect x="9" y="2.5" width="3" height="8.5" rx="0.6"/>
          <rect x="13.5" y="0" width="3" height="11" rx="0.6"/>
        </g></svg>
        <svg width="15" height="11" viewBox="0 0 15 11" fill={c}>
          <path d="M7.5 2.8c2 0 3.9.8 5.2 2.2l1-1A8 8 0 0 0 1.3 4l1 1a7 7 0 0 1 5.2-2.2Z"/>
          <path d="M7.5 6.2c1.2 0 2.3.5 3.1 1.3l1-1A6 6 0 0 0 3.4 6.5l1 1a4.4 4.4 0 0 1 3.1-1.3Z"/>
          <circle cx="7.5" cy="9.3" r="1.2"/>
        </svg>
        <svg width="25" height="12" viewBox="0 0 25 12">
          <rect x="0.5" y="0.5" width="21" height="11" rx="3" fill="none" stroke={c} strokeOpacity="0.4"/>
          <rect x="2" y="2" width="18" height="8" rx="1.5" fill={c}/>
          <path d="M22.5 4v4c.7-.3 1.3-1 1.3-2s-.6-1.7-1.3-2Z" fill={c} fillOpacity="0.5"/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// App top bar — logo + name + contextual export + avatar
// `exportAction` is an object {label, icon, sub?} that changes per view.
// ─────────────────────────────────────────────────────────────
function AppTopBar({ exportAction = { label: 'Exportar PDF', icon: 'pdf', sub: 'vista actual' } }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10, padding: '8px 14px 10px',
      background: '#FFFFFF', borderBottom: `1px solid ${SG.border}`,
    }}>
      <LotaCrest size={32}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: SG.fontDisplay, fontSize: 14.5, fontWeight: 700, color: SG.ink, letterSpacing: -0.1,
          display: 'flex', alignItems: 'center', gap: 6,
        }}>
          SIGESPU Lota
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 4, padding: '2px 6px',
            background: '#DCFCE7', color: '#166534', borderRadius: 999,
            fontSize: 9.5, fontWeight: 600, fontFamily: SG.font,
          }}>
            <span style={{ width: 5, height: 5, background: '#16A34A', borderRadius: 99 }}/>
            En línea
          </span>
        </div>
        <div style={{ fontFamily: SG.font, fontSize: 10.5, color: SG.ink3, marginTop: 1 }}>I. Municipalidad de Lota</div>
      </div>
      <button title={exportAction.sub} style={{
        height: 34, padding: '0 10px 0 8px', borderRadius: 10, border: `1px solid ${SG.border}`,
        background: '#fff', color: SG.ink, fontWeight: 600, fontSize: 11.5, fontFamily: SG.font,
        display: 'inline-flex', alignItems: 'center', gap: 5,
      }}><Icon name={exportAction.icon} size={14}/> {exportAction.label}</button>
      <div style={{
        width: 34, height: 34, borderRadius: 999, background: SG.orange,
        display: 'grid', placeItems: 'center', color: '#fff', fontSize: 11.5, fontWeight: 700, fontFamily: SG.font,
        position: 'relative',
      }}>
        AD
        <span style={{
          position: 'absolute', bottom: -1, right: -1, width: 11, height: 11, borderRadius: 99,
          background: SG.ink, color: '#fff', fontSize: 7, display: 'grid', placeItems: 'center',
          border: '1.5px solid #fff',
        }}><Icon name="chevDn" size={6} color="#fff"/></span>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Bottom tab bar — 5 sections (Usuarios lives in the avatar menu)
// ─────────────────────────────────────────────────────────────
function BottomTabs({ active = 'resumen' }) {
  const items = [
    { id: 'mapa', label: 'Mapa', icon: 'map' },
    { id: 'resumen', label: 'Resumen', icon: 'grid' },
    { id: 'tabla', label: 'Tabla', icon: 'table' },
    { id: 'scraping', label: 'Scraping', icon: 'download' },
    { id: 'actividades', label: 'Actividad', icon: 'kanban', badge: 12 },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      background: 'rgba(255,255,255,0.95)',
      backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      borderTop: `1px solid ${SG.border}`,
      padding: '10px 8px 22px',
      display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)',
      fontFamily: SG.font,
    }}>
      {items.map(it => {
        const a = active === it.id;
        return (
          <div key={it.id} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            color: a ? SG.orange : SG.ink3, position: 'relative',
          }}>
            <div style={{ position: 'relative' }}>
              <Icon name={it.icon} size={22}/>
              {it.badge && (
                <span style={{
                  position: 'absolute', top: -4, right: -10,
                  background: SG.orange, color: '#fff', fontSize: 9, fontWeight: 700,
                  padding: '1px 4px', borderRadius: 999, minWidth: 14, textAlign: 'center',
                }}>{it.badge}</span>
              )}
            </div>
            <span style={{ fontSize: 10, fontWeight: a ? 700 : 500, letterSpacing: -0.1 }}>{it.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Badge / pill primitives
// ─────────────────────────────────────────────────────────────
function Pill({ children, bg, fg, dot, style = {} }) {
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      padding: '2px 8px', borderRadius: 999, background: bg, color: fg,
      fontSize: 10.5, fontWeight: 600, fontFamily: SG.font, lineHeight: 1.5,
      whiteSpace: 'nowrap', ...style,
    }}>
      {dot && <span style={{ width: 5, height: 5, borderRadius: 99, background: fg, display: 'inline-block' }}/>}
      {children}
    </span>
  );
}

function SectorBadge({ code }) {
  const c = SG.sectors[code] || { bg: SG.graySoft, fg: SG.ink2 };
  return <Pill bg={c.bg} fg={c.fg}>{code}</Pill>;
}

function TypeBadge({ type }) {
  const c = SG.types[type] || { bg: SG.graySoft, fg: SG.ink2 };
  return <Pill bg={c.bg} fg={c.fg}>{type}</Pill>;
}

function StatusBadge({ status }) {
  const map = {
    'Activo':     { bg: SG.greenSoft, fg: SG.greenInk },
    'En revisión':{ bg: SG.yellowSoft, fg: SG.yellowInk },
    'Cerrado':    { bg: SG.graySoft, fg: SG.ink2 },
  };
  const c = map[status] || map['Activo'];
  return <Pill bg={c.bg} fg={c.fg} dot>{status}</Pill>;
}

// ─────────────────────────────────────────────────────────────
// Hero card — large branded header
// ─────────────────────────────────────────────────────────────
function Hero({ kicker, kickerIcon = 'grid', title, subtitle, stats, variant = 'orange', cornerPattern = 'tiles' }) {
  const themes = {
    orange: {
      bg: `linear-gradient(135deg, ${SG.orange} 0%, ${SG.orangeDeep} 100%)`,
      kickerBg: 'rgba(255,255,255,0.18)',
    },
    dark: {
      bg: `linear-gradient(135deg, #1C1917 0%, #292524 100%)`,
      kickerBg: 'rgba(255,255,255,0.10)',
    },
    maroon: {
      bg: `linear-gradient(135deg, #1C1917 0%, #7C2D12 100%)`,
      kickerBg: 'rgba(255,255,255,0.14)',
    },
  };
  const t = themes[variant];
  return (
    <div style={{
      borderRadius: 18, background: t.bg, padding: '14px 14px 12px',
      color: '#fff', position: 'relative', overflow: 'hidden',
      fontFamily: SG.font, boxShadow: '0 8px 20px rgba(234,88,12,0.18)',
    }}>
      {/* corner ornament */}
      <div style={{ position: 'absolute', top: 10, right: 10, opacity: 0.5 }}>
        {cornerPattern === 'tiles' && (
          <svg width="58" height="58" viewBox="0 0 58 58" fill="rgba(255,255,255,0.22)">
            <rect x="0" y="0" width="16" height="16" rx="3"/>
            <rect x="20" y="0" width="16" height="16" rx="3"/>
            <rect x="0" y="20" width="16" height="16" rx="3"/>
            <rect x="40" y="20" width="16" height="16" rx="3"/>
            <rect x="20" y="40" width="16" height="16" rx="3"/>
            <rect x="40" y="40" width="16" height="16" rx="3"/>
          </svg>
        )}
        {cornerPattern === 'lines' && (
          <svg width="58" height="58" viewBox="0 0 58 58" stroke="rgba(255,255,255,0.35)" strokeWidth="3" strokeLinecap="round">
            <path d="M6 12h46M6 24h46M6 36h46M6 48h46"/>
          </svg>
        )}
        {cornerPattern === 'shield' && (
          <svg width="64" height="64" viewBox="0 0 64 64" fill="none" stroke="rgba(255,255,255,0.35)" strokeWidth="2.4">
            <path d="M32 6 10 14v18c0 12 9 22 22 26 13-4 22-14 22-26V14L32 6Z"/>
          </svg>
        )}
        {cornerPattern === 'download' && (
          <svg width="48" height="48" viewBox="0 0 48 48" fill="rgba(255,255,255,0.30)">
            <circle cx="24" cy="24" r="20"/>
            <path d="M24 12v16m0 0-6-6m6 6 6-6M14 36h20" stroke="#fff" strokeWidth="2.2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </div>

      <div style={{
        display: 'inline-flex', alignItems: 'center', gap: 6,
        padding: '4px 9px', background: t.kickerBg, borderRadius: 999,
        fontSize: 10, fontWeight: 700, letterSpacing: 0.5, textTransform: 'uppercase',
      }}>
        <Icon name={kickerIcon} size={12}/>
        {kicker}
      </div>
      <div style={{
        fontFamily: SG.fontDisplay, fontSize: 22, fontWeight: 700,
        lineHeight: 1.15, marginTop: 8, letterSpacing: -0.4, maxWidth: '78%',
      }}>{title}</div>
      {subtitle && (
        <div style={{ fontSize: 11.5, opacity: 0.85, marginTop: 4, maxWidth: '88%', lineHeight: 1.4 }}>
          {subtitle}
        </div>
      )}
      {stats && (
        <div style={{
          display: 'grid', gridTemplateColumns: `repeat(${stats.length}, 1fr)`,
          gap: 6, marginTop: 12,
        }}>
          {stats.map((s, i) => (
            <div key={i}>
              <div style={{ fontFamily: SG.fontDisplay, fontSize: 22, fontWeight: 700, letterSpacing: -0.5, lineHeight: 1 }}>{s.value}</div>
              <div style={{ fontSize: 10.5, opacity: 0.85, marginTop: 3, lineHeight: 1.2 }}>{s.label}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Section header (in-page)
// ─────────────────────────────────────────────────────────────
function SectionHead({ title, right }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
      padding: '4px 4px 8px', fontFamily: SG.font,
    }}>
      <div style={{ fontSize: 13.5, fontWeight: 700, color: SG.ink, letterSpacing: -0.1 }}>{title}</div>
      {right && <div style={{ fontSize: 11, color: SG.ink3 }}>{right}</div>}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────
function Card({ children, style = {}, pad = 14 }) {
  return (
    <div style={{
      background: '#fff', border: `1px solid ${SG.border}`, borderRadius: 14,
      padding: pad, boxShadow: SG.shadowSm, fontFamily: SG.font, ...style,
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Phone container — exact 402x874 frame with status bar, no nav title.
// ─────────────────────────────────────────────────────────────
function Phone({ children, dark = false, statusTime = '11:05' }) {
  return (
    <IOSDevice width={402} height={874} dark={dark}>
      {/* Top spacer so content clears the status bar */}
      <div style={{ height: 54 }}/>
      <div style={{
        height: 'calc(874px - 54px)', overflow: 'hidden',
        background: dark ? '#0F0E0D' : SG.bg, position: 'relative',
      }}>
        {children}
      </div>
    </IOSDevice>
  );
}

// ─────────────────────────────────────────────────────────────
// BottomSheet — modal overlay popup with backdrop + drag handle.
// Anchored to the bottom of the phone canvas (position: absolute).
// ─────────────────────────────────────────────────────────────
function BottomSheet({ children, height = 470 }) {
  return (
    <>
      {/* backdrop */}
      <div style={{
        position: 'absolute', inset: 0, background: 'rgba(15,12,10,0.45)',
        backdropFilter: 'blur(2px)', WebkitBackdropFilter: 'blur(2px)', zIndex: 80,
      }}/>
      {/* sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: '#fff', borderTopLeftRadius: 22, borderTopRightRadius: 22,
        boxShadow: '0 -10px 30px rgba(0,0,0,0.18)',
        maxHeight: height, display: 'flex', flexDirection: 'column',
        zIndex: 90, fontFamily: SG.font,
      }}>
        <div style={{ display: 'grid', placeItems: 'center', padding: '8px 0 4px' }}>
          <div style={{ width: 38, height: 4, borderRadius: 99, background: SG.borderStrong }}/>
        </div>
        {children}
      </div>
    </>
  );
}

// ─────────────────────────────────────────────────────────────
// AvatarMenu — dropdown popover anchored to the top-right avatar.
// Holds account/admin shortcuts: profile, Usuarios, Bitácora, Salir.
// ─────────────────────────────────────────────────────────────
function AvatarMenu({ activeItem }) {
  const items = [
    { id: 'perfil',    label: 'Mi perfil',           sub: 'admin@lota.cl · Director',          icon: 'shield' },
    { id: 'usuarios',  label: 'Gestión de usuarios', sub: '4 activos · 0 solicitudes pendientes', icon: 'users', count: 4 },
    { id: 'bitacora',  label: 'Bitácora del sistema',sub: 'Últimos accesos y eventos',         icon: 'clock' },
    { id: 'config',    label: 'Configuración',       sub: 'Geocoding, scraping, notificaciones', icon: 'edit' },
  ];
  return (
    <>
      {/* backdrop */}
      <div style={{
        position: 'absolute', inset: 0, background: 'rgba(15,12,10,0.30)',
        zIndex: 80,
      }}/>
      <div style={{
        position: 'absolute', top: 56, right: 12, width: 280,
        background: '#fff', borderRadius: 14, zIndex: 90,
        boxShadow: '0 16px 40px rgba(0,0,0,0.22), 0 0 0 1px rgba(0,0,0,0.04)',
        fontFamily: SG.font, overflow: 'hidden',
      }}>
        {/* arrow */}
        <div style={{
          position: 'absolute', top: -7, right: 14, width: 14, height: 14,
          background: '#fff', transform: 'rotate(45deg)', borderRadius: 2,
          boxShadow: '-1px -1px 1px rgba(0,0,0,0.03)',
        }}/>
        {/* header (current user) */}
        <div style={{ padding: '14px 14px 12px', display: 'flex', alignItems: 'center', gap: 10, borderBottom: `1px solid ${SG.border}` }}>
          <div style={{
            width: 40, height: 40, borderRadius: 99, background: SG.orange,
            display: 'grid', placeItems: 'center', color: '#fff', fontSize: 13, fontWeight: 700,
          }}>AD</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: SG.ink, letterSpacing: -0.1 }}>Administrador del Sistema</div>
            <div style={{ fontSize: 11, color: SG.ink3, marginTop: 1 }}>Director · Dir. Seguridad Pública</div>
          </div>
        </div>
        {/* items */}
        <div style={{ padding: '6px' }}>
          {items.map(it => {
            const a = activeItem === it.id;
            return (
              <div key={it.id} style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '9px 10px', borderRadius: 9,
                background: a ? SG.orangeSoft : 'transparent',
              }}>
                <div style={{
                  width: 28, height: 28, borderRadius: 8,
                  background: a ? SG.orange : SG.graySoft,
                  color: a ? '#fff' : SG.ink2,
                  display: 'grid', placeItems: 'center', flexShrink: 0,
                }}><Icon name={it.icon} size={14}/></div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 12.5, fontWeight: 600, color: a ? SG.orange : SG.ink, lineHeight: 1.2 }}>{it.label}</div>
                  <div style={{ fontSize: 10.5, color: SG.ink3, marginTop: 1 }}>{it.sub}</div>
                </div>
                {it.count !== undefined && (
                  <span style={{
                    fontSize: 10, fontWeight: 700, padding: '1px 6px', borderRadius: 999,
                    background: a ? SG.orange : SG.graySoft, color: a ? '#fff' : SG.ink3,
                  }}>{it.count}</span>
                )}
                <Icon name="chev" size={12} color={SG.ink4}/>
              </div>
            );
          })}
        </div>
        {/* logout */}
        <div style={{ borderTop: `1px solid ${SG.border}`, padding: '6px' }}>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 10,
            padding: '9px 10px', borderRadius: 9,
          }}>
            <div style={{
              width: 28, height: 28, borderRadius: 8, background: SG.redSoft, color: SG.red,
              display: 'grid', placeItems: 'center', flexShrink: 0,
            }}><Icon name="logout" size={14}/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12.5, fontWeight: 600, color: SG.red }}>Cerrar sesión</div>
              <div style={{ fontSize: 10.5, color: SG.ink3, marginTop: 1 }}>Sesión iniciada hace 25 min</div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

Object.assign(window, { SG, Icon, LotaCrest, StatusBar, AppTopBar, BottomTabs, Pill, SectorBadge, TypeBadge, StatusBadge, Hero, SectionHead, Card, Phone, BottomSheet, AvatarMenu });
