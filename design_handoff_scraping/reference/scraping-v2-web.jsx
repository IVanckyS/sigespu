/* ─────────── Scraping v2 · vistas WEB ─────────── */

const { SC_PATENTES, SC_SOURCES, SC_GEO_COLOR } = window.ScrapingV2Data;

/* Pequeños helpers */
const ScV2_GeoBadge = ({ level }) => {
  const c = SC_GEO_COLOR[level] || SC_GEO_COLOR.Media;
  return (
    <span style={{
      display:"inline-flex", alignItems:"center", gap:5,
      padding:"3px 9px", borderRadius:999,
      fontSize:10.5, fontWeight:700,
      background:c.bg, color:c.fg
    }}>
      <span style={{ width:5, height:5, borderRadius:"50%", background:c.dot }}/>
      {level}
    </span>
  );
};

const ScV2_TipoBadge = ({ tipo, cls }) => (
  <div style={{ display:"flex", flexDirection:"column", gap:2 }}>
    <span style={{
      display:"inline-flex", alignSelf:"flex-start",
      padding:"2px 8px", borderRadius:5,
      background:"var(--or2)", color:"var(--or7)",
      fontSize:10, fontWeight:700, letterSpacing:".04em"
    }}>{tipo}</span>
    <span style={{ fontSize:10, color:"var(--s500)" }}>{cls}</span>
  </div>
);

const ScV2_Hero = () => {
  const I = window.Icons;
  return (
    <div style={{
      background:"#7C2D12",
      backgroundImage:"linear-gradient(135deg,#7C2D12 0%,#9A3412 50%,#C2410C 100%)",
      borderRadius:16, padding:"26px 30px", color:"white",
      position:"relative", overflow:"hidden", marginBottom:18
    }}>
      <div style={{ position:"absolute", right:30, top:24, opacity:.14 }}>
        <I.briefcase size={150} c="white" w={1.1}/>
      </div>

      <div style={{
        display:"inline-flex", alignItems:"center", gap:8,
        padding:"4px 12px", borderRadius:999,
        background:"rgba(255,255,255,.15)",
        fontSize:11, fontWeight:600, letterSpacing:".06em",
        textTransform:"uppercase", color:"rgba(255,255,255,.92)"
      }}>
        <span style={{ width:6, height:6, borderRadius:"50%", background:"#FED7AA" }}/>
        Datos · lotatransparente.cl · Ley 20.285
      </div>

      <h1 style={{
        fontFamily:"var(--fdis)", fontSize:30, fontWeight:700,
        letterSpacing:"-.02em", marginTop:10, lineHeight:1.05
      }}>Datos de Transparencia Pública</h1>

      <p style={{
        fontSize:13.5, color:"rgba(255,255,255,.8)", marginTop:6, maxWidth:640
      }}>
        Patentes, permisos DOM, decretos de tránsito y organizaciones sociales extraídos automáticamente.
      </p>

      <div style={{
        display:"grid", gridTemplateColumns:"repeat(4,auto)",
        gap:48, marginTop:22
      }}>
        {SC_SOURCES.map((s,i)=>(
          <div key={i}>
            <div style={{
              fontFamily:"var(--fdis)", fontSize:34, fontWeight:700,
              color: s.active ? "white" : "rgba(255,255,255,.55)",
              lineHeight:1
            }}>{s.count}</div>
            <div style={{
              fontSize:11.5, color:"rgba(255,255,255,.72)",
              marginTop:6, letterSpacing:".03em"
            }}>{s.label.replace("Organizaciones sociales","Organizaciones").replace("Patentes comerciales","Patentes").replace("Decretos de tránsito","Decretos tránsito")}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

const ScV2_StatusRow = () => {
  const I = window.Icons;
  return (
    <div style={{
      display:"flex", alignItems:"center", gap:14,
      background:"white", border:"1px solid var(--s200)", borderRadius:12,
      padding:"12px 16px", marginBottom:14
    }}>
      <span style={{
        display:"inline-flex", alignItems:"center", gap:8,
        padding:"6px 12px", borderRadius:999,
        background:"#DCFCE7", color:"#15803D",
        fontSize:12, fontWeight:600
      }}>
        <span style={{ width:7, height:7, borderRadius:"50%", background:"#16A34A" }}/>
        Scraper activo
      </span>

      <div>
        <div style={{ fontSize:12, color:"var(--s600)" }}>Última ejecución</div>
        <div style={{ fontSize:12.5, fontWeight:600, color:"var(--s900)", fontFamily:"var(--fmono)" }}>hoy · 03:00 AM</div>
      </div>

      <span style={{ flex:1 }}/>

      <button style={{
        padding:"9px 14px", borderRadius:8, fontSize:12.5, fontWeight:600,
        background:"white", border:"1px solid var(--s200)", color:"var(--s800)",
        display:"flex", alignItems:"center", gap:7
      }}>
        <I.refresh size={13} c="#57534E"/>
        Scrappear ahora
      </button>
      <button style={{
        padding:"9px 14px", borderRadius:8, fontSize:12.5, fontWeight:600,
        background:"white", border:"1px solid var(--s200)", color:"var(--s800)",
        display:"flex", alignItems:"center", gap:7
      }}>
        <I.clock size={13} c="#57534E"/>
        Scrappear histórico
      </button>
    </div>
  );
};

const ScV2_Banner = () => {
  const I = window.Icons;
  return (
    <div style={{
      background:"#FEFCE8", border:"1px solid #FDE68A", borderRadius:10,
      padding:"10px 14px", marginBottom:18,
      display:"flex", alignItems:"center", gap:10
    }}>
      <I.alertTriangle size={15} c="#A16207"/>
      <span style={{ fontSize:12.5, color:"#78350F" }}>
        Actualización automática diaria a las <strong>03:00 AM</strong> desde lotatransparente.cl (Ley 20.285).{" "}
        <span style={{ color:"#92400E" }}>"Scrappear histórico"</span> puede demorar varios minutos.
      </span>
    </div>
  );
};

const ScV2_SourceTabs = ({ active="patentes" }) => (
  <div style={{
    display:"flex", borderBottom:"1.5px solid var(--s200)",
    marginBottom:14, gap:0
  }}>
    {SC_SOURCES.map(s => {
      const on = s.id === active;
      return (
        <div key={s.id} style={{
          padding:"11px 20px",
          color: on ? "var(--or7)" : "var(--s500)",
          fontSize:13, fontWeight: on ? 600 : 500,
          borderBottom: on ? "2px solid #EA580C" : "2px solid transparent",
          marginBottom:-1.5, cursor:"pointer",
          display:"flex", alignItems:"center", gap:8
        }}>
          {s.label}
          <span style={{
            fontSize:10.5, padding:"1px 8px", borderRadius:999,
            background: on ? "var(--or2)" : "var(--s100)",
            color: on ? "var(--or7)" : "var(--s500)",
            fontWeight:700
          }}>{s.count}</span>
        </div>
      );
    })}
  </div>
);

const ScV2_MetaBar = () => (
  <div style={{
    background:"white", border:"1px solid var(--s200)", borderRadius:10,
    padding:"10px 14px", display:"flex", alignItems:"center", gap:22,
    marginBottom:12, fontSize:11.5, color:"var(--s600)"
  }}>
    {[
      { l:"Fuente", v:"lotatransparente.cl", link:true },
      { l:"ig",     v:"164" },
      { l:"Registros totales", v:"15" },
      { l:"Última extracción", v:"2026-04-24 · 03:02" },
    ].map((m,i)=>(
      <div key={i} style={{ display:"flex", alignItems:"center", gap:7 }}>
        <span style={{ color:"var(--s400)", fontSize:9.5, fontWeight:700, letterSpacing:".07em", textTransform:"uppercase" }}>{m.l}</span>
        {m.link ? (
          <a style={{
            padding:"2px 8px", borderRadius:5, background:"var(--or1)",
            color:"var(--or7)", fontWeight:600, fontSize:11.5, textDecoration:"none",
            display:"inline-flex", alignItems:"center", gap:4
          }}>{m.v}<span style={{ fontSize:10 }}>↗</span></a>
        ) : (
          <span style={{ fontFamily:"var(--fmono)", color:"var(--s900)", fontWeight:600 }}>{m.v}</span>
        )}
      </div>
    ))}
  </div>
);

const ScV2_FilterRow = () => {
  const I = window.Icons;
  return (
    <div style={{ display:"flex", alignItems:"center", gap:8, marginBottom:14 }}>
      <span style={{
        display:"inline-flex", alignItems:"center", gap:6,
        padding:"7px 11px", borderRadius:7, background:"var(--or1)",
        color:"var(--or7)", fontSize:12, fontWeight:600,
        border:"1px solid var(--or3)"
      }}>
        <I.clock size={12} c="#C2410C"/>
        Últimos 30 días
      </span>
      {[
        { l:"Año",       v:"Todos" },
        { l:"Mes",       v:"Todos" },
        { l:"Geocoding", v:"Todos" },
      ].map((f,i)=>(
        <div key={i} style={{
          display:"flex", alignItems:"center", gap:7,
          padding:"7px 11px", border:"1px solid var(--s200)", borderRadius:7,
          background:"white", fontSize:12
        }}>
          <span style={{
            fontSize:9.5, letterSpacing:".07em", textTransform:"uppercase",
            color:"var(--s400)", fontWeight:700
          }}>{f.l}</span>
          <strong style={{ color:"var(--s900)", fontWeight:600 }}>{f.v}</strong>
          <I.chevronDown size={11} c="#A8A29E"/>
        </div>
      ))}

      <div style={{ position:"relative", flex:1, minWidth:240 }}>
        <I.search size={13} c="#A8A29E" style={{ position:"absolute", left:11, top:8 }}/>
        <input
          placeholder="Buscar por razón social, RUT, dirección, giro…"
          style={{
            width:"100%", padding:"7px 12px 7px 32px",
            border:"1px solid var(--s200)", borderRadius:7,
            fontSize:12, background:"white"
          }}
        />
      </div>

      <span style={{ fontSize:11.5, color:"var(--s500)" }}>
        Mostrando <strong style={{ color:"var(--or7)", fontFamily:"var(--fmono)" }}>500</strong> de <strong style={{ color:"var(--or7)", fontFamily:"var(--fmono)" }}>500</strong>
      </span>
    </div>
  );
};

const ScV2_Pagination = () => {
  const I = window.Icons;
  return (
    <div style={{
      display:"flex", alignItems:"center", justifyContent:"space-between",
      padding:"14px 4px 0", fontSize:12, color:"var(--s600)"
    }}>
      <span>Mostrando <strong style={{ color:"var(--s900)" }}>1–20</strong> de <strong style={{ color:"var(--s900)" }}>500</strong></span>
      <div style={{ display:"flex", gap:4 }}>
        <button style={{
          width:32, height:32, borderRadius:7, border:"1px solid var(--s200)",
          background:"white", color:"var(--s400)",
          display:"flex", alignItems:"center", justifyContent:"center"
        }}><I.chevronRight size={13} c="#A8A29E" style={{ transform:"rotate(180deg)" }}/></button>
        {[1,2].map(n=>(
          <button key={n} style={{
            minWidth:32, height:32, padding:"0 10px",
            borderRadius:7, border:"1px solid " + (n===1?"#EA580C":"var(--s200)"),
            background:n===1?"#EA580C":"white",
            color:n===1?"white":"var(--s700)",
            fontSize:12, fontWeight:600
          }}>{n}</button>
        ))}
        <span style={{ padding:"6px 6px", color:"var(--s400)" }}>…</span>
        <button style={{
          minWidth:32, height:32, padding:"0 10px",
          borderRadius:7, border:"1px solid var(--s200)",
          background:"white", color:"var(--s700)",
          fontSize:12, fontWeight:600
        }}>25</button>
        <button style={{
          width:32, height:32, borderRadius:7, border:"1px solid var(--s200)",
          background:"white", color:"var(--s700)",
          display:"flex", alignItems:"center", justifyContent:"center"
        }}><I.chevronRight size={13} c="#57534E"/></button>
      </div>
    </div>
  );
};

const ScV2_Table = ({ focusedDec, compact }) => {
  const I = window.Icons;
  const cols = compact
    ? "0.75fr 0.9fr 1.1fr 1.85fr 1.4fr 0.7fr 40px"
    : "0.7fr 0.85fr 1.1fr 1fr 1.7fr 1.5fr 1.3fr 0.7fr 50px";
  return (
    <div style={{
      background:"white", border:"1px solid var(--s200)", borderRadius:12,
      overflow:"hidden"
    }}>
      <div style={{
        display:"grid",
        gridTemplateColumns: cols,
        padding:"11px 16px", background:"var(--s50)",
        borderBottom:"1px solid var(--s200)",
        fontSize:10, fontWeight:700, letterSpacing:".08em",
        textTransform:"uppercase", color:"var(--s500)"
      }}>
        <span>N° decreto</span>
        <span>Fecha</span>
        <span>Tipo</span>
        {!compact && <span>RUT</span>}
        <span>Razón social</span>
        {!compact && <span>Giro</span>}
        <span>Dirección</span>
        <span>Geocoding</span>
        <span></span>
      </div>

      {SC_PATENTES.map((p,i) => {
        const on = focusedDec && p.dec === focusedDec;
        return (
        <div key={p.dec} style={{
          display:"grid",
          gridTemplateColumns: cols,
          alignItems:"center",
          padding:"12px 16px",
          borderBottom: i<SC_PATENTES.length-1 ? "1px solid var(--s100)" : "none",
          fontSize:12.5,
          background: on ? "var(--or1)" : "transparent",
          borderLeft: on ? "3px solid #EA580C" : "3px solid transparent",
          paddingLeft: on ? 13 : 16,
          cursor: focusedDec ? "pointer" : "default"
        }}>
          <span style={{
            fontFamily:"var(--fmono)", fontSize:12, fontWeight:600,
            color:"var(--or7)"
          }}>{p.dec}</span>
          <span style={{ fontFamily:"var(--fmono)", fontSize:11.5, color:"var(--s700)" }}>{p.fecha}</span>
          <ScV2_TipoBadge tipo={p.tipo} cls={p.cls}/>
          {!compact && <span style={{ fontFamily:"var(--fmono)", fontSize:11.5, color:"var(--s800)" }}>{p.rut}</span>}
          <span style={{
            color:"var(--s900)", fontWeight: on ? 600 : 500, fontSize:12,
            overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap"
          }} title={p.rs}>{p.rs}</span>
          {!compact && <span style={{
            color:"var(--s700)", fontSize:11.5,
            overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap"
          }} title={p.giro}>{p.giro}</span>}
          <span style={{ color:"var(--s800)", fontSize:11.5, display:"flex", alignItems:"center", gap:5 }}>
            <I.mapPin size={11} c="#A8A29E"/>
            {p.dir}
          </span>
          <span><ScV2_GeoBadge level={p.geo}/></span>
          <div style={{ display:"flex", justifyContent:"flex-end" }}>
            {on
              ? <I.chevronRight size={14} c="#EA580C"/>
              : <button style={{
                  width:26, height:26, borderRadius:6,
                  display:"flex", alignItems:"center", justifyContent:"center",
                  background:"transparent"
                }}>
                  <I.moreHorizontal size={13} c="#78716C"/>
                </button>
            }
          </div>
        </div>
      );})}
    </div>
  );
};

/* ─────────────── WEB · Variación 1: stack vertical ─────────────── */
const ScrapingWebV1 = () => (
  <div data-screen-label="Scraping Web V1" style={{
    width:"100%", height:"100%", background:"var(--s100)",
    display:"flex", flexDirection:"column", overflow:"hidden"
  }}>
    <window.TopBar active="scraping"/>
    <div style={{ flex:1, minHeight:0, overflow:"auto", padding:"22px 28px" }}>
      <ScV2_Hero/>
      <ScV2_StatusRow/>
      <ScV2_Banner/>
      <ScV2_SourceTabs active="patentes"/>
      <ScV2_MetaBar/>
      <ScV2_FilterRow/>
      <ScV2_Table/>
      <ScV2_Pagination/>
    </div>
  </div>
);

/* ─────────────── WEB · Variación 2: sidebar + data-pane ─────────────── */
const ScV2_SidebarSourceCard = ({ s }) => {
  const I = window.Icons;
  const accent = s.active ? "#EA580C" : "var(--s300)";
  return (
    <div style={{
      background: s.active ? "var(--or1)" : "white",
      border: "1px solid " + (s.active ? "var(--or3)" : "var(--s200)"),
      borderLeft: "3px solid " + accent,
      borderRadius:10, padding:"11px 13px",
      display:"flex", flexDirection:"column", gap:6,
      cursor:"pointer"
    }}>
      <div style={{ display:"flex", alignItems:"center", gap:8 }}>
        <span style={{
          fontSize:12.5, fontWeight:600,
          color: s.active ? "var(--or7)" : "var(--s800)"
        }}>{s.label}</span>
        <span style={{ flex:1 }}/>
        <span style={{
          fontFamily:"var(--fdis)", fontSize:17, fontWeight:700,
          color: s.active ? "var(--or7)" : "var(--s400)"
        }}>{s.count}</span>
      </div>
      <div style={{
        display:"flex", alignItems:"center", gap:6,
        fontSize:10.5, color:"var(--s500)", fontFamily:"var(--fmono)"
      }}>
        <span style={{
          width:5, height:5, borderRadius:"50%",
          background: s.active ? "#16A34A" : "#A8A29E"
        }}/>
        ig {s.ig}
        <span style={{ color:"var(--s300)" }}>·</span>
        {s.last.split(" ")[1]}
      </div>
    </div>
  );
};

const ScrapingWebV2 = () => {
  const I = window.Icons;
  const focusedDec = "#203217";
  const focusedRec = SC_PATENTES.find(p => p.dec === focusedDec);
  return (
    <div data-screen-label="Scraping Web V2" style={{
      width:"100%", height:"100%", background:"var(--s100)",
      display:"flex", flexDirection:"column", overflow:"hidden"
    }}>
      <window.TopBar active="scraping"/>

      {/* Sub-header bar with screen title */}
      <div style={{
        background:"white", borderBottom:"1px solid var(--s200)",
        padding:"14px 28px", display:"flex", alignItems:"center", gap:14,
        flexShrink:0
      }}>
        <I.briefcase size={18} c="#EA580C"/>
        <div>
          <div style={{ fontFamily:"var(--fdis)", fontSize:17, fontWeight:700, letterSpacing:"-.01em", lineHeight:1 }}>
            Transparencia pública
          </div>
          <div style={{ fontSize:10.5, color:"var(--s500)", marginTop:3, letterSpacing:".02em" }}>
            Ley 20.285 · lotatransparente.cl · 500 registros sincronizados
          </div>
        </div>
        <span style={{ flex:1 }}/>
        <span style={{
          display:"inline-flex", alignItems:"center", gap:6,
          padding:"5px 10px", borderRadius:999, background:"var(--or1)",
          color:"var(--or7)", fontSize:11, fontWeight:600,
          border:"1px solid var(--or3)"
        }}>
          <span style={{
            width:7, height:7, borderRadius:"50%", background:"#EA580C",
            animation:"scv2pulse 1.4s ease-in-out infinite"
          }}/>
          Scrappeando · 327/500
        </span>
        <button style={{
          padding:"7px 12px", borderRadius:8, fontSize:12, fontWeight:600,
          background:"white", border:"1px solid var(--s200)", color:"var(--s800)",
          display:"flex", alignItems:"center", gap:6
        }}>
          <I.clock size={12} c="#57534E"/>
          Histórico
        </button>
        <style>{`@keyframes scv2pulse{0%,100%{opacity:1}50%{opacity:.3}}`}</style>
      </div>

      {/* Progress strip */}
      <ScV2_ProgressStrip pct={65} done={327} total={500} eta="~38 s restantes"/>

      {/* 3-col split */}
      <div style={{ flex:1, minHeight:0, display:"flex", overflow:"hidden" }}>
        {/* Sidebar */}
        <aside style={{
          width:248, borderRight:"1px solid var(--s200)",
          background:"var(--s50)", padding:"18px 14px", overflow:"auto",
          display:"flex", flexDirection:"column", gap:14, flexShrink:0
        }}>
          <div>
            <div style={{
              fontSize:9.5, letterSpacing:".09em", textTransform:"uppercase",
              fontWeight:700, color:"var(--s500)", marginBottom:8
            }}>Fuentes</div>
            <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
              {SC_SOURCES.map(s => <ScV2_SidebarSourceCard key={s.id} s={s}/>)}
            </div>
          </div>

          <div style={{
            background:"white", border:"1px solid var(--s200)", borderRadius:10,
            padding:"12px 13px"
          }}>
            <div style={{
              fontSize:9.5, letterSpacing:".09em", textTransform:"uppercase",
              fontWeight:700, color:"var(--s500)", marginBottom:8
            }}>Filtros</div>
            <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
              {[
                { l:"Rango temporal", v:"Últimos 30 días", or:true },
                { l:"Año", v:"Todos" },
                { l:"Mes", v:"Todos" },
                { l:"Geocoding", v:"Todos" },
              ].map((f,i)=>(
                <div key={i} style={{
                  display:"flex", alignItems:"center", justifyContent:"space-between",
                  padding:"7px 10px", borderRadius:7,
                  background: f.or ? "var(--or1)" : "var(--s50)",
                  border: "1px solid " + (f.or ? "var(--or3)" : "var(--s200)"),
                  fontSize:11.5
                }}>
                  <span style={{ color:"var(--s500)", fontSize:10.5, fontWeight:600 }}>{f.l}</span>
                  <span style={{ display:"flex", alignItems:"center", gap:5, fontWeight:600, color: f.or ? "var(--or7)" : "var(--s900)" }}>
                    {f.v} <I.chevronDown size={10} c={f.or ? "#C2410C" : "#A8A29E"}/>
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div style={{
            background:"white", border:"1px dashed var(--s300)", borderRadius:10,
            padding:"12px 13px", fontSize:11.2, color:"var(--s600)",
            lineHeight:1.45
          }}>
            <div style={{ fontWeight:700, color:"var(--s900)", marginBottom:4 }}>Sobre el scraping</div>
            Datos extraídos diariamente a las <strong>03:00 AM</strong> desde lotatransparente.cl (Ley 20.285). "Scrappear histórico" puede tardar varios minutos.
          </div>
        </aside>

        {/* Main pane */}
        <main style={{
          flex:1, overflow:"auto", padding:"18px 24px",
          display:"flex", flexDirection:"column"
        }}>
          {/* Inline header with source + meta */}
          <div style={{
            display:"flex", alignItems:"flex-end", gap:14, marginBottom:14
          }}>
            <div>
              <div style={{
                display:"flex", alignItems:"center", gap:8, marginBottom:4
              }}>
                <h2 style={{
                  fontFamily:"var(--fdis)", fontSize:22, fontWeight:700,
                  letterSpacing:"-.015em", color:"var(--s900)"
                }}>Patentes comerciales</h2>
                <span style={{
                  fontSize:11, padding:"2px 8px", borderRadius:999,
                  background:"var(--or2)", color:"var(--or7)", fontWeight:700
                }}>500</span>
              </div>
              <div style={{ display:"flex", alignItems:"center", gap:14, fontSize:11, color:"var(--s500)" }}>
                <span><span style={{ color:"var(--s400)" }}>Fuente</span>{" "}
                  <a style={{
                    padding:"1px 7px", borderRadius:5, background:"var(--or1)",
                    color:"var(--or7)", fontWeight:600, fontSize:10.5, textDecoration:"none"
                  }}>lotatransparente.cl ↗</a>
                </span>
                <span><span style={{ color:"var(--s400)" }}>ig</span>{" "}
                  <strong style={{ fontFamily:"var(--fmono)", color:"var(--s800)" }}>164</strong>
                </span>
                <span><span style={{ color:"var(--s400)" }}>Última extracción</span>{" "}
                  <strong style={{ fontFamily:"var(--fmono)", color:"var(--s800)" }}>2026-04-24 · 03:02</strong>
                </span>
              </div>
            </div>

            <span style={{ flex:1 }}/>

            <div style={{ position:"relative", width:220 }}>
              <I.search size={13} c="#A8A29E" style={{ position:"absolute", left:11, top:8 }}/>
              <input
                placeholder="Buscar razón social, RUT…"
                style={{
                  width:"100%", padding:"7px 12px 7px 32px",
                  border:"1px solid var(--s200)", borderRadius:7,
                  fontSize:12, background:"white"
                }}
              />
            </div>

            <button style={{
              padding:"7px 12px", borderRadius:7, fontSize:12, fontWeight:600,
              background:"white", border:"1px solid var(--s200)", color:"var(--s800)",
              display:"flex", alignItems:"center", gap:6
            }}>
              <I.download size={12} c="#57534E"/>
              CSV
            </button>
          </div>

          {/* KPI strip above table */}
          <div style={{
            display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:10,
            marginBottom:14
          }}>
            {[
              { l:"Mostrando", v:"500", sub:"de 500 registros", k:"or" },
              { l:"Geocoding alto", v:"428", sub:"85,6 % del total", k:"ok" },
              { l:"Fallos geocoding", v:"72", sub:"requieren revisión", k:"warn" },
            ].map((k,i)=>{
              const color = k.k==="or"?"var(--or7)":k.k==="ok"?"#15803D":k.k==="warn"?"#92400E":"var(--s700)";
              const bg    = k.k==="or"?"var(--or1)":k.k==="ok"?"#F0FDF4":k.k==="warn"?"#FEFCE8":"white";
              return (
                <div key={i} style={{
                  background:bg, border:"1px solid var(--s200)", borderRadius:10,
                  padding:"10px 12px"
                }}>
                  <div style={{ fontSize:9.5, fontWeight:700, letterSpacing:".07em", textTransform:"uppercase", color:"var(--s500)" }}>{k.l}</div>
                  <div style={{ fontFamily:"var(--fdis)", fontSize:22, fontWeight:700, color, marginTop:2, lineHeight:1.1 }}>{k.v}</div>
                  <div style={{ fontSize:10.5, color:"var(--s500)", marginTop:1 }}>{k.sub}</div>
                </div>
              );
            })}
          </div>

          <ScV2_Table focusedDec={focusedDec} compact/>
          <ScV2_Pagination/>
        </main>

        {/* Right map + detail panel */}
        <ScV2_MapDetailPanel rec={focusedRec}/>
      </div>
    </div>
  );
};

/* ──── Progress strip (running scrape) ──── */
const ScV2_ProgressStrip = ({ pct = 65, done = 327, total = 500, eta = "~38 s restantes" }) => {
  const I = window.Icons;
  return (
    <div style={{
      background:"white", borderBottom:"1px solid var(--s200)",
      padding:"9px 28px 0", flexShrink:0
    }}>
      <div style={{
        display:"flex", alignItems:"center", gap:10,
        fontSize:11.5, color:"var(--s700)"
      }}>
        {/* spinner */}
        <span style={{
          width:14, height:14, borderRadius:"50%",
          border:"2px solid var(--or2)", borderTopColor:"#EA580C",
          display:"inline-block",
          animation:"scv2spin .9s linear infinite"
        }}/>
        <span><strong style={{ color:"var(--s900)" }}>Scrappeando</strong> patentes comerciales</span>
        <span style={{ color:"var(--s400)" }}>·</span>
        <span style={{ fontFamily:"var(--fmono)", color:"var(--s900)", fontWeight:600 }}>{done}/{total}</span>
        <span style={{
          padding:"1px 7px", borderRadius:999,
          background:"var(--or2)", color:"var(--or7)",
          fontSize:10.5, fontWeight:700, fontFamily:"var(--fmono)"
        }}>{pct}%</span>
        <span style={{ color:"var(--s400)" }}>·</span>
        <span style={{ color:"var(--s500)" }}>{eta}</span>
        <span style={{ flex:1 }}/>
        <button style={{
          padding:"3px 10px", borderRadius:6, fontSize:11, fontWeight:600,
          background:"transparent", color:"var(--s600)",
          border:"1px solid var(--s200)"
        }}>Cancelar</button>
      </div>
      <div style={{
        marginTop:7, height:3, borderRadius:2,
        background:"var(--s100)", overflow:"hidden", position:"relative"
      }}>
        <div style={{
          width:`${pct}%`, height:"100%",
          background:"linear-gradient(90deg,#F97316,#EA580C)",
          borderRadius:2,
          boxShadow:"0 0 8px rgba(234,88,12,.4)"
        }}/>
      </div>
      <style>{`@keyframes scv2spin{to{transform:rotate(360deg)}}`}</style>
    </div>
  );
};

/* ──── Right column: mini-map + detail of focused record ──── */
const ScV2_MapDetailPanel = ({ rec }) => {
  const I = window.Icons;
  if (!rec) return null;
  return (
    <aside style={{
      width:340, borderLeft:"1px solid var(--s200)", background:"white",
      display:"flex", flexDirection:"column", flexShrink:0, overflow:"hidden"
    }}>
      {/* Header */}
      <div style={{
        padding:"14px 16px", borderBottom:"1px solid var(--s200)",
        display:"flex", alignItems:"center", gap:8, flexShrink:0
      }}>
        <I.mapPin size={15} c="#EA580C"/>
        <div>
          <div style={{ fontFamily:"var(--fdis)", fontSize:13.5, fontWeight:700, color:"var(--s900)", lineHeight:1 }}>
            Registro seleccionado
          </div>
          <div style={{ fontSize:10.5, color:"var(--s500)", marginTop:3, fontFamily:"var(--fmono)" }}>
            {rec.dec} · click otra fila para cambiar
          </div>
        </div>
        <span style={{ flex:1 }}/>
        <button style={{
          width:24, height:24, borderRadius:6, background:"var(--s100)",
          display:"flex", alignItems:"center", justifyContent:"center"
        }}>
          <I.x size={12} c="#57534E"/>
        </button>
      </div>

      <div style={{ flex:1, overflow:"auto" }}>
        {/* Mini map */}
        <div style={{
          height:220, position:"relative",
          background:"#e8edf2",
          backgroundImage:`
            repeating-linear-gradient(0deg,rgba(0,0,0,.04) 0,rgba(0,0,0,.04) 1px,transparent 1px,transparent 32px),
            repeating-linear-gradient(90deg,rgba(0,0,0,.04) 0,rgba(0,0,0,.04) 1px,transparent 1px,transparent 32px),
            linear-gradient(118deg, transparent 38%, white 38%, white 41%, transparent 41%),
            linear-gradient(28deg, transparent 56%, white 56%, white 59%, transparent 59%),
            linear-gradient(72deg, transparent 22%, white 22%, white 24%, transparent 24%)
          `
        }}>
          {/* Other faint pins */}
          {[
            { l:"22%", t:"68%", c:"#9A3412" },
            { l:"78%", t:"30%", c:"#15803D" },
            { l:"15%", t:"22%", c:"#9A3412" },
            { l:"62%", t:"75%", c:"#15803D" },
          ].map((q,i)=>(
            <div key={i} style={{
              position:"absolute", left:q.l, top:q.t,
              width:12, height:12, borderRadius:"50% 50% 50% 0",
              transform:"rotate(-45deg)", background:q.c,
              border:"2px solid white", opacity:.55
            }}/>
          ))}

          {/* Focused pin */}
          <div style={{
            position:"absolute", left:"50%", top:"42%",
            width:84, height:84, transform:"translate(-50%,-50%)",
            borderRadius:"50%", background:"rgba(234,88,12,.15)",
            border:"1.5px dashed #EA580C"
          }}/>
          <div style={{
            position:"absolute", left:"50%", top:"42%",
            transform:"translate(-50%,-100%)"
          }}>
            <div style={{
              width:36, height:36, borderRadius:"50% 50% 50% 0",
              transform:"rotate(-45deg)",
              background:"#EA580C", border:"3px solid white",
              boxShadow:"0 4px 12px rgba(28,25,23,.35)"
            }}/>
          </div>

          {/* Zoom controls */}
          <div style={{
            position:"absolute", right:10, top:10,
            background:"white", borderRadius:7, border:"1px solid var(--s200)",
            display:"flex", flexDirection:"column", boxShadow:"0 1px 3px rgba(0,0,0,.08)"
          }}>
            {["+","−"].map((s,i)=>(
              <span key={i} style={{
                width:26, height:26, display:"flex", alignItems:"center", justifyContent:"center",
                fontSize:14, fontWeight:700, color:"var(--s700)",
                borderBottom: i===0 ? "1px solid var(--s200)" : "none",
                cursor:"pointer"
              }}>{s}</span>
            ))}
          </div>
        </div>

        {/* Detail card */}
        <div style={{ padding:"14px 16px" }}>
          <div style={{ display:"flex", alignItems:"center", gap:8, marginBottom:8 }}>
            <span style={{
              display:"inline-flex", padding:"2px 8px", borderRadius:5,
              background:"var(--or2)", color:"var(--or7)",
              fontSize:10, fontWeight:700, letterSpacing:".04em"
            }}>{rec.tipo}</span>
            <ScV2_GeoBadge level={rec.geo}/>
            <span style={{
              marginLeft:"auto", fontFamily:"var(--fmono)", fontSize:10.5,
              color:"var(--or7)", fontWeight:700
            }}>{rec.dec}</span>
          </div>

          <div style={{
            fontFamily:"var(--fdis)", fontSize:14.5, fontWeight:700,
            color:"var(--s900)", letterSpacing:"-.005em", lineHeight:1.2
          }}>{rec.rs}</div>
          <div style={{ fontSize:11, color:"var(--s500)", marginTop:3, fontStyle:"italic" }}>
            {rec.cls}
          </div>

          <div style={{
            display:"grid", gridTemplateColumns:"auto 1fr", gap:"7px 12px",
            marginTop:12, paddingTop:12, borderTop:"1px dashed var(--s200)",
            fontSize:11.5
          }}>
            <span style={{ color:"var(--s500)", fontWeight:600 }}>RUT</span>
            <span style={{ fontFamily:"var(--fmono)", color:"var(--s900)", fontWeight:600 }}>{rec.rut}</span>
            <span style={{ color:"var(--s500)", fontWeight:600 }}>Giro</span>
            <span style={{ color:"var(--s900)" }}>{rec.giro}</span>
            <span style={{ color:"var(--s500)", fontWeight:600 }}>Dirección</span>
            <span style={{ color:"var(--s900)" }}>{rec.dir}</span>
            <span style={{ color:"var(--s500)", fontWeight:600 }}>Coords.</span>
            <span style={{ fontFamily:"var(--fmono)", color:"var(--s700)", fontSize:11 }}>-37.0894, -73.1578</span>
            <span style={{ color:"var(--s500)", fontWeight:600 }}>Fecha</span>
            <span style={{ fontFamily:"var(--fmono)", color:"var(--s900)" }}>{rec.fecha} · 03:02</span>
            <span style={{ color:"var(--s500)", fontWeight:600 }}>Fuente</span>
            <a style={{
              padding:"1px 7px", borderRadius:5, background:"var(--or1)", justifySelf:"start",
              color:"var(--or7)", fontWeight:600, fontSize:10.5, textDecoration:"none"
            }}>lotatransparente.cl ↗</a>
          </div>

          <div style={{ display:"flex", gap:6, marginTop:14 }}>
            <button style={{
              flex:1, padding:"8px", borderRadius:7, fontSize:12, fontWeight:600,
              background:"#EA580C", color:"white",
              display:"flex", alignItems:"center", justifyContent:"center", gap:6,
              boxShadow:"0 1px 2px rgba(194,65,12,.3)"
            }}>
              <I.map size={12} c="white"/>
              Abrir en mapa
            </button>
            <button style={{
              padding:"8px 12px", borderRadius:7, fontSize:12, fontWeight:600,
              background:"white", color:"var(--s700)", border:"1px solid var(--s200)"
            }}>Decreto PDF</button>
          </div>
        </div>
      </div>
    </aside>
  );
};

window.ScrapingV2Web = { ScrapingWebV1, ScrapingWebV2, ScV2_ProgressStrip, ScV2_MapDetailPanel };
