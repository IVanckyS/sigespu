/* ─────────── Scraping v2 · vistas MOBILE ─────────── */

const { SC_PATENTES: SCM_PATENTES, SC_SOURCES: SCM_SOURCES, SC_GEO_COLOR: SCM_GEO } = window.ScrapingV2Data;

const ScV2M_GeoChip = ({ level, small }) => {
  const c = SCM_GEO[level] || SCM_GEO.Media;
  return (
    <span style={{
      display:"inline-flex", alignItems:"center", gap:4,
      padding: small ? "1px 6px" : "2px 8px", borderRadius:999,
      fontSize: small ? 9 : 9.5, fontWeight:700,
      background:c.bg, color:c.fg
    }}>
      <span style={{ width:4, height:4, borderRadius:"50%", background:c.dot }}/>
      {level}
    </span>
  );
};

/* ─────────────── MOBILE · Variación 1: hero + cards ─────────────── */
const ScrapingMobileV1 = () => {
  const I = window.Icons;
  const { MobileFrame, MStatusBar, MAppHeader, MBottomBar, MIconBtn } = window.MobileChrome;

  return (
    <MobileFrame label="Scraping mobile V1">
      <MStatusBar/>
      <MAppHeader
        title="Transparencia"
        subtitle="lotatransparente.cl · 500 registros"
        right={<div style={{ display:"flex", gap:6 }}>
          <MIconBtn icon="search"/>
          <MIconBtn icon="refresh"/>
        </div>}
      />

      {/* Hero compacto */}
      <div style={{
        background:"#7C2D12",
        backgroundImage:"linear-gradient(135deg,#7C2D12 0%,#9A3412 60%,#C2410C 100%)",
        padding:"14px 14px 14px", color:"white", flexShrink:0
      }}>
        <div style={{
          display:"inline-flex", alignItems:"center", gap:6,
          padding:"3px 9px", borderRadius:999,
          background:"rgba(255,255,255,.15)",
          fontSize:9, fontWeight:600, letterSpacing:".06em",
          textTransform:"uppercase", color:"rgba(255,255,255,.92)",
          marginBottom:9
        }}>
          <span style={{ width:5, height:5, borderRadius:"50%", background:"#FED7AA" }}/>
          Datos · Ley 20.285
        </div>

        <div style={{
          fontFamily:"var(--fdis)", fontSize:18, fontWeight:700,
          letterSpacing:"-.01em", lineHeight:1.1, marginBottom:11
        }}>Datos de Transparencia Pública</div>

        <div style={{ display:"grid", gridTemplateColumns:"repeat(4,1fr)", gap:6 }}>
          {SCM_SOURCES.map((s,i)=>(
            <div key={i} style={{
              background:"rgba(255,255,255,.08)", borderRadius:8,
              padding:"8px 9px"
            }}>
              <div style={{
                fontFamily:"var(--fdis)", fontSize:18, fontWeight:700, lineHeight:1,
                color: s.active ? "white" : "rgba(255,255,255,.55)"
              }}>{s.count}</div>
              <div style={{
                fontSize:8.5, color:"rgba(255,255,255,.7)",
                marginTop:4, textTransform:"uppercase", letterSpacing:".03em"
              }}>{s.short}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Status row + acciones */}
      <div style={{
        background:"white", borderBottom:"1px solid var(--s200)",
        padding:"10px 12px", display:"flex", alignItems:"center", gap:8,
        flexShrink:0
      }}>
        <span style={{
          display:"inline-flex", alignItems:"center", gap:5,
          padding:"3px 8px", borderRadius:999,
          background:"#DCFCE7", color:"#15803D",
          fontSize:10, fontWeight:600
        }}>
          <span style={{ width:5, height:5, borderRadius:"50%", background:"#16A34A" }}/>
          Activo
        </span>
        <span style={{ fontSize:10, color:"var(--s500)", fontFamily:"var(--fmono)" }}>
          últ. hoy · 03:00
        </span>
        <span style={{ flex:1 }}/>
        <button style={{
          padding:"5px 9px", borderRadius:6, fontSize:10.5, fontWeight:600,
          background:"#EA580C", color:"white",
          display:"flex", alignItems:"center", gap:4
        }}>
          <I.refresh size={10} c="white"/>
          Scrappear
        </button>
        <button style={{
          padding:"5px 9px", borderRadius:6, fontSize:10.5, fontWeight:600,
          background:"white", border:"1px solid var(--s200)", color:"var(--s700)",
          display:"flex", alignItems:"center", gap:4
        }}>
          <I.clock size={10} c="#57534E"/>
          Histórico
        </button>
      </div>

      {/* Banner info */}
      <div style={{
        background:"#FEFCE8", borderBottom:"1px solid #FDE68A",
        padding:"7px 12px", flexShrink:0,
        display:"flex", alignItems:"center", gap:7
      }}>
        <I.alertTriangle size={11} c="#A16207"/>
        <span style={{ fontSize:10, color:"#78350F", lineHeight:1.3 }}>
          Actualización diaria a las <strong>03:00 AM</strong> · histórico puede demorar.
        </span>
      </div>

      {/* Source tabs scroll */}
      <div style={{
        background:"white", borderBottom:"1px solid var(--s200)",
        padding:"4px 8px 0", display:"flex", gap:0,
        overflowX:"auto", flexShrink:0
      }}>
        {SCM_SOURCES.map((s,i) => {
          const on = i===0;
          return (
            <div key={s.id} style={{
              padding:"10px 12px",
              borderBottom: on ? "2px solid #EA580C" : "2px solid transparent",
              display:"flex", alignItems:"center", gap:6,
              fontSize:12, fontWeight: on ? 600 : 500,
              color: on ? "var(--or7)" : "var(--s500)",
              whiteSpace:"nowrap", flexShrink:0
            }}>
              {s.short}
              <span style={{
                fontSize:9.5, padding:"1px 6px", borderRadius:999,
                background: on ? "var(--or2)" : "var(--s100)",
                color: on ? "var(--or7)" : "var(--s500)",
                fontWeight:700
              }}>{s.count}</span>
            </div>
          );
        })}
      </div>

      {/* Filter chips row */}
      <div style={{
        background:"white", padding:"8px 12px",
        borderBottom:"1px solid var(--s200)",
        display:"flex", gap:6, flexShrink:0, alignItems:"center",
        overflowX:"auto"
      }}>
        <span style={{
          display:"inline-flex", alignItems:"center", gap:4,
          padding:"4px 8px", border:"1px solid var(--or3)", borderRadius:6,
          background:"var(--or1)", color:"var(--or7)", fontSize:10, fontWeight:600,
          whiteSpace:"nowrap"
        }}>
          <I.clock size={9} c="#C2410C"/>
          30 días
        </span>
        {[
          { l:"Año", v:"Todos" },
          { l:"Mes", v:"Todos" },
          { l:"Geo", v:"Todos" },
        ].map((f,i)=>(
          <span key={i} style={{
            display:"inline-flex", alignItems:"center", gap:4,
            padding:"4px 8px", border:"1px solid var(--s200)", borderRadius:6,
            background:"var(--s50)", fontSize:10.5, whiteSpace:"nowrap"
          }}>
            <span style={{ fontSize:8.5, letterSpacing:".06em", textTransform:"uppercase", color:"var(--s400)", fontWeight:700 }}>{f.l}</span>
            <strong style={{ color:"var(--s900)", fontWeight:600 }}>{f.v}</strong>
            <I.chevronDown size={9} c="#A8A29E"/>
          </span>
        ))}
        <span style={{ marginLeft:"auto", fontSize:10, color:"var(--or7)", fontFamily:"var(--fmono)", fontWeight:700, whiteSpace:"nowrap" }}>500/500</span>
      </div>

      {/* Patentes cards */}
      <div style={{
        flex:1, overflow:"auto",
        padding:"10px 12px 12px",
        display:"flex", flexDirection:"column", gap:8,
        background:"var(--s50)"
      }}>
        {SCM_PATENTES.slice(0,7).map(p => (
          <div key={p.dec} style={{
            background:"white", border:"1px solid var(--s200)", borderRadius:10,
            padding:"11px 12px"
          }}>
            <div style={{ display:"flex", alignItems:"center", gap:6, marginBottom:6 }}>
              <span style={{
                fontFamily:"var(--fmono)", fontSize:11, fontWeight:700,
                color:"var(--or7)"
              }}>{p.dec}</span>
              <span style={{ fontSize:9.5, color:"var(--s400)" }}>·</span>
              <span style={{ fontFamily:"var(--fmono)", fontSize:10.5, color:"var(--s600)" }}>{p.fecha}</span>
              <span style={{ marginLeft:"auto" }}>
                <ScV2M_GeoChip level={p.geo}/>
              </span>
            </div>

            <div style={{
              fontSize:12.5, fontWeight:600, color:"var(--s900)",
              lineHeight:1.25, marginBottom:5
            }}>{p.rs}</div>

            <div style={{ display:"flex", alignItems:"center", gap:5, marginBottom:6, flexWrap:"wrap" }}>
              <span style={{
                display:"inline-flex", padding:"2px 7px", borderRadius:5,
                background:"var(--or2)", color:"var(--or7)", fontSize:9.5, fontWeight:700,
                letterSpacing:".04em"
              }}>{p.tipo}</span>
              <span style={{ fontSize:9.5, color:"var(--s500)" }}>{p.cls}</span>
              <span style={{ color:"var(--s300)", fontSize:9 }}>·</span>
              <span style={{ fontFamily:"var(--fmono)", fontSize:10, color:"var(--s600)" }}>{p.rut}</span>
            </div>

            <div style={{
              fontSize:10.5, color:"var(--s700)", paddingTop:6,
              borderTop:"1px dashed var(--s200)",
              display:"flex", flexDirection:"column", gap:3
            }}>
              <div style={{ display:"flex", alignItems:"flex-start", gap:5 }}>
                <span style={{ fontSize:8.5, letterSpacing:".06em", textTransform:"uppercase", color:"var(--s400)", fontWeight:700, minWidth:36 }}>Giro</span>
                <span style={{ color:"var(--s800)", flex:1 }}>{p.giro}</span>
              </div>
              <div style={{ display:"flex", alignItems:"flex-start", gap:5 }}>
                <span style={{ fontSize:8.5, letterSpacing:".06em", textTransform:"uppercase", color:"var(--s400)", fontWeight:700, minWidth:36 }}>Dir.</span>
                <I.mapPin size={10} c="#A8A29E" style={{ marginTop:1, flexShrink:0 }}/>
                <span style={{ color:"var(--s800)", flex:1 }}>{p.dir}</span>
              </div>
            </div>
          </div>
        ))}

        {/* Load more */}
        <button style={{
          background:"white", border:"1px solid var(--s200)", borderRadius:10,
          padding:"10px", fontSize:11.5, fontWeight:600, color:"var(--s700)",
          marginTop:2
        }}>
          Cargar 20 más · <span style={{ color:"var(--s500)" }}>20 de 500</span>
        </button>
      </div>

      <MBottomBar active="scraping"/>
    </MobileFrame>
  );
};

/* ─────────────── MOBILE · Variación 2: data-dense, segmented ─────────────── */
const ScrapingMobileV2 = () => {
  const I = window.Icons;
  const { MobileFrame, MStatusBar, MBottomBar, MIconBtn } = window.MobileChrome;

  return (
    <MobileFrame label="Scraping mobile V2">
      <MStatusBar/>

      {/* App header propio */}
      <div style={{
        background:"white", padding:"10px 14px 12px",
        borderBottom:"1px solid var(--s200)", flexShrink:0
      }}>
        <div style={{ display:"flex", alignItems:"center", gap:10 }}>
          <I.briefcase size={18} c="#EA580C"/>
          <div style={{ flex:1 }}>
            <div style={{
              fontFamily:"var(--fdis)", fontSize:16, fontWeight:700,
              letterSpacing:"-.01em", lineHeight:1.1, color:"var(--s900)"
            }}>Transparencia pública</div>
            <div style={{
              fontSize:9.5, color:"var(--s500)", marginTop:2,
              letterSpacing:".03em"
            }}>Ley 20.285 · lotatransparente.cl</div>
          </div>
          <MIconBtn icon="search"/>
        </div>

        {/* Status + acciones inline */}
        <div style={{
          marginTop:10, display:"flex", alignItems:"center", gap:6,
          background:"var(--s50)", border:"1px solid var(--s200)", borderRadius:9,
          padding:"7px 10px"
        }}>
          <span style={{
            display:"inline-flex", alignItems:"center", gap:5,
            padding:"2px 7px", borderRadius:999,
            background:"#DCFCE7", color:"#15803D",
            fontSize:9.5, fontWeight:700
          }}>
            <span style={{ width:5, height:5, borderRadius:"50%", background:"#16A34A" }}/>
            Activo
          </span>
          <span style={{ fontSize:10, color:"var(--s600)", fontFamily:"var(--fmono)" }}>hoy · 03:00 AM</span>
          <span style={{ flex:1 }}/>
          <button style={{
            padding:"4px 8px", borderRadius:6, fontSize:10, fontWeight:600,
            background:"#EA580C", color:"white",
            display:"flex", alignItems:"center", gap:4
          }}>
            <I.refresh size={9} c="white"/>
            Scrappear
          </button>
          <button style={{
            padding:"4px 8px", borderRadius:6, fontSize:10, fontWeight:600,
            background:"white", border:"1px solid var(--s200)", color:"var(--s700)"
          }}>Histórico</button>
        </div>
      </div>

      {/* KPI strip horizontal scroll */}
      <div style={{
        display:"flex", gap:8, padding:"10px 14px",
        background:"white", overflowX:"auto", flexShrink:0,
        borderBottom:"1px solid var(--s200)"
      }}>
        {[
          { l:"Patentes",   v:500, k:"or",     sub:"comerciales" },
          { l:"DOM",        v:0,   k:"gray",   sub:"permisos" },
          { l:"Decretos",   v:0,   k:"gray",   sub:"tránsito" },
          { l:"Org.",       v:0,   k:"gray",   sub:"sociales" },
        ].map((s,i)=>{
          const fg = s.k==="or" ? "var(--or7)" : "var(--s400)";
          const bg = s.k==="or" ? "var(--or1)" : "var(--s50)";
          const bd = s.k==="or" ? "var(--or3)" : "var(--s200)";
          return (
            <div key={i} style={{
              minWidth:78, background:bg, border:"1px solid " + bd,
              borderRadius:9, padding:"7px 9px", flexShrink:0
            }}>
              <div style={{ fontFamily:"var(--fdis)", fontSize:18, fontWeight:700, color:fg, lineHeight:1 }}>{s.v}</div>
              <div style={{ fontSize:9.5, fontWeight:700, color: s.k==="or" ? "var(--or7)" : "var(--s700)", marginTop:3 }}>{s.l}</div>
              <div style={{ fontSize:8.5, color:"var(--s500)", marginTop:1, letterSpacing:".03em" }}>{s.sub}</div>
            </div>
          );
        })}
      </div>

      {/* Segmented control de fuentes */}
      <div style={{
        background:"white", padding:"10px 14px", flexShrink:0,
        borderBottom:"1px solid var(--s200)"
      }}>
        <div style={{
          background:"var(--s100)", borderRadius:8, padding:3,
          display:"grid", gridTemplateColumns:"repeat(4,1fr)", gap:0
        }}>
          {SCM_SOURCES.map((s,i)=>{
            const on = i===0;
            return (
              <span key={s.id} style={{
                padding:"7px 4px", textAlign:"center",
                fontSize:10.5, fontWeight: on ? 700 : 500,
                color: on ? "var(--or7)" : "var(--s500)",
                background: on ? "white" : "transparent",
                borderRadius:6,
                boxShadow: on ? "0 1px 2px rgba(0,0,0,.07)" : "none",
                display:"flex", alignItems:"center", justifyContent:"center", gap:4
              }}>
                {s.short}
                <span style={{
                  fontSize:8.5, padding:"0 5px", borderRadius:999,
                  background: on ? "var(--or2)" : "var(--s200)",
                  color: on ? "var(--or7)" : "var(--s500)",
                  fontWeight:700
                }}>{s.count}</span>
              </span>
            );
          })}
        </div>
      </div>

      {/* Filter sticky bar */}
      <div style={{
        background:"var(--s50)", padding:"8px 14px",
        borderBottom:"1px solid var(--s200)",
        display:"flex", alignItems:"center", gap:6,
        flexShrink:0, overflowX:"auto"
      }}>
        <I.filter size={11} c="#78716C"/>
        {[
          { l:"30 días", or:true },
          { l:"Año Todos" },
          { l:"Mes Todos" },
          { l:"Geo Todos" },
        ].map((f,i)=>(
          <span key={i} style={{
            display:"inline-flex", alignItems:"center", gap:3,
            padding:"3px 8px", borderRadius:999,
            background: f.or ? "var(--or6)" : "white",
            border: "1px solid " + (f.or ? "var(--or6)" : "var(--s200)"),
            color: f.or ? "white" : "var(--s700)",
            fontSize:10, fontWeight:600, whiteSpace:"nowrap"
          }}>
            {f.l}
            {!f.or && <I.chevronDown size={9} c="#A8A29E"/>}
          </span>
        ))}
        <span style={{ marginLeft:"auto", fontSize:10, color:"var(--s500)", fontFamily:"var(--fmono)", whiteSpace:"nowrap" }}>
          500/500
        </span>
      </div>

      {/* Compact list (table-like rows) */}
      <div style={{
        flex:1, overflow:"auto", background:"white"
      }}>
        {SCM_PATENTES.slice(0,9).map((p,i) => (
          <div key={p.dec} style={{
            padding:"10px 14px",
            borderBottom: "1px solid var(--s100)",
            display:"flex", flexDirection:"column", gap:5
          }}>
            <div style={{ display:"flex", alignItems:"center", gap:6 }}>
              <span style={{
                fontFamily:"var(--fmono)", fontSize:10.5, fontWeight:700,
                color:"var(--or7)"
              }}>{p.dec}</span>
              <span style={{
                display:"inline-flex", padding:"1px 5px", borderRadius:4,
                background:"var(--or2)", color:"var(--or7)",
                fontSize:8.5, fontWeight:700, letterSpacing:".04em"
              }}>{p.tipo}</span>
              <span style={{ fontFamily:"var(--fmono)", fontSize:9.5, color:"var(--s500)" }}>{p.fecha}</span>
              <span style={{ flex:1 }}/>
              <ScV2M_GeoChip level={p.geo} small/>
            </div>

            <div style={{
              fontSize:12, fontWeight:600, color:"var(--s900)",
              lineHeight:1.25,
              overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap"
            }}>{p.rs}</div>

            <div style={{
              display:"flex", alignItems:"center", gap:6,
              fontSize:10, color:"var(--s600)"
            }}>
              <span style={{ fontFamily:"var(--fmono)", color:"var(--s500)" }}>{p.rut}</span>
              <span style={{ color:"var(--s300)" }}>·</span>
              <I.mapPin size={9} c="#A8A29E"/>
              <span style={{
                color:"var(--s700)",
                overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap", flex:1
              }}>{p.dir}</span>
            </div>
          </div>
        ))}

        {/* Pagination footer */}
        <div style={{
          padding:"12px 14px", display:"flex", alignItems:"center", gap:6,
          fontSize:10.5, color:"var(--s500)"
        }}>
          <span>Mostrando <strong style={{ color:"var(--s900)" }}>1–20</strong> de <strong style={{ color:"var(--s900)" }}>500</strong></span>
          <span style={{ flex:1 }}/>
          <button style={{
            width:28, height:28, borderRadius:6, border:"1px solid var(--s200)",
            background:"white", color:"var(--s400)",
            display:"flex", alignItems:"center", justifyContent:"center"
          }}><I.chevronRight size={11} c="#A8A29E" style={{ transform:"rotate(180deg)" }}/></button>
          <button style={{
            minWidth:28, height:28, padding:"0 8px",
            borderRadius:6, background:"#EA580C", color:"white",
            fontSize:11, fontWeight:700
          }}>1</button>
          <button style={{
            minWidth:28, height:28, padding:"0 8px",
            borderRadius:6, border:"1px solid var(--s200)",
            background:"white", color:"var(--s700)",
            fontSize:11, fontWeight:600
          }}>2</button>
          <span style={{ color:"var(--s400)", padding:"0 2px" }}>…</span>
          <button style={{
            minWidth:28, height:28, padding:"0 8px",
            borderRadius:6, border:"1px solid var(--s200)",
            background:"white", color:"var(--s700)",
            fontSize:11, fontWeight:600
          }}>25</button>
          <button style={{
            width:28, height:28, borderRadius:6, border:"1px solid var(--s200)",
            background:"white", color:"var(--s700)",
            display:"flex", alignItems:"center", justifyContent:"center"
          }}><I.chevronRight size={11} c="#57534E"/></button>
        </div>
      </div>

      <MBottomBar active="scraping"/>
    </MobileFrame>
  );
};

window.ScrapingV2Mobile = { ScrapingMobileV1, ScrapingMobileV2 };
