// Usuarios — User management mobile view
function ScreenUsuarios() {
  const users = [
    { i: 'AD', name: 'Administrador del Sistema', email: 'admin@lota.cl',     unidad: 'Dir. Seguridad Pública', rol: 'DIRECTOR',  estado: 'Activo', last: 'hace 25 min', color: SG.orange, you: true },
    { i: 'DS', name: 'Director Seguridad Pública', cargo: 'Director', email: 'director@lota.cl', unidad: 'Dir. Seguridad Pública', rol: 'DIRECTOR',  estado: 'Activo', last: 'Sin sesiones aún', color: '#7C2D12' },
    { i: 'JP', name: 'Juan Pérez',                 cargo: 'Inspector municipal', email: 'inspector1@lota.cl', unidad: 'Inspección', rol: 'OPERATIVO', estado: 'Activo', last: 'Sin sesiones aún', color: '#2563EB' },
    { i: 'MS', name: 'María Silva',                email: 'msilva@lota.cl',    unidad: 'Municipal',             rol: 'VISITANTE', estado: 'Activo', last: 'Sin sesiones aún', color: '#9333EA' },
  ];
  const roleColors = {
    DIRECTOR:  { bg: SG.orangeSoft, fg: SG.orange, dot: SG.orange },
    OPERATIVO: { bg: SG.yellowSoft, fg: SG.yellowInk, dot: SG.yellow },
    VISITANTE: { bg: '#EDE9FE', fg: '#5B21B6', dot: '#7C3AED' },
  };
  const distrib = [
    { label: 'Director',  count: 2, color: SG.ink, pct: 50 },
    { label: 'Operativo', count: 1, color: SG.orange, pct: 25 },
    { label: 'Visitante', count: 1, color: '#7C3AED', pct: 25 },
  ];
  const activity = [
    { who: 'DS', action: 'Aprobó solicitud de R. Sepúlveda', when: 'hace 2h',  color: '#7C2D12' },
    { who: 'DS', action: 'Creó usuario inspector2@lota.cl',  when: 'hace 5h',  color: '#7C2D12' },
    { who: 'DS', action: 'Rechazó solicitud de C. Morales',  when: 'ayer 16:30', color: '#7C2D12' },
  ];

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
      <AppTopBar exportAction={{ label: 'Exportar Excel', icon: 'pdf', sub: 'Usuarios · 4 activos' }}/>

      <div style={{ flex: 1, overflow: 'auto', padding: '12px 14px 100px' }}>
        <Hero
          kicker="Administración · Acceso al sistema"
          kickerIcon="shield"
          title="Gestión de usuarios"
          subtitle="Roles, credenciales y permisos del personal SIGESPU."
          stats={[
            { value: 4, label: 'Activos' },
            { value: 4, label: 'Registrados' },
            { value: 3, label: 'Roles en uso' },
            { value: 0, label: 'Solicitudes' },
          ]}
          variant="maroon"
          cornerPattern="shield"
        />

        {/* Sub-tabs */}
        <div style={{ display: 'flex', gap: 6, marginTop: 12, overflowX: 'auto' }}>
          {[
            { id: 'us', label: 'Usuarios', icon: 'users', active: true },
            { id: 'so', label: 'Solicitudes', icon: 'bell', badge: 0 },
            { id: 'ro', label: 'Roles', icon: 'shield' },
            { id: 'bi', label: 'Bitácora', icon: 'clock' },
          ].map(t => (
            <div key={t.id} style={{
              display: 'inline-flex', alignItems: 'center', gap: 6, padding: '7px 11px',
              borderRadius: 999,
              background: t.active ? SG.orangeSoft : '#fff',
              color: t.active ? SG.orange : SG.ink2,
              border: t.active ? `1px solid ${SG.orange}` : `1px solid ${SG.border}`,
              fontSize: 12, fontWeight: 600, fontFamily: SG.font, flexShrink: 0, whiteSpace: 'nowrap',
            }}>
              <Icon name={t.icon} size={13}/>
              {t.label}
            </div>
          ))}
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
          <div style={{
            flex: 1, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'flex', alignItems: 'center',
            gap: 7, padding: '0 12px',
          }}>
            <Icon name="search" size={15} color={SG.ink3}/>
            <span style={{ fontSize: 12.5, color: SG.ink3, fontFamily: SG.font }}>Nombre, email, RUT…</span>
          </div>
          <button style={{
            width: 40, height: 40, borderRadius: 11, background: '#fff',
            border: `1px solid ${SG.border}`, display: 'grid', placeItems: 'center',
            color: SG.ink2,
          }}><Icon name="filter" size={17}/></button>
        </div>

        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 6, marginTop: 8, overflowX: 'auto' }}>
          {[
            { k: 'Rol', v: 'Todos los roles' },
            { k: 'Unidad', v: 'Todas' },
            { k: 'Estado', v: 'Activos' },
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

        {/* Actions */}
        <div style={{ marginTop: 12 }}>
          <button style={{
            width: '100%', height: 40, borderRadius: 11, border: 'none',
            background: SG.orange, color: '#fff', fontWeight: 600, fontFamily: SG.font, fontSize: 12.5,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}><Icon name="plus" size={14} color="#fff"/> Crear usuario</button>
        </div>

        {/* User list */}
        <div style={{ marginTop: 14, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {users.map((u, i) => (
            <UserCard key={i} user={u} role={roleColors[u.rol]}/>
          ))}
        </div>

        {/* Distribución de roles */}
        <div style={{ marginTop: 18 }}>
          <SectionHead title="Distribución de roles" right={`${distrib.reduce((a,b)=>a+b.count,0)} usuarios`}/>
          <Card pad={14}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {distrib.map((d, i) => (
                <div key={i}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 5, fontFamily: SG.font }}>
                    <span style={{ fontSize: 12, color: SG.ink2, fontWeight: 600 }}>{d.label}</span>
                    <span style={{ fontSize: 12, color: SG.ink, fontWeight: 700, fontFamily: SG.fontDisplay }}>{d.count}</span>
                  </div>
                  <div style={{ height: 6, borderRadius: 99, background: SG.graySoft, position: 'relative', overflow: 'hidden' }}>
                    <div style={{
                      position: 'absolute', inset: 0, width: `${d.pct}%`,
                      background: d.color, borderRadius: 99,
                    }}/>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </div>

        {/* Actividad reciente */}
        <div style={{ marginTop: 18 }}>
          <SectionHead title="Actividad reciente"/>
          <Card pad={4}>
            {activity.map((a, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 10, padding: '10px 10px',
                borderBottom: i < activity.length - 1 ? `1px solid ${SG.border}` : 'none',
              }}>
                <div style={{
                  width: 30, height: 30, borderRadius: 99, background: a.color, color: '#fff',
                  display: 'grid', placeItems: 'center', fontSize: 11, fontWeight: 700, fontFamily: SG.font,
                  flexShrink: 0,
                }}>{a.who}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 12, color: SG.ink, fontWeight: 500, fontFamily: SG.font, lineHeight: 1.3 }}>{a.action}</div>
                  <div style={{ fontSize: 10.5, color: SG.ink3, marginTop: 1 }}>{a.when}</div>
                </div>
              </div>
            ))}
          </Card>
        </div>
      </div>

      <BottomTabs active="usuarios"/>
    </div>
  );
}

function UserCard({ user, role }) {
  return (
    <div style={{
      position: 'relative',
      background: user.you ? '#FFF8F2' : '#fff',
      border: `1px solid ${user.you ? '#F9D2BA' : SG.border}`,
      borderRadius: 12, padding: '12px',
      fontFamily: SG.font, overflow: 'hidden',
    }}>
      {user.you && (
        <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: SG.orange }}/>
      )}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 99, background: user.color, color: '#fff',
          display: 'grid', placeItems: 'center', fontSize: 13, fontWeight: 700, flexShrink: 0,
        }}>{user.i}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{
              fontSize: 13.5, fontWeight: 700, color: SG.ink, letterSpacing: -0.1,
              whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', minWidth: 0,
            }}>{user.name}</span>
            {user.you && (
              <span style={{
                padding: '1px 6px', background: SG.orange, color: '#fff',
                borderRadius: 5, fontSize: 9, fontWeight: 700,
              }}>TÚ</span>
            )}
          </div>
          {user.cargo && (
            <div style={{ fontSize: 11, color: SG.ink3, marginTop: 1 }}>{user.cargo}</div>
          )}
          <div style={{ fontSize: 11, color: SG.ink3, marginTop: 1 }}>{user.email}</div>
        </div>
        <Icon name="moreV" size={16} color={SG.ink3}/>
      </div>
      <div style={{
        marginTop: 10, display: 'flex', flexWrap: 'wrap', gap: 6, alignItems: 'center',
      }}>
        <Pill bg={role.bg} fg={role.fg} dot>{user.rol}</Pill>
        <StatusBadge status={user.estado}/>
        <Pill bg={SG.graySoft} fg={SG.ink2}>{user.unidad}</Pill>
      </div>
      <div style={{
        marginTop: 8, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        fontSize: 10.5, color: SG.ink3,
      }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon name="clock" size={11}/> {user.last}
        </span>
        {!user.you && (
          <div style={{ display: 'inline-flex', gap: 4 }}>
            <button style={{
              width: 26, height: 26, borderRadius: 7, border: `1px solid ${SG.border}`,
              background: '#fff', color: SG.ink2, display: 'grid', placeItems: 'center',
            }}><Icon name="pencil" size={12}/></button>
            <button style={{
              width: 26, height: 26, borderRadius: 7, border: `1px solid ${SG.border}`,
              background: '#fff', color: SG.green, display: 'grid', placeItems: 'center',
            }}><Icon name="toggleOn" size={12} color={SG.green}/></button>
            <button style={{
              width: 26, height: 26, borderRadius: 7, border: `1px solid ${SG.border}`,
              background: '#fff', color: SG.red, display: 'grid', placeItems: 'center',
            }}><Icon name="trash" size={12} color={SG.red}/></button>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { ScreenUsuarios });
