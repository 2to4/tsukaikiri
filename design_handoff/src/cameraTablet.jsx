// cameraTablet.jsx — カメラ登録 タブレット横向き（撮影/解析/候補確認 二ペイン/エラー）
const { T, CATS, CAT_ORDER, Icon, CatTile } = window;
const CW = 1194, CH = 834;

function PhotoFill({ seed = 0, style = {} }) {
  const hues = ['#D9D3C6', '#CBD6C9', '#E0D2C4', '#CFD3DB', '#DDD6CC', '#D6CFC4'];
  const a = hues[seed % hues.length];
  return <div style={{ background: `repeating-linear-gradient(135deg, ${a} 0 8px, ${a}99 8px 16px)`, ...style }} />;
}
function ConfTag({ conf, big }) {
  const map = { high: ['確信度 高', T.green, T.greenSoft], mid: ['確信度 中', T.plenty, T.plentySoft], low: ['要確認', T.near, T.nearSoft] };
  const [label, color, soft] = map[conf];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: big ? '5px 12px' : '3px 9px', borderRadius: 999, background: soft, flexShrink: 0 }}>
      <span style={{ width: big ? 7 : 6, height: big ? 7 : 6, borderRadius: 99, background: color }} />
      <span style={{ fontSize: big ? 13 : 11, fontWeight: 700, color }}>{label}</span>
    </span>
  );
}

// ════════════════════════════════════════════════════════════
// Capture — left viewfinder / right control panel
// ════════════════════════════════════════════════════════════
function TabletCapture({ photos, onShutter, onLibrary, onRemove, onAnalyze, onClose }) {
  const MAX = 10, full = photos.length >= MAX;
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      {/* viewfinder */}
      <div style={{ flex: 1, background: 'radial-gradient(120% 80% at 50% 30%, #2A2823 0%, #131210 100%)', position: 'relative' }}>
        <button onClick={onClose} style={{ position: 'absolute', top: 22, left: 22, ...camIconBtn, zIndex: 3 }}><Icon name="close" size={22} color="#fff" /></button>
        <div style={{ position: 'absolute', top: 26, left: '50%', transform: 'translateX(-50%)', background: 'rgba(0,0,0,0.5)', color: '#fff', padding: '6px 15px', borderRadius: 999, fontSize: 13.5, fontWeight: 700 }}>{photos.length} / {MAX} 枚</div>
        {[['t', 'l', { top: 70, left: 70 }], ['t', 'r', { top: 70, right: 70 }], ['b', 'l', { bottom: 130, left: 70 }], ['b', 'r', { bottom: 130, right: 70 }]].map(([v, h, pos], i) => (
          <div key={i} style={{ position: 'absolute', width: 40, height: 40,
            borderTop: v === 't' ? '3px solid rgba(255,255,255,0.55)' : 'none', borderBottom: v === 'b' ? '3px solid rgba(255,255,255,0.55)' : 'none',
            borderLeft: h === 'l' ? '3px solid rgba(255,255,255,0.55)' : 'none', borderRight: h === 'r' ? '3px solid rgba(255,255,255,0.55)' : 'none',
            borderRadius: 10, ...pos }} />
        ))}
        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 14, paddingBottom: 60 }}>
          <div style={{ width: 64, height: 64, borderRadius: 20, background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="camera" size={32} color="rgba(255,255,255,0.85)" /></div>
          <div style={{ color: 'rgba(255,255,255,0.92)', fontSize: 17, fontWeight: 700 }}>冷蔵庫の中が見えるように撮影</div>
          <div style={{ color: 'rgba(255,255,255,0.45)', fontSize: 12.5, fontFamily: 'ui-monospace, monospace', letterSpacing: 0.5 }}>カメラプレビュー</div>
        </div>
        {/* shutter + library */}
        <div style={{ position: 'absolute', bottom: 36, left: 0, right: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 0 }}>
          <button onClick={onLibrary} disabled={full} style={{ position: 'absolute', left: 44, ...camIconBtn, opacity: full ? 0.4 : 1 }}><Icon name="image" size={26} color="#fff" /></button>
          <button onClick={onShutter} disabled={full} style={{ width: 80, height: 80, borderRadius: 99, cursor: full ? 'default' : 'pointer', background: 'transparent', border: '4px solid rgba(255,255,255,0.92)', padding: 5, opacity: full ? 0.4 : 1 }}>
            <div style={{ width: '100%', height: '100%', borderRadius: 99, background: '#fff' }} />
          </button>
        </div>
      </div>
      {/* control panel */}
      <div style={{ width: 380, flexShrink: 0, background: '#FBFAF7', borderLeft: `1px solid ${T.line}`, display: 'flex', flexDirection: 'column', fontFamily: T.font }}>
        <div style={{ padding: '34px 28px 8px' }}>
          <div style={{ fontFamily: T.brand, fontSize: 25, fontWeight: 700, color: T.ink }}>冷蔵庫を撮影</div>
          <div style={{ fontSize: 14, fontWeight: 500, color: T.sub, lineHeight: 1.7, marginTop: 8 }}>
            棚ごと・引き出しごとに分けて撮ると認識精度が上がります。最大10枚まで。
          </div>
        </div>
        <div style={{ flex: 1, overflow: 'auto', padding: '16px 24px 8px' }}>
          {photos.length === 0 ? (
            <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10, color: T.faint, textAlign: 'center', paddingBottom: 40 }}>
              <Icon name="image" size={36} color={T.faint} />
              <div style={{ fontSize: 13.5, fontWeight: 600 }}>撮影した写真がここに並びます</div>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              {photos.map((p, i) => (
                <div key={p} style={{ position: 'relative', aspectRatio: '1', }}>
                  <PhotoFill seed={i} style={{ width: '100%', height: '100%', borderRadius: 14 }} />
                  <button onClick={() => onRemove(p)} style={{ position: 'absolute', top: -7, right: -7, width: 24, height: 24, borderRadius: 99, background: 'rgba(0,0,0,0.72)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="close" size={14} color="#fff" stroke={2.4} /></button>
                </div>
              ))}
            </div>
          )}
        </div>
        <div style={{ padding: '14px 24px 26px', borderTop: `1px solid ${T.line}` }}>
          <button onClick={onAnalyze} disabled={photos.length === 0} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: photos.length ? 'pointer' : 'default',
            background: photos.length ? T.green : '#D8D4CB', boxShadow: photos.length ? '0 12px 26px rgba(31,122,85,0.28)' : 'none',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
            <Icon name="spark" size={22} color="#fff" /> 解析する{photos.length ? `（${photos.length}枚）` : ''}
          </button>
        </div>
      </div>
    </div>
  );
}
const camIconBtn = { width: 46, height: 46, borderRadius: 15, background: 'rgba(255,255,255,0.16)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' };

// ════════════════════════════════════════════════════════════
// Analyzing
// ════════════════════════════════════════════════════════════
function TabletAnalyzing({ photos, onCancel }) {
  const steps = ['写真を読み取り中', '食材を検出中', '候補を作成中'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, fontFamily: T.font, background: T.bg, padding: 40, textAlign: 'center', position: 'relative' }}>
      <div style={{ display: 'flex', gap: 10, marginBottom: 18 }}>
        {photos.slice(0, 8).map((p, i) => <PhotoFill key={p} seed={i} style={{ width: 48, height: 48, borderRadius: 12 }} />)}
      </div>
      <div className="cam-pulse" style={{ width: 104, height: 104, borderRadius: 32, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 6 }}><Icon name="spark" size={48} color={T.green} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 26, fontWeight: 700, color: T.ink }}>AIが食材を解析中</div>
      <div style={{ fontSize: 15, fontWeight: 600, color: T.sub }}>写真 {photos.length} 枚から食材を探しています</div>
      <div style={{ width: 260, height: 7, borderRadius: 99, background: '#E6E2D9', overflow: 'hidden', marginTop: 16 }}><div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} /></div>
      <div style={{ display: 'flex', gap: 26, marginTop: 22 }}>
        {steps.map((s, i) => (
          <div key={s} className="cam-step" style={{ animationDelay: `${i * 0.7}s`, display: 'flex', alignItems: 'center', gap: 8, fontSize: 13.5, fontWeight: 600, color: T.sub }}>
            <span style={{ width: 18, height: 18, borderRadius: 99, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="check" size={12} color={T.green} stroke={3} /></span>{s}
          </div>
        ))}
      </div>
      <button onClick={onCancel} style={{ position: 'absolute', bottom: 34, background: 'none', border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.sub }}>キャンセル</button>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// Review — two pane (left list / right large editor) ★
// ════════════════════════════════════════════════════════════
function Check({ on, onClick, size = 26 }) {
  return (
    <button onClick={onClick} style={{ width: size, height: size, borderRadius: 8, cursor: 'pointer', flexShrink: 0,
      border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {on && <Icon name="check" size={size * 0.62} color="#fff" stroke={3} />}
    </button>
  );
}
function ReviewRow({ c, selected, onSelect, onToggle }) {
  const low = c.conf === 'low';
  return (
    <div onClick={onSelect} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 13px', borderRadius: 14, cursor: 'pointer',
      background: selected ? T.greenSoft : (low && !c.checked ? '#FBFAF7' : '#fff'),
      boxShadow: selected ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)',
      opacity: low && !c.checked ? 0.8 : 1 }}>
      <div onClick={(e) => { e.stopPropagation(); onToggle(); }}><Check on={c.checked} onClick={() => {}} size={24} /></div>
      <CatTile item={{ cat: c.cat, emoji: c.emoji }} size={42} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15.5, fontWeight: 700, color: T.ink, lineHeight: 1.2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{c.name}</div>
        <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 2 }}>{c.qty}{c.unit} ・ {c.cat}</div>
      </div>
      <ConfTag conf={c.conf} />
    </div>
  );
}
const stepBtnT = { width: 40, height: 40, borderRadius: 12, background: '#F4F1EB', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' };
function EditField({ label, children, alignTop }) {
  return (
    <div style={{ padding: '18px 0', borderBottom: `1px solid ${T.line}`, display: 'flex', alignItems: alignTop ? 'flex-start' : 'center', justifyContent: 'space-between', gap: 16 }}>
      <span style={{ fontSize: 15, fontWeight: 700, color: T.sub, paddingTop: alignTop ? 6 : 0 }}>{label}</span>
      <div>{children}</div>
    </div>
  );
}
function ReviewEditor({ c, onChange, seedIndex }) {
  if (!c) {
    return (
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, color: T.faint, textAlign: 'center', padding: 40 }}>
        <div style={{ width: 90, height: 90, borderRadius: 28, background: '#fff', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="sliders" size={38} color={T.faint} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 18, fontWeight: 700, color: T.sub }}>候補を選んで確認</div>
        <div style={{ fontSize: 13.5, fontWeight: 500, lineHeight: 1.7, maxWidth: 260 }}>左の候補をタップすると、ここで名前・数量・カテゴリを修正できます。</div>
      </div>
    );
  }
  return (
    <div style={{ height: '100%', overflow: 'auto', padding: '36px 44px 36px', fontFamily: T.font }}>
      {/* hero */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 22 }}>
        <div style={{ width: 110, height: 110, borderRadius: 32, background: CATS[c.cat].tile, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 58, flexShrink: 0 }}>{c.emoji}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <ConfTag conf={c.conf} big />
          <input value={c.name} onChange={(e) => onChange({ name: e.target.value })} style={{ display: 'block', width: '100%', marginTop: 10, border: 'none', borderBottom: `2px solid ${T.line}`, outline: 'none', background: 'transparent', padding: '4px 0', fontFamily: T.brand, fontSize: 30, fontWeight: 700, color: T.ink }} />
          <div style={{ fontSize: 12.5, fontWeight: 600, color: T.faint, marginTop: 6 }}>名前をタップして修正できます</div>
        </div>
      </div>
      {/* source photos */}
      <div style={{ marginTop: 22 }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: T.sub, marginBottom: 8 }}>認識元の写真</div>
        <div style={{ display: 'flex', gap: 10 }}>
          {[0, 1].map((i) => (
            <div key={i} style={{ position: 'relative', width: 84, height: 84 }}>
              <PhotoFill seed={seedIndex + i} style={{ width: '100%', height: '100%', borderRadius: 14 }} />
              <div style={{ position: 'absolute', inset: 0, borderRadius: 14, boxShadow: 'inset 0 0 0 2px rgba(31,122,85,0.5)' }} />
            </div>
          ))}
        </div>
      </div>
      {/* fields */}
      <div style={{ marginTop: 18 }}>
        <EditField label="数量">
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <button onClick={() => onChange({ qty: Math.max(1, c.qty - 1) })} style={stepBtnT}><Icon name="minus" size={19} color={T.ink} /></button>
            <span style={{ fontSize: 19, fontWeight: 800, minWidth: 28, textAlign: 'center' }}>{c.qty}</span>
            <button onClick={() => onChange({ qty: c.qty + 1 })} style={stepBtnT}><Icon name="plus" size={19} color={T.ink} /></button>
            <input value={c.unit} onChange={(e) => onChange({ unit: e.target.value })} style={{ width: 64, marginLeft: 4, textAlign: 'center', border: `1.5px solid ${T.line}`, borderRadius: 12, outline: 'none', background: '#fff', padding: '9px 6px', fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.ink }} />
          </div>
        </EditField>
        <EditField label="カテゴリ" alignTop>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'flex-end', maxWidth: 360 }}>
            {CAT_ORDER.map((cat) => {
              const on = c.cat === cat;
              return <button key={cat} onClick={() => onChange({ cat })} style={{ border: 'none', cursor: 'pointer', padding: '9px 15px', borderRadius: 999, fontFamily: T.font, fontSize: 14, fontWeight: 700, background: on ? T.ink : CATS[cat].tile, color: on ? '#fff' : T.ink }}>{cat}</button>;
            })}
          </div>
        </EditField>
        <EditField label="在庫に追加">
          <div style={{ display: 'inline-flex', background: '#F4F1EB', borderRadius: 12, padding: 4, gap: 3 }}>
            {[[true, '採用'], [false, '除外']].map(([v, l]) => (
              <button key={l} onClick={() => onChange({ checked: v })} style={{ border: 'none', cursor: 'pointer', padding: '8px 20px', borderRadius: 9, fontFamily: T.font, fontSize: 14.5, fontWeight: 700,
                background: c.checked === v ? (v ? T.green : '#fff') : 'transparent', color: c.checked === v ? (v ? '#fff' : T.over) : T.sub }}>{l}</button>
            ))}
          </div>
        </EditField>
      </div>
    </div>
  );
}
function TabletReview({ candidates, setCandidates, selId, setSel, onConfirm, onClose }) {
  const chosen = candidates.filter((c) => c.checked).length;
  const allOn = chosen === candidates.length;
  const update = (id, patch) => setCandidates((p) => p.map((c) => c.id === id ? { ...c, ...patch } : c));
  const sel = candidates.find((c) => c.id === selId) || null;
  const selIdx = candidates.findIndex((c) => c.id === selId);
  return (
    <div style={{ height: '100%', display: 'flex', fontFamily: T.font }}>
      {/* left list */}
      <div style={{ width: 452, flexShrink: 0, borderRight: `1px solid ${T.line}`, background: '#FBFAF7', display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '28px 22px 12px' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 10 }}>
            <div>
              <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>認識された食材</div>
              <div style={{ fontSize: 13, fontWeight: 600, color: T.sub, marginTop: 3 }}>{candidates.length}件の候補 ・ <b style={{ color: T.green }}>{chosen}件</b>を採用</div>
            </div>
            <button onClick={() => setCandidates((p) => p.map((c) => ({ ...c, checked: !allOn })))} style={{ border: `1.5px solid ${T.line}`, background: '#fff', cursor: 'pointer', padding: '8px 12px', borderRadius: 10, fontFamily: T.font, fontSize: 13, fontWeight: 700, color: T.ink, whiteSpace: 'nowrap' }}>{allOn ? 'すべて解除' : 'すべて採用'}</button>
          </div>
        </div>
        <div style={{ flex: 1, overflow: 'auto', padding: '4px 16px 12px', display: 'flex', flexDirection: 'column', gap: 9 }}>
          {candidates.map((c) => <ReviewRow key={c.id} c={c} selected={selId === c.id} onSelect={() => setSel(c.id)} onToggle={() => update(c.id, { checked: !c.checked })} />)}
        </div>
        <div style={{ padding: '14px 18px 20px', borderTop: `1px solid ${T.line}`, background: '#FBFAF7' }}>
          <button onClick={onConfirm} disabled={chosen === 0} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: chosen ? 'pointer' : 'default',
            background: chosen ? T.green : '#D8D4CB', boxShadow: chosen ? '0 12px 26px rgba(31,122,85,0.3)' : 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
            fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
            <Icon name="check" size={22} color="#fff" /> 確定して在庫に追加（{chosen}件）
          </button>
        </div>
      </div>
      {/* right editor */}
      <div style={{ flex: 1, background: T.bg, position: 'relative' }}>
        <button onClick={onClose} title="閉じる" style={{ position: 'absolute', top: 24, right: 24, zIndex: 3, width: 44, height: 44, borderRadius: 14, background: '#fff', border: `1.5px solid ${T.line}`, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="close" size={20} color={T.sub} /></button>
        <ReviewEditor c={sel} onChange={(patch) => update(selId, patch)} seedIndex={selIdx} />
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// Error
// ════════════════════════════════════════════════════════════
function TabletError({ onRetry, onLater }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, fontFamily: T.font, background: T.bg, padding: 40, textAlign: 'center' }}>
      <div style={{ width: 104, height: 104, borderRadius: 32, background: T.nearSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="wifi" size={48} color={T.near} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 25, fontWeight: 700, color: T.ink }}>解析できませんでした</div>
      <div style={{ fontSize: 15.5, fontWeight: 500, color: T.sub, lineHeight: 1.75, maxWidth: 360 }}>電波が弱いようです。電波の良い場所か Wi-Fi に接続して、もう一度お試しください。</div>
      <div style={{ marginTop: 8, fontSize: 13, fontWeight: 600, color: T.faint, background: '#fff', borderRadius: 12, padding: '9px 15px' }}>撮影した写真はそのまま保存されています</div>
      <div style={{ display: 'flex', gap: 12, marginTop: 26 }}>
        <button onClick={onLater} style={{ height: 58, borderRadius: 18, padding: '0 26px', cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>あとで解析する</button>
        <button onClick={onRetry} style={{ height: 58, borderRadius: 18, padding: '0 30px', cursor: 'pointer', border: 'none', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', gap: 9, fontFamily: T.font, fontSize: 16, fontWeight: 800, color: '#fff' }}><Icon name="refresh" size={21} color="#fff" /> もう一度試す</button>
      </div>
    </div>
  );
}

window.CameraTablet = { TabletCapture, TabletAnalyzing, TabletReview, TabletError, CW, CH };
