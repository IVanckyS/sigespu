/* ─────────── Mobile shared chrome ─────────── */

const MobileFrame = ({ children, label }) => (
  <div data-screen-label={label || "Mobile"} style={{
    width:"100%", height:"100%",
    display:"flex", alignItems:"center", justifyContent:"center",
    background:"linear-gradient(180deg,#F5F5F4,#E7E5E4)",
    padding:18
  }}>
    <div style={{
      width:390, height:824, borderRadius:42,
      background:"#1C1917", padding:11,
      boxShadow:"0 30px 60px -20px rgba(28,25,23,.35), 0 12px 24px -10px rgba(28,25,23,.2)",
      position:"relative"
    }}>
      <div style={{
        position:"absolute", top:18, left:"50%", transform:"translateX(-50%)",
        width:110, height:28, borderRadius:14, background:"#1C1917", zIndex:5
      }}/>
      <div style={{
        width:"100%", height:"100%", borderRadius:32, overflow:"hidden",
        background:"white", position:"relative",
        display:"flex", flexDirection:"column"
      }}>
        {children}
      </div>
    </div>
  </div>
);

const MStatusBar = () => (
  <div style={{
    background:"white", padding:"12px 22px 4px",
    display:"flex", justifyContent:"space-between", fontSize:12,
    fontWeight:600, color:"var(--s900)", flexShrink:0
  }}>
    <span style={{ fontFamily:"var(--fmono)" }}>09:42</span>
    <span style={{ display:"flex", gap:5, alignItems:"center" }}>
      <svg width="14" height="10" viewBox="0 0 14 10"><rect x="0" y="6" width="2" height="4" fill="#1C1917"/><rect x="3" y="4" width="2" height="6" fill="#1C1917"/><rect x="6" y="2" width="2" height="8" fill="#1C1917"/><rect x="9" y="0" width="2" height="10" fill="#1C1917"/></svg>
      <span>5G</span>
      <svg width="20" height="10" viewBox="0 0 22 11"><rect x="1" y="1" width="18" height="9" rx="2" fill="none" stroke="#1C1917" strokeWidth="1"/><rect x="3" y="3" width="13" height="5" fill="#1C1917"/><rect x="20" y="4" width="1.5" height="3" fill="#1C1917"/></svg>
    </span>
  </div>
);

const MAppHeader = ({ title, subtitle, right }) => {
  const I = window.Icons;
  return (
    <div style={{
      background:"white", padding:"8px 14px 10px",
      display:"flex", alignItems:"center", gap:10,
      borderBottom:"1px solid var(--s200)", flexShrink:0
    }}>
      <svg viewBox="0 0 80 80" width="26" height="26">
        <rect width="80" height="80" rx="18" fill="#EA580C"/>
        <path d="M40 14 C30 14 22 22 22 32 C22 46 40 66 40 66 C40 66 58 46 58 32 C58 22 50 14 40 14 Z" fill="white"/>
        <circle cx="40" cy="32" r="7" fill="#EA580C"/>
        <circle cx="40" cy="32" r="3" fill="white"/>
      </svg>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ fontFamily:"var(--fdis)", fontSize:14, fontWeight:700, lineHeight:1 }}>{title}</div>
        <div style={{ fontSize:10, color:"var(--s500)", marginTop:2, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>{subtitle}</div>
      </div>
      {right}
    </div>
  );
};

const MBottomBar = ({ active="tabla" }) => {
  const I = window.Icons;
  const tabs = [
    { i:"map",             l:"Mapa",    id:"mapa" },
    { i:"layoutDashboard", l:"Resumen", id:"resumen" },
    { i:"table",           l:"Tabla",   id:"tabla" },
    { i:"briefcase",       l:"Scrape",  id:"scraping" },
    { i:"users",           l:"Usuar.",  id:"usuarios" },
    { i:"trello",          l:"Activ.",  id:"actividades" },
  ];
  return (
    <div style={{
      background:"white", borderTop:"1px solid var(--s200)",
      padding:"7px 0 16px",
      display:"grid", gridTemplateColumns:"repeat(6,1fr)", gap:0,
      flexShrink:0
    }}>
      {tabs.map(t => {
        const Ic = I[t.i];
        const on = t.id === active;
        return (
          <div key={t.id} style={{
            display:"flex", flexDirection:"column", alignItems:"center", gap:3
          }}>
            <Ic size={19} c={on ? "#EA580C" : "#78716C"}/>
            <span style={{
              fontSize:9.5, fontWeight: on ? 700 : 500,
              color: on ? "var(--or7)" : "var(--s500)"
            }}>{t.l}</span>
          </div>
        );
      })}
    </div>
  );
};

const MIconBtn = ({ icon, count, c="#44403C" }) => {
  const I = window.Icons;
  const Ic = I[icon];
  return (
    <button style={{
      width:32, height:32, borderRadius:8, background:"var(--s100)",
      display:"flex", alignItems:"center", justifyContent:"center", position:"relative"
    }}>
      <Ic size={15} c={c}/>
      {count && (
        <span style={{
          position:"absolute", top:-3, right:-3,
          minWidth:14, height:14, padding:"0 4px", borderRadius:7,
          background:"#EA580C", color:"white",
          fontSize:9, fontWeight:700, fontFamily:"var(--fmono)",
          display:"flex", alignItems:"center", justifyContent:"center",
          border:"1.5px solid white"
        }}>{count}</span>
      )}
    </button>
  );
};

window.MobileChrome = { MobileFrame, MStatusBar, MAppHeader, MBottomBar, MIconBtn };
