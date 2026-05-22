/* ─────────── App chrome: top bar + sub-header ─────────── */
const { useState } = React;

/* ── Logo SIGESPU + Lota ── */
const Brand = () => (
  <div style={{ display:"flex", alignItems:"center", gap:10 }}>
    <svg viewBox="0 0 80 80" width="34" height="34">
      <circle cx="40" cy="40" r="38" fill="#292524" stroke="#44403C" strokeWidth="1.5"/>
      <path d="M10 48 L10 38 Q10 26 20 26 L60 26 Q70 26 70 38 L70 48 Z" fill="#EA580C"/>
      <rect x="28" y="30" width="6" height="8" rx="1" fill="white" opacity=".9"/>
      <rect x="37" y="30" width="6" height="8" rx="1" fill="white" opacity=".9"/>
      <rect x="46" y="30" width="6" height="8" rx="1" fill="white" opacity=".9"/>
      <path d="M32 26 L40 18 L48 26 Z" fill="#FED7AA"/>
      <circle cx="40" cy="16" r="2.5" fill="#FED7AA"/>
    </svg>
    <div style={{ width:1, height:24, background:"#E7E5E4" }}/>
    <svg viewBox="0 0 80 80" width="28" height="28">
      <rect width="80" height="80" rx="18" fill="#EA580C"/>
      <path d="M40 14 C30 14 22 22 22 32 C22 46 40 66 40 66 C40 66 58 46 58 32 C58 22 50 14 40 14 Z" fill="white"/>
      <circle cx="40" cy="32" r="7" fill="#EA580C"/>
      <circle cx="40" cy="32" r="3" fill="white"/>
    </svg>
    <div>
      <div style={{ fontFamily:"var(--fdis)", fontSize:14, fontWeight:700, color:"var(--s900)", letterSpacing:"-.02em", lineHeight:1.1 }}>SIGESPU Lota</div>
      <div style={{ fontSize:9.5, color:"var(--s500)", textTransform:"uppercase", letterSpacing:".07em", marginTop:1 }}>I. Municipalidad de Lota</div>
    </div>
  </div>
);

/* ── Mode switcher ── */
const MODES = [
  { id:"mapa",         label:"Mapa",         icon:"map" },
  { id:"resumen",      label:"Resumen",      icon:"layoutDashboard" },
  { id:"tabla",        label:"Tabla",        icon:"table" },
  { id:"scraping",     label:"Scraping",     icon:"briefcase" },
  { id:"usuarios",     label:"Usuarios",     icon:"users" },
  { id:"actividades",  label:"Actividades",  icon:"trello" },
];
const ModeCounts = { actividades:13, usuarios:10, tabla:33, scraping:37 };
const ModeSwitcher = ({ active="actividades" }) => {
  const I = window.Icons;
  return (
    <div style={{
      background:"var(--s100)", borderRadius:10, padding:3,
      display:"inline-flex", gap:0
    }}>
      {MODES.map(m => {
        const on = m.id === active;
        const Ic = I[m.icon];
        return (
          <span key={m.id} style={{
            padding:"7px 12px",
            background: on ? "white" : "transparent",
            borderRadius:7,
            display:"flex", alignItems:"center", gap:6,
            fontSize:12, fontWeight: on ? 600 : 500,
            color: on ? "var(--or7)" : "var(--s500)",
            boxShadow: on ? "0 1px 2px rgba(0,0,0,.07)" : "none",
            cursor:"pointer"
          }}>
            <Ic size={13} c={on ? "#C2410C" : "#78716C"}/>
            {m.label}
            {on && ModeCounts[m.id] && (
              <span style={{
                fontSize:9, background:"var(--or2)", color:"var(--or7)",
                padding:"1px 6px", borderRadius:10, fontWeight:700,
                marginLeft:2
              }}>{ModeCounts[m.id]}</span>
            )}
          </span>
        );
      })}
    </div>
  );
};

/* ── Top bar ── */
const TopBar = ({ active="actividades" }) => {
  const I = window.Icons;
  return (
    <div style={{
      background:"#fff", borderBottom:"1px solid var(--s200)",
      padding:"0 20px", display:"flex", alignItems:"center", gap:18,
      height:60, flexShrink:0
    }}>
      <Brand/>
      <ModeSwitcher active={active}/>
      <div style={{ marginLeft:"auto", display:"flex", alignItems:"center", gap:10 }}>
        <div style={{
          display:"inline-flex", alignItems:"center", gap:6,
          padding:"5px 10px", borderRadius:999, background:"var(--c-success-bg)",
          color:"var(--c-success)", fontSize:11, fontWeight:600
        }}>
          <span style={{ width:7, height:7, borderRadius:"50%", background:"#16A34A" }}/>
          En línea · sync 09:42
        </div>
        <button style={{
          width:32, height:32, borderRadius:8, background:"var(--s100)",
          display:"flex", alignItems:"center", justifyContent:"center", position:"relative"
        }}>
          <I.bell size={15} c="#57534E"/>
          <span style={{
            position:"absolute", top:6, right:7, width:7, height:7, borderRadius:"50%",
            background:"#EA580C", border:"1.5px solid white"
          }}/>
        </button>
        <div style={{
          background:"var(--s100)", borderRadius:999,
          display:"flex", alignItems:"center", gap:8, padding:"4px 12px 4px 4px"
        }}>
          <div style={{
            width:26, height:26, borderRadius:"50%",
            background:"#EA580C", color:"white",
            display:"flex", alignItems:"center", justifyContent:"center",
            fontSize:10, fontWeight:700, fontFamily:"var(--fdis)"
          }}>RS</div>
          <div>
            <div style={{ fontSize:11.5, fontWeight:600, lineHeight:1.1 }}>Rodrigo Sandoval</div>
            <div style={{ fontSize:9.5, color:"var(--s500)", letterSpacing:".03em" }}>Coord. Seg. Pública</div>
          </div>
        </div>
      </div>
    </div>
  );
};

/* ── Screen sub-header (toolbar for Actividades) ── */
const ActividadesToolbar = ({ filtroTipo="todos" }) => {
  const I = window.Icons;
  return (
    <div style={{
      background:"#fff", borderBottom:"1px solid var(--s200)",
      padding:"14px 20px", display:"flex", alignItems:"center", gap:12,
      flexShrink:0
    }}>
      <div style={{ display:"flex", alignItems:"center", gap:8 }}>
        <I.trello size={16} c="#EA580C"/>
        <div>
          <div style={{ fontFamily:"var(--fdis)", fontSize:17, fontWeight:700, letterSpacing:"-.01em", lineHeight:1 }}>
            Actividades municipales
          </div>
          <div style={{ fontSize:10.5, color:"var(--s500)", marginTop:3, letterSpacing:".02em" }}>
            Tablero kanban · 13 actividades · semana del 11 al 17 de mayo
          </div>
        </div>
      </div>

      <div style={{ flex:1 }}/>

      {/* Search */}
      <div style={{ position:"relative", width:240 }}>
        <I.search size={14} c="#A8A29E" style={{ position:"absolute", left:10, top:9 }}/>
        <input
          placeholder="Buscar por título…"
          style={{
            width:"100%", padding:"7px 10px 7px 32px",
            border:"1.5px solid var(--s200)", borderRadius:8,
            fontSize:12.5, background:"var(--s50)", color:"var(--s700)"
          }}
        />
      </div>

      {/* Type filter dropdown */}
      <button style={{
        display:"flex", alignItems:"center", gap:8,
        padding:"7px 12px", border:"1.5px solid var(--s200)", borderRadius:8,
        background:"white", fontSize:12.5, fontWeight:500, color:"var(--s700)"
      }}>
        <I.filter size={13} c="#57534E"/>
        Tipo: <strong style={{ color:"var(--s900)", fontWeight:600 }}>Todos</strong>
        <span style={{
          fontSize:10, fontWeight:600, padding:"1px 6px", borderRadius:10,
          background:"var(--s100)", color:"var(--s500)"
        }}>4</span>
        <I.chevronDown size={13} c="#78716C"/>
      </button>

      {/* JSON buttons */}
      <button style={{
        display:"flex", alignItems:"center", gap:6,
        padding:"7px 12px", border:"1.5px solid var(--s200)", borderRadius:8,
        background:"white", fontSize:12.5, fontWeight:500, color:"var(--s700)"
      }}>
        <I.download size={13} c="#57534E"/>
        Exportar JSON
      </button>
      <button style={{
        display:"flex", alignItems:"center", gap:6,
        padding:"7px 12px", border:"1.5px solid var(--s200)", borderRadius:8,
        background:"white", fontSize:12.5, fontWeight:500, color:"var(--s700)"
      }}>
        <I.upload size={13} c="#57534E"/>
        Importar JSON
      </button>

      <div style={{ width:1, height:26, background:"var(--s200)" }}/>

      <button style={{
        display:"flex", alignItems:"center", gap:6,
        padding:"8px 14px", borderRadius:8,
        background:"#EA580C", color:"white",
        fontSize:12.5, fontWeight:600,
        boxShadow:"0 1px 2px rgba(194,65,12,.3)"
      }}>
        <I.plus size={14} c="white"/>
        Nueva actividad
      </button>
    </div>
  );
};

Object.assign(window, { TopBar, ActividadesToolbar });
