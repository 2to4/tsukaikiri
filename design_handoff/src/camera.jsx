// camera.jsx — カメラ登録フロー（スマホ）: 撮影前 / 解析中 / 候補確認 / エラー
const { T, CATS, CAT_ORDER, Icon, CatTile } = window;

// striped placeholder to stand in for a real photo
function PhotoFill({ seed = 0, style = {} }) {
  const hues = ['#D9D3C6', '#CBD6C9', '#E0D2C4', '#CFD3DB', '#DDD6CC'];
  const a = hues[seed % hues.length];
  return (
    <div style={{ background: `repeating-linear-gradient(135deg, ${a} 0 7px, ${a}99 7px 14px)`, ...style }} />
  );
}

// ─────────────────────────────────────────────────────────────
// 1. Capture
// ─────────────────────────────────────────────────────────────
function CaptureScreen({ photos, onShutter, onLibrary, onRemove, onAnalyze, onClose }) {
  const MAX = 10;
  const full = photos.length >= MAX;
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: '#15140F' }}>
      {/* top bar */}
      <div style={{ paddingTop: T.statusPad, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: `${T.statusPad}px 16px 8px` }}>
        <button onClick={onClose} style={camIconBtn}><Icon name="close" size={22} color="#fff" /></button>
        <div style={{ color: '#fff', fontFamily: T.brand, fontSize: 17, fontWeight: 700 }}>冷蔵庫を撮影</div>
        <div style={{ width: 42 }} />
      </div>
      {/* viewfinder */}
      <div style={{ flex: 1, margin: '6px 16px 0', borderRadius: 24, position: 'relative', overflow: 'hidden',
        background: 'radial-gradient(120% 80% at 50% 20%, #2A2823 0%, #14130F 100%)' }}>
        {[['tl', { top: 18, left: 18 }], ['tr', { top: 18, right: 18 }], ['bl', { bottom: 18, left: 18 }], ['br', { bottom: 18, right: 18 }]].map(([k, pos]) => (
          <div key={k} style={{ position: 'absolute', width: 30, height: 30,
            borderTop: k[0] === 't' ? '3px solid rgba(255,255,255,0.6)' : 'none',
            borderBottom: k[0] === 'b' ? '3px solid rgba(255,255,255,0.6)' : 'none',
            borderLeft: k[1] === 'l' ? '3px solid rgba(255,255,255,0.6)' : 'none',
            borderRight: k[1] === 'r' ? '3px solid rgba(255,255,255,0.6)' : 'none',
            borderRadius: 8, ...pos }} />
        ))}
        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, padding: 24, textAlign: 'center' }}>
          <div style={{ width: 56, height: 56, borderRadius: 18, background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="camera" size={28} color="rgba(255,255,255,0.85)" />
          </div>
          <div style={{ color: 'rgba(255,255,255,0.92)', fontSize: 15, fontWeight: 700 }}>冷蔵庫の中が見えるように撮影</div>
          <div style={{ color: 'rgba(255,255,255,0.45)', fontSize: 12, fontFamily: 'ui-monospace, monospace', letterSpacing: 0.5 }}>カメラプレビュー</div>
        </div>
        {/* count chip */}
        <div style={{ position: 'absolute', top: 14, left: '50%', transform: 'translateX(-50%)',
          background: 'rgba(0,0,0,0.5)', color: '#fff', padding: '5px 13px', borderRadius: 999, fontSize: 12.5, fontWeight: 700 }}>
          {photos.length} / {MAX} 枚
        </div>
      </div>
      {/* thumbnails */}
      {photos.length > 0 && (
        <div style={{ display: 'flex', gap: 9, overflowX: 'auto', padding: '12px 16px 4px' }}>
          {photos.map((p, i) => (
            <div key={p} style={{ position: 'relative', flexShrink: 0 }}>
              <PhotoFill seed={i} style={{ width: 54, height: 54, borderRadius: 12 }} />
              <button onClick={() => onRemove(p)} style={{ position: 'absolute', top: -6, right: -6, width: 22, height: 22, borderRadius: 99,
                background: 'rgba(0,0,0,0.72)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="close" size={13} color="#fff" stroke={2.4} />
              </button>
            </div>
          ))}
        </div>
      )}
      {/* controls */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr auto 1fr', alignItems: 'center', padding: '14px 22px 30px' }}>
        <div style={{ justifySelf: 'start' }}>
          <button onClick={onLibrary} disabled={full} style={{ ...camIconBtn, opacity: full ? 0.4 : 1 }}>
            <Icon name="image" size={24} color="#fff" />
          </button>
        </div>
        <button onClick={onShutter} disabled={full} style={{ width: 74, height: 74, borderRadius: 99, cursor: full ? 'default' : 'pointer',
          background: 'transparent', border: '4px solid rgba(255,255,255,0.9)', padding: 4, opacity: full ? 0.4 : 1 }}>
          <div style={{ width: '100%', height: '100%', borderRadius: 99, background: '#fff' }} />
        </button>
        <div style={{ justifySelf: 'end' }}>
          <button onClick={onAnalyze} disabled={photos.length === 0} style={{ height: 50, borderRadius: 16, padding: '0 16px', cursor: photos.length ? 'pointer' : 'default',
            border: 'none', background: photos.length ? T.green : 'rgba(255,255,255,0.15)', color: '#fff',
            display: 'flex', alignItems: 'center', gap: 6, fontFamily: T.font, fontSize: 14.5, fontWeight: 800,
            boxShadow: photos.length ? '0 8px 20px rgba(31,122,85,0.4)' : 'none' }}>
            解析する <Icon name="chevron" size={17} color="#fff" stroke={2.4} />
          </button>
        </div>
      </div>
      {full && <div style={{ textAlign: 'center', color: 'rgba(255,255,255,0.6)', fontSize: 12, paddingBottom: 14, marginTop: -18 }}>最大10枚まで撮影できます</div>}
    </div>
  );
}
const camIconBtn = { width: 42, height: 42, borderRadius: 14, background: 'rgba(255,255,255,0.14)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' };

// ─────────────────────────────────────────────────────────────
// 2. Analyzing
// ─────────────────────────────────────────────────────────────
function AnalyzingScreen({ photos, onCancel }) {
  const steps = ['写真を読み取り中', '食材を検出中', '候補を作成中'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ paddingTop: T.statusPad }} />
      <div style={{ display: 'flex', gap: 8, justifyContent: 'center', padding: '18px 16px 0' }}>
        {photos.slice(0, 6).map((p, i) => <PhotoFill key={p} seed={i} style={{ width: 40, height: 40, borderRadius: 10 }} />)}
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 28, textAlign: 'center' }}>
        <div className="cam-pulse" style={{ width: 92, height: 92, borderRadius: 30, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}>
          <Icon name="spark" size={42} color={T.green} />
        </div>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>AIが食材を解析中</div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.sub }}>写真 {photos.length} 枚から食材を探しています</div>
        <div style={{ width: 200, height: 6, borderRadius: 99, background: '#E6E2D9', overflow: 'hidden', marginTop: 14 }}>
          <div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 7, marginTop: 18 }}>
          {steps.map((s, i) => (
            <div key={s} className="cam-step" style={{ animationDelay: `${i * 0.7}s`, display: 'flex', alignItems: 'center', gap: 8, fontSize: 13, fontWeight: 600, color: T.sub }}>
              <span style={{ width: 16, height: 16, borderRadius: 99, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="check" size={11} color={T.green} stroke={3} />
              </span>{s}
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: '0 16px 32px', textAlign: 'center' }}>
        <button onClick={onCancel} style={{ background: 'none', border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 14.5, fontWeight: 700, color: T.sub }}>キャンセル</button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 3. Review candidates (★ main)
// ─────────────────────────────────────────────────────────────
function ConfTag({ conf }) {
  const map = { high: ['確信度 高', T.green, T.greenSoft], mid: ['確信度 中', T.plenty, T.plentySoft], low: ['要確認', T.near, T.nearSoft] };
  const [label, color, soft] = map[conf];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '3px 9px', borderRadius: 999, background: soft, flexShrink: 0 }}>
      <span style={{ width: 6, height: 6, borderRadius: 99, background: color }} />
      <span style={{ fontSize: 11, fontWeight: 700, color }}>{label}</span>
    </span>
  );
}
function Check({ on, onClick }) {
  return (
    <button onClick={onClick} style={{ width: 26, height: 26, borderRadius: 8, cursor: 'pointer', flexShrink: 0,
      border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff',
      display: 'flex', alignItems: 'center', justifyContent: 'center', marginTop: 2 }}>
      {on && <Icon name="check" size={16} color="#fff" stroke={3} />}
    </button>
  );
}
function CandidateCard({ c, onChange, catOpen, setCatOpen }) {
  const low = c.conf === 'low';
  return (
    <div style={{ background: low && !c.checked ? '#FBFAF7' : '#fff', borderRadius: 16, padding: '12px 13px',
      boxShadow: '0 1px 2px rgba(40,39,35,0.04)', opacity: low && !c.checked ? 0.82 : 1, transition: 'opacity .15s' }}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
        <Check on={c.checked} onClick={() => onChange({ checked: !c.checked })} />
        <CatTile item={{ cat: c.cat, emoji: c.emoji }} size={44} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'space-between' }}>
            <input value={c.name} onChange={(e) => onChange({ name: e.target.value })} style={{
              flex: 1, minWidth: 0, border: 'none', outline: 'none', background: 'transparent', padding: '2px 0',
              fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink, borderBottom: '1.5px solid transparent' }}
              onFocus={(e) => e.target.style.borderBottomColor = T.line}
              onBlur={(e) => e.target.style.borderBottomColor = 'transparent'} />
            <ConfTag conf={c.conf} />
          </div>
          {/* controls */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 9, flexWrap: 'wrap' }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', background: '#F4F1EB', borderRadius: 10 }}>
              <button onClick={() => onChange({ qty: Math.max(1, c.qty - 1) })} style={qStep}><Icon name="minus" size={15} color={T.ink} /></button>
              <span style={{ minWidth: 22, textAlign: 'center', fontSize: 14.5, fontWeight: 800, color: T.ink }}>{c.qty}</span>
              <button onClick={() => onChange({ qty: c.qty + 1 })} style={qStep}><Icon name="plus" size={15} color={T.ink} /></button>
            </div>
            <input value={c.unit} onChange={(e) => onChange({ unit: e.target.value })} style={{
              width: 46, textAlign: 'center', border: `1.5px solid ${T.line}`, borderRadius: 10, outline: 'none',
              background: '#fff', padding: '6px 4px', fontFamily: T.font, fontSize: 13.5, fontWeight: 700, color: T.ink }} />
            <button onClick={() => setCatOpen(catOpen ? null : c.id)} style={{ display: 'inline-flex', alignItems: 'center', gap: 5,
              padding: '6px 11px', borderRadius: 10, border: 'none', cursor: 'pointer', background: CATS[c.cat].tile,
              fontFamily: T.font, fontSize: 13.5, fontWeight: 700, color: T.ink }}>
              {c.cat} <Icon name="chevron" size={13} color={T.sub} stroke={2.4} />
            </button>
          </div>
          {catOpen && (
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7, marginTop: 9 }}>
              {CAT_ORDER.map((cat) => {
                const on = c.cat === cat;
                return <button key={cat} onClick={() => { onChange({ cat }); setCatOpen(null); }} style={{
                  padding: '6px 12px', borderRadius: 999, border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 13, fontWeight: 700,
                  background: on ? T.ink : CATS[cat].tile, color: on ? '#fff' : T.ink }}>{cat}</button>;
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
const qStep = { width: 32, height: 32, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' };

function ReviewScreen({ candidates, setCandidates, onConfirm, onBack }) {
  const [catOpen, setCatOpen] = React.useState(null);
  const chosen = candidates.filter((c) => c.checked).length;
  const update = (id, patch) => setCandidates((p) => p.map((c) => c.id === id ? { ...c, ...patch } : c));
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      {/* header */}
      <div style={{ padding: `${T.statusPad}px 16px 10px`, flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={onBack} style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer',
            border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span>
          </button>
          <div>
            <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>認識された食材</div>
            <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 2 }}>{candidates.length}件の候補 ・ <b style={{ color: T.green }}>{chosen}件</b>を採用</div>
          </div>
        </div>
        <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 12, background: '#fff', borderRadius: 12, padding: '10px 13px', display: 'flex', gap: 8, alignItems: 'center' }}>
          <Icon name="sliders" size={17} color={T.green} />
          採用するものを選び、名前・数量・カテゴリを必要に応じて修正してください
        </div>
      </div>
      {/* list */}
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 16px 8px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {candidates.map((c) => (
          <CandidateCard key={c.id} c={c} onChange={(patch) => update(c.id, patch)}
            catOpen={catOpen === c.id} setCatOpen={setCatOpen} />
        ))}
        <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, padding: '4px 0' }}>
          ＝ AIが自動で読み取った候補です。登録前に確認できます
        </div>
      </div>
      {/* confirm */}
      <div style={{ flexShrink: 0, padding: '14px 16px 26px', background: `linear-gradient(to top, ${T.bg} 70%, transparent)` }}>
        <button onClick={onConfirm} disabled={chosen === 0} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none',
          cursor: chosen ? 'pointer' : 'default', background: chosen ? T.green : '#D8D4CB',
          boxShadow: chosen ? '0 12px 26px rgba(31,122,85,0.3)' : 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          <Icon name="check" size={22} color="#fff" /> 確定して在庫に追加（{chosen}件）
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 4. Error (poor signal)
// ─────────────────────────────────────────────────────────────
function ErrorScreen({ onRetry, onLater }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 30, textAlign: 'center' }}>
        <div style={{ width: 96, height: 96, borderRadius: 30, background: T.nearSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}>
          <Icon name="wifi" size={44} color={T.near} />
        </div>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>解析できませんでした</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.75, maxWidth: 268 }}>
          電波が弱いようです。電波の良い場所か<br />Wi-Fi に接続して、もう一度お試しください。
        </div>
        <div style={{ marginTop: 6, fontSize: 12.5, fontWeight: 600, color: T.faint, background: '#fff', borderRadius: 10, padding: '8px 13px' }}>
          撮影した写真はそのまま保存されています
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, padding: '0 16px 32px' }}>
        <button onClick={onRetry} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer',
          background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9,
          fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="refresh" size={21} color="#fff" /> もう一度試す
        </button>
        <button onClick={onLater} style={{ width: '100%', height: 54, borderRadius: 16, cursor: 'pointer',
          background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>
          あとで解析する
        </button>
      </div>
    </div>
  );
}

window.CameraScreens = { CaptureScreen, AnalyzingScreen, ReviewScreen, ErrorScreen };
