// Shared atoms for Go Binary Rush mockups
// Loaded as <script type="text/babel" src="atoms.jsx"></script>

const { useState, useEffect, useMemo } = React;

// ── Phone frame ──────────────────────────────────────────────
function Phone({ children, label }) {
  return (
    <div className="phone" data-screen-label={label}>
      <StatusBar />
      {children}
    </div>
  );
}

function StatusBar() {
  return (
    <div className="statusbar">
      <span className="time">09:41</span>
      <span className="right">
        <span style={{ fontSize: 9, letterSpacing: '0.1em' }}>BIN</span>
        <span className="dot on"></span>
        <span className="dot on"></span>
        <span className="dot"></span>
        <span style={{ fontSize: 9, letterSpacing: '0.05em' }}>87%</span>
      </span>
    </div>
  );
}

// ── App bar ──────────────────────────────────────────────────
function AppBar({ title = "GO BINARY RUSH", back = true, meta }) {
  return (
    <div className="appbar">
      {back && (
        <div className="back">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
            <path d="M9 2 L4 7 L9 12" stroke="currentColor" strokeWidth="1.4" strokeLinecap="square" fill="none" />
          </svg>
        </div>
      )}
      <span className="title">{title}</span>
      <span className="spacer"></span>
      {meta && <span className="meta">{meta}</span>}
    </div>
  );
}

// ── HUD strip (tier / score / streak / best) ─────────────────
function Hud({ tier = "T1", tierProg = "1/3", score = 0, streak = 0, best = 0, mistake = false }) {
  return (
    <div className="hud">
      <div className="cell">
        <div className="k">TIER</div>
        <div className="v">{tier}</div>
        <div className="sub">{tierProg}</div>
      </div>
      <div className="cell">
        <div className="k">SCORE</div>
        <div className="v">{score}</div>
        <div className="sub">+10/Q</div>
      </div>
      <div className={"cell" + (mistake ? " amber" : "")}>
        <div className="k">STREAK</div>
        <div className="v">×{streak}</div>
        <div className="sub">{streak >= 3 ? "ON FIRE" : "BUILD"}</div>
      </div>
      <div className="cell">
        <div className="k">BEST</div>
        <div className="v">{best}</div>
        <div className="sub">ALL-TIME</div>
      </div>
    </div>
  );
}

// ── Bit tile ─────────────────────────────────────────────────
function Bit({ on, locked, dim, flash, size = "md", children }) {
  const cls = ["bit"];
  if (size === "sm") cls.push("sm");
  if (size === "xs") cls.push("xs");
  if (on) cls.push("on");
  if (locked) cls.push("locked");
  if (dim) cls.push("dim");
  if (flash) cls.push("flash");
  return <div className={cls.join(" ")}>{children ?? (on ? "1" : "0")}</div>;
}

// Bit weights ladder: 128 64 32 16 8 4 2 1
function BitWeights({ count = 4, on = [], live }) {
  const weights = [];
  for (let i = count - 1; i >= 0; i--) weights.push(1 << i);
  return (
    <div className="weights">
      {weights.map((w, i) => {
        const cls = ["w"];
        if (on.includes(i)) cls.push("active");
        if (live === i) cls.push("live");
        return <div key={i} className={cls.join(" ")}>{w}</div>;
      })}
    </div>
  );
}

// Render a bit row from a bool[] / number[]
function BitRow({ bits, locked, flashIndex, size = "md" }) {
  return (
    <div className={"bit-row" + (size === "sm" ? " tight" : "")}>
      {bits.map((b, i) => (
        <Bit key={i} on={!!b} locked={locked} flash={flashIndex === i} size={size}>{b ? "1" : "0"}</Bit>
      ))}
    </div>
  );
}

// ── ASCII feedback line ──────────────────────────────────────
function AsciiFeedback({ kind = "ok", children }) {
  let cls = "ascii-feedback";
  if (kind === "err") cls += " err";
  if (kind === "amber") cls += " amber";
  return <div className={cls}>{children}</div>;
}

// ── Pips (progress) ──────────────────────────────────────────
function Pips({ total, current, missed = [] }) {
  const arr = [];
  for (let i = 0; i < total; i++) {
    let cls = "pip";
    if (missed.includes(i)) cls += " miss";
    else if (i < current) cls += " done";
    else if (i === current) cls += " cur";
    arr.push(<div key={i} className={cls} />);
  }
  return <div className="pips">{arr}</div>;
}

// ── Timer ring ───────────────────────────────────────────────
function TimerRing({ value, total = 60, label }) {
  const r = 28;
  const c = 2 * Math.PI * r;
  const pct = value / total;
  return (
    <div className="ring-wrap">
      <svg width="64" height="64">
        <circle cx="32" cy="32" r={r} stroke="rgba(40,90,50,0.25)" strokeWidth="3" fill="none" />
        <circle cx="32" cy="32" r={r} stroke="#7dff97" strokeWidth="3" fill="none"
          strokeDasharray={c} strokeDashoffset={c * (1 - pct)}
          strokeLinecap="square"
          style={{ filter: 'drop-shadow(0 0 4px rgba(125,255,151,0.7))' }} />
      </svg>
      <div className="num">{value}</div>
    </div>
  );
}

// ── Bottom dock ──────────────────────────────────────────────
function Dock({ active = "play" }) {
  const tabs = [
    { id: "play", ico: "▶", l: "PLAY" },
    { id: "stats", ico: "▤", l: "STATS" },
    { id: "ach", ico: "★", l: "ACHV" },
    { id: "ref", ico: "?", l: "REF" },
  ];
  return (
    <div className="dock">
      {tabs.map(t => (
        <div key={t.id} className={"tab" + (t.id === active ? " on" : "")}>
          <span className="ico">{t.ico}</span>
          <span>{t.l}</span>
        </div>
      ))}
    </div>
  );
}

// ── Helpers ──────────────────────────────────────────────────
function toBits(n, w) {
  const out = [];
  for (let i = w - 1; i >= 0; i--) out.push((n >> i) & 1);
  return out;
}
function bitsToNum(bits) { return bits.reduce((a, b) => (a << 1) | (b ? 1 : 0), 0); }

Object.assign(window, {
  Phone, AppBar, Hud, Bit, BitRow, BitWeights, AsciiFeedback,
  Pips, TimerRing, Dock, StatusBar, toBits, bitsToNum,
});
