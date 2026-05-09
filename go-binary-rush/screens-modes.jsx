// Speed Burst, Hex Match, Daily Challenge

// ── 5. SPEED BURST ───────────────────────────────────────────
function SpeedBurstScreen() {
  return (
    <Phone label="09 Speed Burst">
      <AppBar title="SPEED BURST" meta="60s blitz" />

      {/* Custom HUD with timer ring */}
      <div className="hud" style={{ alignItems: 'center' }}>
        <div className="cell">
          <div className="k">SCORE</div>
          <div className="v">128</div>
          <div className="sub">+10/Q</div>
        </div>
        <div className="cell">
          <div className="k">CORRECT</div>
          <div className="v">12<span className="dim" style={{ fontSize: 11 }}>/14</span></div>
          <div className="sub">86% ACC</div>
        </div>
        <div className="cell" style={{ alignItems: 'center' }}>
          <div className="k">TIME</div>
          <TimerRing value={18} total={60} />
        </div>
        <div className="cell">
          <div className="k">×COMBO</div>
          <div className="v">×7</div>
          <div className="sub">2× MULT</div>
        </div>
      </div>

      <div className="body" style={{ paddingTop: 14 }}>
        {/* Mini queue preview */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'center', marginBottom: 10 }}>
          <span className="dim" style={{ fontSize: 9, letterSpacing: '0.18em' }}>QUEUE</span>
          <div style={{ display:'flex', gap: 6 }}>
            {[13, 7, 4, 21].map((n, i) => (
              <div key={i} style={{
                border:'1px solid ' + (i === 0 ? 'var(--g-3)' : 'var(--g-1)'),
                padding:'2px 8px', borderRadius: 2, fontSize: 11,
                color: i === 0 ? 'var(--g-4)' : 'var(--g-2)',
                textShadow: i === 0 ? 'var(--glow-sm)' : 'none',
                fontVariantNumeric: 'tabular-nums',
              }}>{n}</div>
            ))}
            <span className="dimmer" style={{ fontSize: 11 }}>…</span>
          </div>
        </div>

        <div className="target-box" style={{ marginTop: 10 }}>
          <span className="lbl">DECIMAL → BINARY</span>
          <span className="val med">13</span>
        </div>

        <BitWeights count={4} on={[0, 2, 3]} live={2} />
        <BitRow bits={[1,1,0,1]} flashIndex={2} />

        <div className="live-decimal" style={{ marginTop: 10 }}>
          <span className="bright">8</span>
          <span className="dimmer">+</span>
          <span className="bright">4</span>
          <span className="dimmer">+</span>
          <span className="dim">0</span>
          <span className="dimmer">+</span>
          <span className="bright">1</span>
          <span className="dimmer">=</span>
          <span className="num match">13</span>
        </div>

        <div style={{ marginTop: 16 }}>
          <AsciiFeedback>[ OK ]  ✓  +20 PTS  ·  ×7</AsciiFeedback>
        </div>

        {/* Recent answer trail */}
        <div style={{ display: 'flex', gap: 4, marginTop: 14, justifyContent: 'center' }}>
          {[1,1,1,1,0,1,1,1,1,1,1,1,1,1].map((ok, i) => (
            <div key={i} style={{
              width: 9, height: 9,
              background: ok ? 'var(--g-3)' : 'var(--red)',
              boxShadow: ok ? 'var(--glow-sm)' : 'var(--glow-red)',
              borderRadius: 1,
              opacity: 0.4 + i * 0.045,
            }} />
          ))}
        </div>
      </div>
    </Phone>
  );
}

// ── 6. HEX MATCH (binary → hex, with nibble grouping) ────────
function HexMatchScreen() {
  // 11010110 → D6
  const high = [1,1,0,1]; // D
  const low  = [0,1,1,0]; // 6
  return (
    <Phone label="10 Hex Match">
      <AppBar title="HEX MATCH" meta="bin → hex" />
      <Hud tier="T1" tierProg="1/10" score={20} streak={2} best={110} />

      <div className="body" style={{ paddingTop: 8 }}>
        <Pips total={10} current={2} />

        <div className="kicker bright" style={{ textAlign:'center', marginTop: 22, marginBottom: 6 }}>BINARY · 8-BIT</div>

        {/* nibble brackets */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: 14 }}>
          <div className="nibble-bracket active">
            <span className="lbl">HIGH · 8 4 2 1</span>
            <BitRow bits={high} size="sm" />
          </div>
          <div className="nibble-bracket">
            <span className="lbl">LOW · 8 4 2 1</span>
            <BitRow bits={low} size="sm" />
          </div>
        </div>

        {/* arrow + computed hex */}
        <div style={{ textAlign: 'center', marginTop: 14, fontSize: 16, color: 'var(--g-2)', letterSpacing: '0.2em' }}>
          ↓ <span className="dim" style={{ fontSize: 10 }}>NIBBLE → HEX DIGIT</span>
        </div>

        <div style={{ display:'flex', justifyContent:'center', gap: 28, marginTop: 6 }}>
          <div style={{
            width: 56, height: 56, border:'1px solid var(--g-3)', borderRadius: 2,
            display:'flex', alignItems:'center', justifyContent:'center',
            fontSize: 28, color:'var(--g-5)', textShadow:'var(--glow-md)', fontWeight: 700,
          }}>D</div>
          <div style={{
            width: 56, height: 56, border:'1px dashed var(--g-1)', borderRadius: 2,
            display:'flex', alignItems:'center', justifyContent:'center',
            fontSize: 28, color:'var(--g-1)', fontWeight: 700,
          }}>_<span className="caret"></span></div>
        </div>

        {/* hex keypad */}
        <div className="keypad" style={{ marginTop: 18 }}>
          {['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'].map(k =>
            <button key={k} className="key">{k}</button>
          )}
        </div>

        <div style={{ display:'flex', gap: 6, marginTop: 10 }}>
          <button className="btn ghost" style={{ flex: 1 }}>⌫</button>
          <button className="btn block" style={{ flex: 2 }}>CONFIRM ↵</button>
        </div>
      </div>
    </Phone>
  );
}

// ── 7. DAILY CHALLENGE (entry / preview) ─────────────────────
function DailyScreen() {
  return (
    <Phone label="11 Daily">
      <AppBar title="DAILY · MAY 09" meta="seed #129" />
      <hr className="hr solid" style={{ margin: '0 18px 16px' }} />

      <div className="body" style={{ paddingBottom: 80 }}>
        {/* Big timer */}
        <div style={{
          border: '1px solid var(--g-1)', padding: '14px 16px', marginBottom: 18,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between'
        }}>
          <div>
            <div className="kicker">RESETS IN</div>
            <div style={{ fontSize: 26, color: 'var(--g-4)', textShadow:'var(--glow-md)', fontWeight: 700, fontVariantNumeric: 'tabular-nums', letterSpacing: '0.06em' }}>
              04:13:22
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div className="kicker">PARTICIPANTS</div>
            <div style={{ fontSize: 18, color: 'var(--g-3)', fontWeight: 600 }}>2,847</div>
          </div>
        </div>

        <div className="kicker">TODAY'S RUN · 10 QUESTIONS</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5,1fr)', gap: 6, marginBottom: 16 }}>
          {[
            { i: 1, m: "MATCH",    s: "ok" },
            { i: 2, m: "REVERSE",  s: "ok" },
            { i: 3, m: "ADD",      s: "miss" },
            { i: 4, m: "XOR",      s: "ok" },
            { i: 5, m: "MATCH",    s: "ok" },
            { i: 6, m: "HEX",      s: "cur" },
            { i: 7, m: "REVERSE",  s: "next" },
            { i: 8, m: "ADD",      s: "next" },
            { i: 9, m: "XOR",      s: "next" },
            { i:10, m: "MATCH",    s: "next" },
          ].map((q) => {
            let color = 'var(--g-1)', border = 'var(--g-1)', glow = 'none';
            if (q.s === 'ok')   { color = 'var(--g-3)'; border = 'var(--g-2)'; glow = 'var(--glow-sm)'; }
            if (q.s === 'miss') { color = 'var(--red)'; border = 'rgba(255,77,77,0.4)'; glow = 'var(--glow-red)'; }
            if (q.s === 'cur')  { color = 'var(--g-4)'; border = 'var(--g-3)'; glow = 'var(--glow-md)'; }
            return (
              <div key={q.i} style={{
                border: '1px solid ' + border, borderRadius: 2,
                padding: '8px 4px', textAlign: 'center', boxShadow: glow,
              }}>
                <div style={{ fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.1em' }}>Q{String(q.i).padStart(2,'0')}</div>
                <div style={{ fontSize: 11, color, marginTop: 2, letterSpacing: '0.05em' }}>{q.m}</div>
                <div style={{ fontSize: 9, color, marginTop: 2 }}>
                  {q.s === 'ok' && '✓'}
                  {q.s === 'miss' && '✗'}
                  {q.s === 'cur' && '▶'}
                  {q.s === 'next' && '·'}
                </div>
              </div>
            );
          })}
        </div>

        <div className="row"><span className="lbl">SCORE</span><span className="val">42</span></div>
        <div className="row"><span className="lbl">CORRECT</span><span className="val">4 / 5</span></div>
        <div className="row"><span className="lbl">EST. RANK</span><span className="val">#147 / 2,847</span></div>

        <div style={{ marginTop: 18 }}>
          <button className="btn block">CONTINUE Q06 →</button>
        </div>

        <div style={{ marginTop: 12, textAlign: 'center', fontSize: 9, color: 'var(--g-1)', letterSpacing: '0.16em' }}>
          SAME SEED FOR EVERYONE · NO DO-OVERS
        </div>
      </div>
      <Dock active="play" />
    </Phone>
  );
}

Object.assign(window, { SpeedBurstScreen, HexMatchScreen, DailyScreen });
