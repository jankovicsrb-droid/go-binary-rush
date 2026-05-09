// Game screens — MATCH, REVERSE, ADDITION, XOR

// ── 1. MATCH (decimal → binary) ──────────────────────────────
function MatchScreen() {
  // target = 11 → 1011
  const target = 11;
  const bits = [1, 0, 1, 1]; // 8+0+2+1 = 11
  const live = bitsToNum(bits);
  return (
    <Phone label="04 Match">
      <AppBar title="MATCH" meta="dec → bin" />
      <Hud tier="T1" tierProg="1/3" score={40} streak={4} best={240} />

      <div className="body" style={{ paddingTop: 12 }}>
        <Pips total={5} current={2} />
        <div style={{ display:'flex', justifyContent:'space-between', fontSize: 9, color:'var(--g-2)', letterSpacing:'0.16em', marginTop: 8 }}>
          <span>Q 03/05</span>
          <span>02.4s</span>
        </div>

        <div className="target-box" style={{ marginTop: 28 }}>
          <span className="lbl">TARGET</span>
          <span className="val">{target}</span>
          <span className="dim" style={{ fontSize: 10, letterSpacing: '0.16em', marginTop: 2 }}>
            DECIMAL · ENCODE TO 4-BIT
          </span>
        </div>

        <BitWeights count={4} on={[0, 2, 3]} live={2} />
        <BitRow bits={bits} flashIndex={2} />

        <div className="live-decimal">
          <span>1·8</span>
          <span className="dimmer">+</span>
          <span>0·4</span>
          <span className="dimmer">+</span>
          <span>1·2</span>
          <span className="dimmer">+</span>
          <span>1·1</span>
          <span className="dimmer">=</span>
          <span className="num match">{live}</span>
        </div>

        <div style={{ marginTop: 22, textAlign: 'center' }}>
          <span style={{ fontSize: 11, color: 'var(--amber)', letterSpacing: '0.18em', cursor: 'pointer' }}>[ HINT · −2 ]</span>
        </div>

        <div style={{ marginTop: 10, textAlign: 'center', fontSize: 10, color: 'var(--g-1)', letterSpacing: '0.18em' }}>
          TAP A BIT TO TOGGLE
        </div>
      </div>
    </Phone>
  );
}

// ── MATCH — correct feedback state ───────────────────────────
function MatchCorrectScreen() {
  return (
    <Phone label="05 Match · OK">
      <AppBar title="MATCH" meta="dec → bin" />
      <Hud tier="T1" tierProg="1/3" score={50} streak={5} best={240} />

      <div className="body" style={{ paddingTop: 12 }}>
        <Pips total={5} current={3} />
        <div style={{ display:'flex', justifyContent:'space-between', fontSize: 9, color:'var(--g-2)', letterSpacing:'0.16em', marginTop: 8 }}>
          <span>Q 03/05 · LOCKED</span>
          <span className="bright">+10 · ×5</span>
        </div>

        <div className="target-box" style={{ marginTop: 28 }}>
          <span className="lbl">TARGET</span>
          <span className="val hot">11</span>
        </div>

        <BitWeights count={4} on={[0, 2, 3]} />
        <BitRow bits={[1,0,1,1]} locked />

        <div style={{ marginTop: 22 }}>
          <AsciiFeedback>[ OK ]  ✓  +10 PTS  ·  STREAK ×5</AsciiFeedback>
        </div>

        <div style={{ textAlign: 'center', marginTop: 12, fontSize: 11, color: 'var(--g-2)', letterSpacing: '0.16em' }}>
          NEXT IN 0.4s<span className="caret"></span>
        </div>

        <div className="ascii" style={{ textAlign: 'center', marginTop: 18, color: 'var(--g-3)' }}>
{`8  +  0  +  2  +  1  =  11
▲              ▲     ▲`}
        </div>
      </div>
    </Phone>
  );
}

// ── 2. REVERSE (binary → decimal) ────────────────────────────
function ReverseScreen() {
  // 1010 → 10
  return (
    <Phone label="06 Reverse">
      <AppBar title="REVERSE" meta="bin → dec" />
      <Hud tier="T1" tierProg="1/3" score={20} streak={2} best={180} />

      <div className="body" style={{ paddingTop: 12 }}>
        <Pips total={5} current={2} />
        <div style={{ display:'flex', justifyContent:'space-between', fontSize: 9, color:'var(--g-2)', letterSpacing:'0.16em', marginTop: 8 }}>
          <span>Q 03/05</span>
          <span>01.7s</span>
        </div>

        <div className="kicker bright" style={{ textAlign:'center', marginTop: 22 }}>DECODE</div>
        <BitWeights count={4} on={[1, 3]} />
        <BitRow bits={[1,0,1,0]} locked />

        <div className="live-decimal" style={{ marginTop: 8 }}>
          <span className="bright">8</span>
          <span className="dimmer">+</span>
          <span className="dim">0</span>
          <span className="dimmer">+</span>
          <span className="bright">2</span>
          <span className="dimmer">+</span>
          <span className="dim">0</span>
          <span className="dimmer">=</span>
          <span className="num">?</span>
        </div>

        <div className="kicker" style={{ textAlign:'center', marginTop: 24 }}>DECIMAL VALUE?</div>
        <div className="field" style={{ margin: '0 60px' }}>
          <span>1</span><span className="caret"></span>
        </div>

        {/* numeric keypad */}
        <div className="keypad three" style={{ marginTop: 18 }}>
          {['1','2','3','4','5','6','7','8','9'].map(k =>
            <button key={k} className="key">{k}</button>
          )}
          <button className="key dim">·</button>
          <button className="key">0</button>
          <button className="key action">⌫</button>
        </div>

        <button className="btn block" style={{ marginTop: 14 }}>CONFIRM ↵</button>
      </div>
    </Phone>
  );
}

// ── 3. ADDITION (binary column add with carry) ───────────────
function AdditionScreen() {
  // a = 1011 (11), b = 0110 (6), target = 17 (10001)
  const a = [1,0,1,1];
  const b = [0,1,1,0];
  const c = [1,0,0,0,1]; // result row (5 bits)
  const carry = [1,1,1,0,0]; // tiny carry markers
  return (
    <Phone label="07 Addition">
      <AppBar title="ADDITION" meta="a + b = c" />
      <Hud tier="T1" tierProg="2/3" score={60} streak={3} best={90} />

      <div className="body" style={{ paddingTop: 8 }}>
        <Pips total={5} current={1} />

        <div style={{ marginTop: 24 }}>
          <BitWeights count={4} on={[0,1,2,3]} />

          {/* carry row */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginBottom: 4, paddingLeft: 28 }}>
            {carry.slice(0,4).map((v,i) => (
              <div key={i} style={{ width: 52, textAlign: 'center', fontSize: 10, color: v ? 'var(--amber)' : 'var(--g-1)', textShadow: v ? 'var(--glow-amber)' : 'none', letterSpacing: '0.1em' }}>
                {v ? '⤴ 1' : '·'}
              </div>
            ))}
          </div>

          <Row label="A" bits={a} hint="11" />
          <div style={{ height: 6 }} />
          <Row label="B" bits={b} hint="6" plus />
          <div style={{ borderTop: '1px solid var(--g-2)', margin: '10px 28px 8px' }} />
          <Row label="C" bits={c} hint="17" wide />

          <div style={{ textAlign:'center', marginTop: 12, fontSize: 11, color:'var(--g-2)', letterSpacing:'0.16em' }}>
            TARGET <span className="bright">17</span> · CURRENT <span className="bright">17</span> ✓
          </div>
        </div>

        <div className="hint-card" style={{ marginTop: 18 }}>
          <div className="h">$ HOW IT WORKS</div>
          Add column-by-column right→left. <code className="amber">1+1 = 10</code>: write 0, carry 1 to the next column.
        </div>
      </div>
    </Phone>
  );
}

function Row({ label, bits, hint, plus, wide }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
      <div style={{ width: 18, color: 'var(--g-2)', fontSize: 11, letterSpacing: '0.16em' }}>{plus ? '+' : ''}</div>
      <div style={{ width: 14, color: 'var(--g-3)', fontSize: 13, fontWeight: 600 }}>{label}</div>
      <div className="bit-row tight">
        {bits.map((b,i) => (
          <Bit key={i} on={!!b} size="sm">{b ? '1' : '0'}</Bit>
        ))}
      </div>
      <div style={{ width: 22, color: 'var(--g-1)', fontSize: 10, letterSpacing: '0.1em' }}>={hint}</div>
    </div>
  );
}

// ── 4. XOR ───────────────────────────────────────────────────
function XorScreen() {
  // a = 1011, b = 1010, c = 0001
  const a = [1,0,1,1];
  const b = [1,0,1,0];
  const c = [0,0,0,1];
  return (
    <Phone label="08 XOR">
      <AppBar title="XOR" meta="a ⊕ b" />
      <Hud tier="T1" tierProg="1/3" score={30} streak={1} best={60} />

      <div className="body" style={{ paddingTop: 8 }}>
        <Pips total={5} current={1} />

        <div style={{ display:'flex', justifyContent:'center', alignItems:'center', gap: 18, marginTop: 18, fontSize: 11, color: 'var(--g-2)', letterSpacing: '0.18em' }}>
          <span>A</span><span>⊕</span><span>B</span><span>=</span><span className="bright">C</span>
        </div>

        <div style={{ marginTop: 14 }}>
          <RowXor label="A" bits={a} highlight={[0,2,3]} />
          <div style={{ height: 4 }} />
          <RowXor label="B" bits={b} highlight={[0,2]} />
          <div style={{ borderTop: '1px solid var(--g-2)', margin: '12px 28px 8px' }} />
          <RowXor label="C" bits={c} editable />
        </div>

        <div style={{ textAlign:'center', marginTop: 14, fontSize: 12, color: 'var(--g-3)', letterSpacing: '0.1em' }}>
          = <span className="bright">{bitsToNum(c)}</span>
          <span className="dimmer" style={{ margin:'0 8px' }}>│</span>
          <span className="dim">target</span> <span className="bright">1</span>
        </div>

        {/* Inline truth-table reminder when hint is on */}
        <div style={{
          margin: '20px 0 0', display:'grid', gridTemplateColumns:'repeat(4,1fr)',
          gap: 4, fontSize: 11, textAlign:'center'
        }}>
          {[
            ['0⊕0','0'],['0⊕1','1'],['1⊕0','1'],['1⊕1','0'],
          ].map(([k,v]) => (
            <div key={k} style={{ border:'1px dashed var(--g-1)', padding:'6px 0', borderRadius: 2 }}>
              <div className="dim" style={{ fontSize: 9, letterSpacing: '0.05em' }}>{k}</div>
              <div className="bright" style={{ fontSize: 14, marginTop: 2 }}>{v}</div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 18 }}>
          <AsciiFeedback kind="amber">[ HINT · ⊕ FLIPS WHEN BITS DIFFER ]</AsciiFeedback>
        </div>
      </div>
    </Phone>
  );
}

function RowXor({ label, bits, highlight = [], editable }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
      <div style={{ width: 18, color: 'var(--g-3)', fontSize: 13, fontWeight: 600 }}>{label}</div>
      <div className="bit-row">
        {bits.map((b,i) => {
          const isHi = highlight.includes(i);
          return (
            <Bit key={i} on={!!b} size="md" locked={!editable && !isHi}>{b ? '1' : '0'}</Bit>
          );
        })}
      </div>
    </div>
  );
}

Object.assign(window, { MatchScreen, MatchCorrectScreen, ReverseScreen, AdditionScreen, XorScreen });
