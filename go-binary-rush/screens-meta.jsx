// Meta: Result, Run Summary, Achievements, Leaderboard, Game Over

// ── RESULT (mid-question feedback overlay) ───────────────────
function MissScreen() {
  return (
    <Phone label="12 Match · MISS">
      <AppBar title="MATCH" meta="dec → bin" />
      <Hud tier="T1" tierProg="1/3" score={40} streak={0} best={240} mistake />

      <div className="body" style={{ paddingTop: 12 }}>
        <Pips total={5} current={3} missed={[2]} />
        <div style={{ display:'flex', justifyContent:'space-between', fontSize: 9, color:'var(--g-2)', letterSpacing:'0.16em', marginTop: 8 }}>
          <span>Q 03/05</span>
          <span className="red">STREAK BROKEN</span>
        </div>

        <div className="target-box" style={{ marginTop: 22 }}>
          <span className="lbl">TARGET</span>
          <span className="val red">11</span>
        </div>

        <BitWeights count={4} on={[0,1,3]} />

        {/* user's answer (wrong) */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
          <div className="kicker" style={{ color: 'var(--red)', marginBottom: 0 }}>YOU · 1101 = 13</div>
          <div className="bit-row">
            {[1,1,0,1].map((b,i) => {
              const isWrong = i === 1 || i === 2;
              return (
                <div key={i} className="bit on" style={{
                  borderColor: isWrong ? 'var(--red)' : 'var(--g-2)',
                  color: isWrong ? 'var(--red)' : 'var(--g-3)',
                  textShadow: isWrong ? 'var(--glow-red)' : 'var(--glow-sm)',
                  background: isWrong ? 'rgba(255,77,77,0.1)' : 'transparent',
                  boxShadow: isWrong ? 'var(--glow-red)' : 'none',
                }}>{b}</div>
              );
            })}
          </div>

          <div style={{ fontSize: 10, color: 'var(--g-2)', letterSpacing: '0.12em', marginTop: 6 }}>CORRECT</div>
          <div className="bit-row">
            {[1,0,1,1].map((b,i) => (
              <div key={i} className={"bit " + (b ? "on" : "")} style={{
                borderColor: 'var(--g-3)',
                opacity: 0.85,
              }}>{b}</div>
            ))}
          </div>
        </div>

        <div style={{ marginTop: 16 }}>
          <AsciiFeedback kind="err">[ MISS ]  ✗  STREAK ×0  ·  −1 LIFE</AsciiFeedback>
        </div>

        <div className="hint-card" style={{ marginTop: 14 }}>
          <div className="h" style={{ color: 'var(--red)' }}>$ DIFF</div>
          Bit <code className="amber">2</code> (weight 4) and bit <code className="amber">1</code> (weight 2) were swapped.
          <div style={{ marginTop: 4 }} className="dim">8 + <span className="amber">4</span> + 0 + 1 = 13   ·   8 + 0 + <span className="bright">2</span> + 1 = 11</div>
        </div>
      </div>
    </Phone>
  );
}

// ── RUN SUMMARY / GAME OVER ──────────────────────────────────
function RunSummaryScreen() {
  const answers = [1,1,0,1,1,1,1,0,1,1,1,1,1,0,1]; // 1 = ok
  return (
    <Phone label="13 Run Summary">
      <AppBar title="RUN COMPLETE" back={false} meta="MATCH · T2" />
      <hr className="hr solid" style={{ margin: '0 18px 16px' }} />

      <div className="body" style={{ paddingBottom: 80 }}>
        {/* Big score banner */}
        <div style={{ textAlign: 'center', margin: '8px 0 18px' }}>
          <div className="ascii" style={{ color: 'var(--g-2)', marginBottom: 8 }}>
{`╔═══════════════════════╗
║      [ COMPLETE ]     ║
╚═══════════════════════╝`}
          </div>
          <div className="kicker bright" style={{ marginBottom: 4 }}>FINAL SCORE</div>
          <div style={{ fontSize: 56, fontWeight: 700, color: 'var(--g-5)', textShadow: 'var(--glow-lg)', lineHeight: 1, fontVariantNumeric: 'tabular-nums' }}>
            247
          </div>
          <div className="dim" style={{ fontSize: 11, letterSpacing: '0.16em', marginTop: 4 }}>
            <span className="amber">+ NEW BEST</span> · prev 240
          </div>
        </div>

        <div className="row"><span className="lbl">CORRECT</span><span className="val">12 / 15  · 80%</span></div>
        <div className="row"><span className="lbl">AVG TIME</span><span className="val">1.8s</span></div>
        <div className="row"><span className="lbl">BEST STREAK</span><span className="val">×7</span></div>
        <div className="row"><span className="lbl">XP EARNED</span><span className="val cyan">+ 47 XP</span></div>

        <div className="kicker" style={{ marginTop: 18 }}>QUESTION TIMELINE</div>
        <div style={{ display: 'flex', gap: 3 }}>
          {answers.map((ok, i) => (
            <div key={i} style={{
              flex: 1, height: 24,
              background: ok ? 'rgba(78,207,106,0.2)' : 'rgba(255,77,77,0.18)',
              borderTop: '2px solid ' + (ok ? 'var(--g-3)' : 'var(--red)'),
              boxShadow: ok ? 'inset 0 -2px 0 rgba(78,207,106,0.3)' : 'inset 0 -2px 0 rgba(255,77,77,0.3)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 9, color: ok ? 'var(--g-3)' : 'var(--red)', fontWeight: 600,
            }}>{ok ? '✓' : '✗'}</div>
          ))}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.12em', marginTop: 4 }}>
          <span>Q01</span><span>Q15</span>
        </div>

        {/* Tier progress */}
        <div className="kicker" style={{ marginTop: 18 }}>TIER PROGRESS</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span className="bright">T2</span>
          <div style={{ flex: 1, height: 6, border: '1px solid var(--g-1)', borderRadius: 1 }}>
            <div style={{ height: '100%', width: '65%', background: 'var(--g-3)', boxShadow: 'var(--glow-sm)' }} />
          </div>
          <span className="dim">T3</span>
        </div>
        <div className="dim" style={{ fontSize: 9, letterSpacing:'0.12em', marginTop: 4 }}>2 / 3 RUNS · 1 LEFT TO PROMOTE</div>

        <div style={{ marginTop: 18, display: 'flex', gap: 8 }}>
          <button className="btn ghost" style={{ flex: 1 }}>HOME</button>
          <button className="btn block" style={{ flex: 2 }}>RUN AGAIN ↵</button>
        </div>
      </div>
    </Phone>
  );
}

// ── ACHIEVEMENTS ─────────────────────────────────────────────
function AchievementsScreen() {
  const list = [
    { g: '◉', name: "FIRST BIT",          sub: "complete your first run",       u: true,  prog: "1/1" },
    { g: '⊕', name: "XOR APPRENTICE",     sub: "100 correct XOR answers",       u: true,  prog: "100/100" },
    { g: '⏱', name: "BLITZ",              sub: "reach 200 in speed burst",      u: true,  prog: "247/200" },
    { g: '∞', name: "STREAK ×10",         sub: "10 in a row, any mode",         u: false, prog: "×7" },
    { g: '◆', name: "TIER 3 PROMOTED",    sub: "win 3 runs in a row at T2",     u: false, prog: "1/3" },
    { g: '⚡', name: "SUB-SECOND",         sub: "answer in under 1.0s · 50×",    u: false, prog: "12/50" },
    { g: '✦', name: "PERFECTIONIST",      sub: "100% on a 15-Q run",            u: false, prog: "—" },
    { g: '☀', name: "DAILY × 30",         sub: "complete 30 daily challenges",  u: false, prog: "7/30" },
  ];
  return (
    <Phone label="14 Achievements">
      <AppBar title="ACHIEVEMENTS" meta="3/8 · 38%" />
      <hr className="hr solid" style={{ margin: '0 18px 16px' }} />

      <div className="body" style={{ paddingBottom: 80 }}>
        {/* progress bar */}
        <div style={{ display: 'flex', alignItems:'center', gap: 8, marginBottom: 16 }}>
          <span className="bright" style={{ fontWeight: 600 }}>3</span>
          <div style={{ flex: 1, height: 5, border: '1px solid var(--g-1)', borderRadius: 1 }}>
            <div style={{ height: '100%', width: '38%', background: 'var(--g-3)', boxShadow: 'var(--glow-sm)' }} />
          </div>
          <span className="dim">8</span>
        </div>

        {list.map((a, i) => (
          <div key={i} className={"ach" + (a.u ? " unlocked" : "")}>
            <div className="glyph">{a.g}</div>
            <div>
              <div className="name">{a.name}</div>
              <div className="sub">{a.sub}</div>
            </div>
            <div className="lock">{a.u ? '✓ ' + a.prog : a.prog}</div>
          </div>
        ))}
      </div>
      <Dock active="ach" />
    </Phone>
  );
}

// ── LEADERBOARD ──────────────────────────────────────────────
function LeaderboardScreen() {
  const board = [
    { r:  1, n: "h3x_dragon",   s: 412, you: false },
    { r:  2, n: "byteSmith",    s: 388, you: false },
    { r:  3, n: "nibbler",      s: 351, you: false },
    { r:  4, n: "01__loop",     s: 318, you: false },
    { r:  5, n: "marko_ms",     s: 247, you: true },
    { r:  6, n: "bitflip",      s: 230, you: false },
    { r:  7, n: "asciigirl",    s: 211, you: false },
    { r:  8, n: "carry_one",    s: 199, you: false },
    { r:  9, n: "0xCAFE",       s: 184, you: false },
    { r: 10, n: "endian",       s: 172, you: false },
  ];
  return (
    <Phone label="15 Leaderboard">
      <AppBar title="LEADERBOARD" meta="DAILY · LOCAL" />

      {/* Tab chooser */}
      <div style={{ display: 'flex', gap: 6, padding: '0 18px 12px' }}>
        {['DAILY', 'WEEKLY', 'ALL-TIME'].map((t, i) => (
          <div key={t} style={{
            flex: 1, textAlign: 'center', padding: '6px 0', fontSize: 10, letterSpacing: '0.16em',
            border: '1px solid ' + (i === 0 ? 'var(--g-3)' : 'var(--g-1)'),
            color: i === 0 ? 'var(--g-4)' : 'var(--g-2)',
            textShadow: i === 0 ? 'var(--glow-sm)' : 'none',
            borderRadius: 2,
          }}>{t}</div>
        ))}
      </div>

      <div className="body" style={{ paddingTop: 0, paddingBottom: 80 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '24px 1fr auto', gap: 8, fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.16em', padding: '4px 0', borderBottom: '1px dashed var(--g-1)' }}>
          <span>#</span><span>HANDLE</span><span>SCORE</span>
        </div>
        {board.map((p) => (
          <div key={p.r} style={{
            display: 'grid', gridTemplateColumns: '24px 1fr auto', gap: 8,
            padding: '8px 0', borderBottom: '1px dashed var(--g-1)',
            background: p.you ? 'rgba(78,207,106,0.06)' : 'transparent',
            paddingLeft: p.you ? 6 : 0,
            marginLeft: p.you ? -6 : 0, marginRight: p.you ? -6 : 0,
            paddingRight: p.you ? 6 : 0,
            borderLeft: p.you ? '2px solid var(--g-3)' : 'none',
            alignItems: 'center',
          }}>
            <span style={{
              color: p.r <= 3 ? 'var(--amber)' : 'var(--g-2)',
              textShadow: p.r <= 3 ? 'var(--glow-amber)' : 'none',
              fontVariantNumeric: 'tabular-nums', fontWeight: p.r <= 3 ? 600 : 400,
            }}>{String(p.r).padStart(2,'0')}</span>
            <span style={{
              color: p.you ? 'var(--g-4)' : 'var(--g-3)',
              textShadow: p.you ? 'var(--glow-sm)' : 'none',
              fontWeight: p.you ? 600 : 400, fontSize: 12,
            }}>{p.n}{p.you && <span className="dim" style={{ marginLeft: 6, fontSize: 9, letterSpacing: '0.16em' }}>· YOU</span>}</span>
            <span style={{
              color: p.you ? 'var(--g-5)' : 'var(--g-3)',
              textShadow: p.you ? 'var(--glow-md)' : 'none',
              fontWeight: 600, fontVariantNumeric: 'tabular-nums',
            }}>{p.s}</span>
          </div>
        ))}

        <div className="dim" style={{ fontSize: 9, letterSpacing:'0.16em', textAlign:'center', marginTop: 14 }}>
          RESETS IN 04:13:22  ·  SEED #129
        </div>
      </div>
      <Dock active="stats" />
    </Phone>
  );
}

Object.assign(window, { MissScreen, RunSummaryScreen, AchievementsScreen, LeaderboardScreen });
