// Home, Reference, Profile screens
const { useState: useStateCore } = React;

// ── HOME ─────────────────────────────────────────────────────
function HomeScreen() {
  const modes = [
    { n: 1, name: "MATCH",         sub: "decimal  →  binary",        badge: "★ 240" },
    { n: 2, name: "REVERSE",       sub: "binary   →  decimal",       badge: "★ 180" },
    { n: 3, name: "ADDITION",      sub: "row_a + row_b = target",    badge: "★ 90" },
    { n: 4, name: "XOR",           sub: "a ⊕ b = ?",                 badge: "★ 60" },
    { n: 5, name: "SPEED BURST",   sub: "60 second blitz",           badge: "★ 320" },
    { n: 6, name: "HEX MATCH",     sub: "binary   →  hex",           badge: "★ 110" },
    { n: 7, name: "DAILY",         sub: "10 questions · 04:13:22",   badge: "▌3/10" },
  ];
  return (
    <Phone label="01 Home">
      <div className="appbar">
        <span className="title">GO BINARY RUSH</span>
        <span className="spacer"></span>
        <span className="meta">v0.4 · ONLINE<span className="caret"></span></span>
      </div>
      <hr className="hr solid" style={{ margin: '0 18px 16px' }} />

      <div className="body">
        {/* Today's banner */}
        <div style={{
          border: '1px solid var(--g-1)', borderLeft: '2px solid var(--g-3)',
          padding: '10px 12px', marginBottom: 18,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center'
        }}>
          <div>
            <div style={{ fontSize: 9, letterSpacing: '0.18em', color: 'var(--g-2)', marginBottom: 4 }}>WELCOME BACK · MARKO</div>
            <div style={{ fontSize: 13, color: 'var(--g-4)', textShadow: 'var(--glow-sm)', letterSpacing: '0.05em' }}>
              <span className="dim">streak </span>×<span className="hot">7d</span>
              <span className="dimmer" style={{ margin: '0 8px' }}>│</span>
              <span className="dim">acc </span><span className="bright">86%</span>
            </div>
          </div>
          <span className="tier-badge">TIER · T2</span>
        </div>

        <div className="kicker">SELECT MODE</div>
        <div className="mode-list">
          {modes.map(m => (
            <div className="mode" key={m.n}>
              <span className="num">[{m.n}]</span>
              <div>
                <div className="name">{m.name}</div>
                <div className="sub">{m.sub}</div>
              </div>
              <div className="badge">
                <div className="b">{m.badge}</div>
                <div className="dimmer">BEST</div>
              </div>
            </div>
          ))}
        </div>

        <hr className="hr" />
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 10, letterSpacing: '0.18em', color: 'var(--g-2)' }}>
          <span>REFERENCE  →</span>
          <span>PROFILE  →</span>
        </div>
      </div>

      <Dock active="play" />
    </Phone>
  );
}

// ── REFERENCE ────────────────────────────────────────────────
function ReferenceScreen() {
  const powers = [7,6,5,4,3,2,1,0];
  const hex = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
  return (
    <Phone label="02 Reference">
      <AppBar title="REFERENCE" meta="$ man bits" />
      <hr className="hr solid" style={{ margin: '0 18px 16px' }} />
      <div className="body" style={{ paddingBottom: 80 }}>

        <div className="kicker">POWERS OF TWO</div>
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6, marginBottom: 18
        }}>
          {powers.map(p => (
            <div key={p} style={{
              border: '1px solid var(--g-1)', borderRadius: 2, padding: '8px 4px',
              textAlign: 'center'
            }}>
              <div style={{ fontSize: 9, color: 'var(--g-2)', letterSpacing: '0.1em' }}>2^{p}</div>
              <div style={{ fontSize: 18, color: 'var(--g-4)', textShadow: 'var(--glow-sm)', fontWeight: 600 }}>{1 << p}</div>
            </div>
          ))}
        </div>

        <div className="kicker">HEX MAP</div>
        <div className="ascii" style={{ marginBottom: 18, color: 'var(--g-3)' }}>
{`hex  bin   dec    hex  bin   dec
─────────────  ─────────────
 0   0000   0     8   1000   8
 1   0001   1     9   1001   9
 2   0010   2     A   1010  10
 3   0011   3     B   1011  11
 4   0100   4     C   1100  12
 5   0101   5     D   1101  13
 6   0110   6     E   1110  14
 7   0111   7     F   1111  15`}
        </div>

        <div className="kicker">XOR · TRUTH TABLE</div>
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 4,
          fontSize: 12, textAlign: 'center', marginBottom: 18
        }}>
          {[
            ['A','B','A⊕B'],
            ['0','0','0'],['0','1','1'],['1','0','1'],['1','1','0'],
          ].map((row, r) => row.map((c, i) => (
            <div key={r+'-'+i} style={{
              padding: '6px 0',
              color: r === 0 ? 'var(--g-2)' : (i === 2 ? 'var(--g-4)' : 'var(--g-3)'),
              borderBottom: r === 0 ? '1px dashed var(--g-1)' : 'none',
              textShadow: r > 0 && i === 2 ? 'var(--glow-sm)' : 'none',
              letterSpacing: '0.16em',
            }}>{c}</div>
          )))}
        </div>

        <div className="kicker">BINARY ADDITION</div>
        <div className="ascii" style={{ color: 'var(--g-3)' }}>
{`0 + 0 = 0
0 + 1 = 1
1 + 0 = 1
1 + 1 = 10   ← carry`}
        </div>

        <hr className="hr" />
        <div className="hint-card">
          <div className="h">$ TIP</div>
          Read binary right→left, doubling each place: <code>1 2 4 8 16 32 64 128</code>.
          A bit "on" adds its weight to the total.
        </div>
      </div>
      <Dock active="ref" />
    </Phone>
  );
}

// ── PROFILE / STATS ──────────────────────────────────────────
function ProfileScreen() {
  const heat = [
    { mode: "MATCH",     row: [0,0,1,1,2,2,3,1] },
    { mode: "REVERSE",   row: [1,0,0,2,1,3,2,2] },
    { mode: "ADDITION",  row: [0,1,2,2,3,1,1,0] },
    { mode: "XOR",       row: [0,0,1,1,2,2,1,0] },
  ];
  const runs = [38, 42, 51, 48, 55, 60, 58, 71, 65, 80];
  return (
    <Phone label="03 Profile">
      <AppBar title="PROFILE" meta="@marko_ms" />
      <hr className="hr solid" style={{ margin: '0 18px 16px' }} />

      <div className="body" style={{ paddingBottom: 80 }}>
        {/* Identity */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
          <div style={{
            width: 56, height: 56, border: '1px solid var(--g-3)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 22, color: 'var(--g-4)', textShadow: 'var(--glow-md)',
            fontWeight: 700, letterSpacing: '0.05em',
          }}>MM</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, color: 'var(--g-4)', textShadow: 'var(--glow-sm)', letterSpacing: '0.08em', fontWeight: 600 }}>MARKO M.</div>
            <div style={{ fontSize: 10, color: 'var(--g-2)', letterSpacing: '0.1em', marginTop: 3 }}>JOINED 12 DAYS AGO · 142 RUNS</div>
            <div style={{ marginTop: 6 }}><span className="tier-badge">TIER · T2 · 1/3 → T3</span></div>
          </div>
        </div>

        <div className="kicker">CORE STATS</div>
        <div className="row"><span className="lbl">ACCURACY</span><span className="val">86.4%</span></div>
        <div className="row"><span className="lbl">AVG TIME / Q</span><span className="val">2.1s</span></div>
        <div className="row"><span className="lbl">TOTAL CORRECT</span><span className="val">1,247</span></div>
        <div className="row"><span className="lbl">WEAKEST MODE</span><span className="val amber">ADDITION · 71%</span></div>
        <div className="row"><span className="lbl">DAILY STREAK</span><span className="val">×7d</span></div>

        <div className="kicker" style={{ marginTop: 22 }}>RUN HISTORY · LAST 10</div>
        <div className="spark">
          {runs.map((v, i) => (
            <div key={i} className={"b" + (v === Math.max(...runs) ? " peak" : "")} style={{ height: `${v / 90 * 100}%` }} />
          ))}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.1em', marginTop: 4 }}>
          <span>10 RUNS AGO</span><span>NOW</span>
        </div>

        <div className="kicker" style={{ marginTop: 22 }}>BIT HEATMAP · ERRORS</div>
        <div style={{ display: 'flex', gap: 4, fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.1em', marginBottom: 4, paddingLeft: 64 }}>
          {[128,64,32,16,8,4,2,1].map(w => <div key={w} style={{ flex: 1, textAlign: 'center' }}>{w}</div>)}
        </div>
        {heat.map((r) => (
          <div key={r.mode} style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
            <div style={{ width: 56, fontSize: 10, color: 'var(--g-2)', letterSpacing: '0.1em' }}>{r.mode}</div>
            <div className="heat-row" style={{ flex: 1 }}>
              {r.row.map((h, i) => <div key={i} className="heat-cell" data-h={h}>{h > 0 ? h : ''}</div>)}
            </div>
          </div>
        ))}
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.1em', marginTop: 6 }}>
          <span>· 0 ERR</span><span className="dim">· LOW</span><span className="amber">· MED</span><span className="red">· HIGH</span>
        </div>
      </div>
      <Dock active="stats" />
    </Phone>
  );
}

Object.assign(window, { HomeScreen, ReferenceScreen, ProfileScreen });
