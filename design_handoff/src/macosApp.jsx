// macosApp.jsx — つかいきり macOS screens (all 6) + root App
const { T, Icon, CatTile, CATS, CAT_ORDER, ITEMS, expiryOf } = window;
const { MEALS, MEALS_LOW } = window.Meals;
const { SHOP_SEED } = window.ShoppingPhone;
const { HelpAbout } = window.HelpAbout;
const { StepRail, MacWelcome, MacAIStep, MacLinkStep, MacListStep, MacApplianceStep, MacFinish } = window.MacOnboarding;
const { useHover, TBtn, MacBar, VDiv, MacSearch, MacAppWindow, useFitMac, MFONT } = window.MacShell;

const ALL_MEALS = [...MEALS, ...MEALS_LOW];
const clone = a => a.map(x => ({ ...x }));
const CAT_EMOJI = { '肉': '🥩', '魚': '🐟', '野菜': '🥬', '乳製品': '🧀', '調味料': '🧂', '常備品': '🥫' };

// ── Shared atoms ──────────────────────────────────────────────────
function ActionBtn({ icon, onClick, danger }) {
  const [h, hP] = useHover();
  return (
    <button onClick={onClick} {...hP} style={{ width: 24, height: 24, borderRadius: 6, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', background: h ? (danger ? T.overSoft : T.greenSoft) : 'transparent', transition: 'background 0.08s' }}>
      <Icon name={icon} size={12} color={h ? (danger ? T.over : T.green) : T.sub} stroke={2.2} />
    </button>
  );
}

function FilterRow({ label, on, onClick, emoji }) {
  const [h, hP] = useHover();
  return (
    <button onClick={onClick} {...hP} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 7, padding: '5px 8px', borderRadius: 6, fontFamily: T.font, fontSize: 12, fontWeight: on ? 700 : 600, textAlign: 'left', background: on ? T.greenSoft : h ? 'rgba(40,39,35,0.05)' : 'transparent', color: on ? T.greenInk : T.ink, transition: 'background 0.08s', marginBottom: 1 }}>
      {emoji ? <span style={{ fontSize: 13 }}>{emoji}</span> : <span style={{ width: 13 }} />}
      <span style={{ flex: 1 }}>{label}</span>
      {on && <Icon name="check" size={11} color={T.green} stroke={3} />}
    </button>
  );
}

function GroupHead({ label, color, count }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 7, padding: '9px 14px 5px', position: 'sticky', top: 0, background: 'rgba(247,245,240,0.96)', backdropFilter: 'blur(10px)', zIndex: 1 }}>
      <div style={{ width: 6, height: 6, borderRadius: 99, background: color, flexShrink: 0 }} />
      <span style={{ fontSize: 10.5, fontWeight: 800, color, fontFamily: T.font }}>{label}</span>
      <span style={{ fontSize: 10, fontWeight: 600, color: T.faint }}>{count}品</span>
    </div>
  );
}

function ExpiryChip({ days }) {
  const status = expiryOf(days);
  const color = status === 'over' ? T.over : status === 'near' ? T.near : T.faint;
  const bg = status === 'over' ? T.overSoft : status === 'near' ? T.nearSoft : T.plentySoft;
  const text = days < 0 ? `${Math.abs(days)}日超過` : days === 0 ? '今日まで' : `あと${days}日`;
  return <span style={{ padding: '3px 7px', borderRadius: 999, background: bg, color, fontSize: 10.5, fontWeight: 800, whiteSpace: 'nowrap' }}>{text}</span>;
}

// ── Screen 1: 在庫 ────────────────────────────────────────────────
function ItemRow({ item, selected, onClick }) {
  const [h, hP] = useHover();
  return (
    <div onClick={onClick} {...hP} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '7px 14px', background: selected ? '#EDF5F1' : h ? 'rgba(40,39,35,0.035)' : 'transparent', cursor: 'pointer', transition: 'background 0.07s' }}>
      <CatTile item={item} size={34} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: selected ? T.greenInk : T.ink, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{item.name}</div>
        <div style={{ fontSize: 10.5, fontWeight: 600, color: T.sub, marginTop: 1 }}>{item.cat}</div>
      </div>
      <div style={{ fontSize: 12, fontWeight: 700, color: T.sub, whiteSpace: 'nowrap', marginRight: 4 }}>{item.qty}{item.unit}</div>
      <ExpiryChip days={item.days} />
      {(h || selected) && (
        <div style={{ display: 'flex', gap: 2, marginLeft: 4 }}>
          <ActionBtn icon="edit" onClick={e => e.stopPropagation()} />
          <ActionBtn icon="trash" onClick={e => e.stopPropagation()} danger />
        </div>
      )}
    </div>
  );
}

function ItemDetail({ item }) {
  if (!item) return (
    <div style={{ width: 300, flexShrink: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10, borderLeft: `1px solid ${T.line}`, padding: 30, textAlign: 'center' }}>
      <div style={{ fontSize: 36, opacity: 0.3 }}>🥗</div>
      <div style={{ fontSize: 13, fontWeight: 700, color: T.faint }}>食材を選択してください</div>
      <div style={{ fontSize: 11.5, color: T.faint, lineHeight: 1.6 }}>一覧から食材をクリックすると<br />詳細・編集できます</div>
    </div>
  );
  const status = expiryOf(item.days);
  const tileColor = CATS[item.cat]?.tile || '#EAE7DF';
  return (
    <div style={{ width: 300, flexShrink: 0, borderLeft: `1px solid ${T.line}`, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ padding: '20px 20px 14px', background: tileColor + '66', borderBottom: `1px solid ${T.line}`, display: 'flex', alignItems: 'center', gap: 14 }}>
        <div style={{ width: 60, height: 60, borderRadius: 18, background: tileColor, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 30 }}>{item.emoji}</div>
        <div>
          <div style={{ fontSize: 18, fontWeight: 800, color: T.ink, lineHeight: 1.2 }}>{item.name}</div>
          <div style={{ fontSize: 12, fontWeight: 700, color: T.sub, marginTop: 3 }}>{item.cat}</div>
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '14px 18px' }}>
        {[['数量', `${item.qty} ${item.unit}`], ['カテゴリ', item.cat], ['賞味期限まで', item.days < 0 ? `${Math.abs(item.days)}日超過` : item.days === 0 ? '今日まで' : `あと${item.days}日`]].map(([k, v]) => (
          <div key={k} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '9px 0', borderBottom: `1px solid ${T.line}` }}>
            <span style={{ fontSize: 12, fontWeight: 700, color: T.sub }}>{k}</span>
            <span style={{ fontSize: 13, fontWeight: 700, color: T.ink }}>{v}</span>
          </div>
        ))}
        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <TBtn icon="spark" label="この食材で献立を提案" primary onClick={() => {}} />
          <TBtn icon="check" label="使い切りにする" onClick={() => {}} />
          <TBtn icon="trash" label="削除" onClick={() => {}} />
        </div>
        <div style={{ marginTop: 16, padding: '11px 13px', background: T.greenSoft, borderRadius: 10, fontSize: 11.5, fontWeight: 600, color: T.greenInk, lineHeight: 1.65 }}>
          ダブルクリックで名前・数量を直接編集できます
        </div>
      </div>
    </div>
  );
}

function InventoryScreen({ search, setSearch }) {
  const [catF, setCatF] = React.useState('すべて');
  const [selId, setSel] = React.useState(ITEMS[1]?.id || null);
  let filtered = ITEMS;
  if (catF !== 'すべて') filtered = filtered.filter(i => i.cat === catF);
  if (search) filtered = filtered.filter(i => i.name.includes(search));
  const near = filtered.filter(i => i.days <= 3);
  const week = filtered.filter(i => i.days > 3 && i.days <= 7);
  const plenty = filtered.filter(i => i.days > 7);
  const selItem = ITEMS.find(i => i.id === selId);
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      <div style={{ width: 168, flexShrink: 0, padding: '10px 6px', borderRight: `1px solid ${T.line}`, overflow: 'auto', background: '#FAFAF7' }}>
        <div style={{ fontSize: 9.5, fontWeight: 800, color: T.faint, fontFamily: T.font, padding: '3px 8px 4px', letterSpacing: '0.08em' }}>カテゴリ</div>
        <FilterRow label="すべて" on={catF === 'すべて'} onClick={() => setCatF('すべて')} />
        {CAT_ORDER.map(c => <FilterRow key={c} label={c} on={catF === c} onClick={() => setCatF(c)} emoji={CAT_EMOJI[c]} />)}
      </div>
      <div style={{ flex: 1, overflow: 'auto', borderRight: `1px solid ${T.line}` }}>
        {near.length > 0 && <><GroupHead label="今日・もうすぐ" color={T.near} count={near.length} />{near.map(i => <ItemRow key={i.id} item={i} selected={selId === i.id} onClick={() => setSel(i.id)} />)}</>}
        {week.length > 0 && <><GroupHead label="今週のうちに" color={T.ink} count={week.length} />{week.map(i => <ItemRow key={i.id} item={i} selected={selId === i.id} onClick={() => setSel(i.id)} />)}</>}
        {plenty.length > 0 && <><GroupHead label="まだ余裕" color={T.sub} count={plenty.length} />{plenty.map(i => <ItemRow key={i.id} item={i} selected={selId === i.id} onClick={() => setSel(i.id)} />)}</>}
        {filtered.length === 0 && <div style={{ padding: '50px 20px', textAlign: 'center', color: T.faint, fontSize: 13, fontFamily: T.font }}><div style={{ fontSize: 28, marginBottom: 12 }}>🔍</div>該当する食材がありません</div>}
      </div>
      <ItemDetail item={selItem} />
    </div>
  );
}

// ── Screen 2: カメラ登録 ──────────────────────────────────────────
const CANDS = [
  { id: 1, name: '牛乳', emoji: '🥛', qty: 1, unit: '本', cat: '乳製品', conf: 'high', checked: true },
  { id: 2, name: '卵', emoji: '🥚', qty: 6, unit: '個', cat: '常備品', conf: 'high', checked: true },
  { id: 3, name: 'ほうれん草', emoji: '🥬', qty: 1, unit: '袋', cat: '野菜', conf: 'high', checked: true },
  { id: 4, name: 'ミニトマト', emoji: '🍅', qty: 4, unit: '個', cat: '野菜', conf: 'mid', checked: true },
  { id: 5, name: '鶏もも肉', emoji: '🍗', qty: 1, unit: 'パック', cat: '肉', conf: 'high', checked: true },
  { id: 6, name: 'バター', emoji: '🧈', qty: 1, unit: '箱', cat: '乳製品', conf: 'mid', checked: true },
  { id: 7, name: '葉物野菜？', emoji: '🥬', qty: 1, unit: '袋', cat: '野菜', conf: 'low', checked: false },
];
const CONF_LABEL = { high: '確信度 高', mid: '確信度 中', low: '確信度 低' };
const CONF_COLOR = { high: T.greenInk, mid: T.near, low: T.faint };
const CONF_BG = { high: T.greenSoft, mid: T.nearSoft, low: T.plentySoft };

function CameraScreen({ camState, setCamState }) {
  const [cands, setCands] = React.useState(clone(CANDS));
  const [selC, setSelC] = React.useState(1);
  const [drag, setDrag] = React.useState(false);
  const [photos, setPhotos] = React.useState([]);
  const timer = React.useRef(null);
  const sel = cands.find(c => c.id === selC);
  const startAnalyze = () => { setCamState('analyzing'); clearTimeout(timer.current); timer.current = setTimeout(() => { setCands(clone(CANDS)); setSelC(1); setCamState('review'); }, 2400); };
  React.useEffect(() => { if (camState === 'capture') { setPhotos([]); setCands(clone(CANDS)); } }, [camState]);
  if (camState === 'capture') return (
    <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 40 }}>
      <div onDragOver={e => { e.preventDefault(); setDrag(true); }} onDragLeave={() => setDrag(false)} onDrop={e => { e.preventDefault(); setDrag(false); setPhotos(p => [...p, ...Array.from(e.dataTransfer.files).slice(0, 10 - p.length).map((_, i) => i + Date.now())]); }}
        style={{ width: '100%', maxWidth: 640, height: 380, borderRadius: 20, border: `2px dashed ${drag ? T.green : T.line}`, background: drag ? T.greenSoft : '#FAFAF7', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, transition: 'all 0.15s', cursor: 'pointer' }}
        onClick={() => setPhotos(p => p.length < 10 ? [...p, Date.now()] : p)}>
        <div style={{ width: 72, height: 72, borderRadius: 20, background: drag ? T.green : T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'all 0.15s' }}><Icon name="camera" size={32} color={drag ? '#fff' : T.green} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 20, fontWeight: 700, color: T.ink }}>写真をドロップ、または クリックして選択</div>
        <div style={{ fontSize: 13, color: T.sub, fontWeight: 600 }}>冷蔵庫の写真を最大10枚追加できます</div>
        {photos.length > 0 && <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>{photos.map((p, i) => <div key={p} style={{ width: 52, height: 52, borderRadius: 10, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>📷</div>)}</div>}
        {photos.length > 0 && <TBtn icon="spark" label={`${photos.length}枚を解析する ⌘R`} primary onClick={e => { e.stopPropagation(); startAnalyze(); }} />}
      </div>
    </div>
  );
  if (camState === 'analyzing') return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12 }}>
      <div className="cam-pulse" style={{ width: 80, height: 80, borderRadius: 24, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="spark" size={38} color={T.green} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 20, fontWeight: 700, color: T.ink }}>AIが写真を解析中…</div>
      <div style={{ fontSize: 13, color: T.sub }}>食材を認識しています。しばらくお待ちください</div>
      <div style={{ width: 240, height: 6, borderRadius: 99, background: T.line, overflow: 'hidden', marginTop: 8 }}><div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} /></div>
    </div>
  );
  // review state
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      <div style={{ flex: 1, overflow: 'auto', borderRight: `1px solid ${T.line}` }}>
        <div style={{ padding: '12px 16px 6px', fontSize: 10.5, fontWeight: 800, color: T.faint, letterSpacing: '0.07em' }}>認識された食材（{cands.length}件）</div>
        {cands.map(c => {
          const [h, hP] = [false, {}]; // simplified
          const on = selC === c.id;
          return (
            <div key={c.id} onClick={() => setSelC(c.id)} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '9px 16px', background: on ? '#EDF5F1' : 'transparent', cursor: 'pointer', opacity: c.conf === 'low' ? 0.6 : 1 }}>
              <input type="checkbox" checked={c.checked} onChange={() => setCands(p => p.map(x => x.id === c.id ? { ...x, checked: !x.checked } : x))} onClick={e => e.stopPropagation()} style={{ width: 16, height: 16, accentColor: T.green, cursor: 'pointer' }} />
              <span style={{ fontSize: 20 }}>{c.emoji}</span>
              <div style={{ flex: 1 }}><div style={{ fontSize: 13, fontWeight: 700, color: T.ink }}>{c.name}</div><div style={{ fontSize: 11, color: T.sub, fontWeight: 600 }}>{c.cat}</div></div>
              <span style={{ fontSize: 10.5, fontWeight: 700, padding: '2px 7px', borderRadius: 999, background: CONF_BG[c.conf], color: CONF_COLOR[c.conf] }}>{CONF_LABEL[c.conf]}</span>
            </div>
          );
        })}
      </div>
      <div style={{ width: 380, flexShrink: 0, padding: 24, overflow: 'auto' }}>
        {sel && (<>
          <div style={{ textAlign: 'center', marginBottom: 20 }}>
            <div style={{ fontSize: 64, marginBottom: 6 }}>{sel.emoji}</div>
            <div style={{ fontSize: 20, fontWeight: 800, color: T.ink }}>{sel.name}</div>
            <span style={{ fontSize: 11.5, fontWeight: 700, padding: '3px 9px', borderRadius: 999, background: CONF_BG[sel.conf], color: CONF_COLOR[sel.conf], marginTop: 6, display: 'inline-block' }}>{CONF_LABEL[sel.conf]}</span>
          </div>
          {[['名前', sel.name], ['数量', `${sel.qty} ${sel.unit}`], ['カテゴリ', sel.cat]].map(([k, v]) => (
            <div key={k} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '9px 0', borderBottom: `1px solid ${T.line}` }}>
              <span style={{ fontSize: 12, fontWeight: 700, color: T.sub }}>{k}</span>
              <span style={{ fontSize: 13, fontWeight: 700, color: T.ink }}>{v}</span>
            </div>
          ))}
          <div style={{ marginTop: 18 }}><TBtn icon="check" label={`確定して追加（${cands.filter(c => c.checked).length}件）`} primary onClick={() => setCamState('capture')} /></div>
        </>)}
      </div>
    </div>
  );
}

// ── Screen 3: 献立提案 ────────────────────────────────────────────
function MealsScreen({ mealsState, setMealsState }) {
  const [cond, setCond] = React.useState('おまかせ');
  const [selId, setSel] = React.useState(MEALS[0]?.id || null);
  const timer = React.useRef(null);
  const startGen = () => { setMealsState('generating'); clearTimeout(timer.current); timer.current = setTimeout(() => { setMealsState('results'); setSel(MEALS[0]?.id); }, 2400); };
  const meals = mealsState === 'low' ? MEALS_LOW : MEALS;
  const selMeal = ALL_MEALS.find(m => m.id === selId);
  const CONDS = ['おまかせ', '主菜のみ', 'あと1品', '時短'];
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      <div style={{ width: 360, flexShrink: 0, borderRight: `1px solid ${T.line}`, display: 'flex', flexDirection: 'column', background: '#FAFAF7' }}>
        <div style={{ padding: '14px 14px 10px', borderBottom: `1px solid ${T.line}` }}>
          <div style={{ fontSize: 10.5, fontWeight: 800, color: T.faint, marginBottom: 8, letterSpacing: '0.06em' }}>条件</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {CONDS.map(c => <button key={c} onClick={() => setCond(c)} style={{ padding: '5px 12px', borderRadius: 999, border: `1.5px solid ${cond === c ? T.green : T.line}`, background: cond === c ? T.greenSoft : '#fff', color: cond === c ? T.greenInk : T.ink, fontFamily: T.font, fontSize: 12, fontWeight: 700, cursor: 'pointer' }}>{c}</button>)}
          </div>
          {(mealsState === 'before' || mealsState === 'generating') && <div style={{ marginTop: 10 }}><TBtn icon="spark" label="在庫から提案する" kbd="⌘R" primary onClick={startGen} disabled={mealsState === 'generating'} /></div>}
        </div>
        <div style={{ flex: 1, overflow: 'auto' }}>
          {mealsState === 'before' && <div style={{ padding: '50px 20px', textAlign: 'center', color: T.faint, fontSize: 13 }}><div style={{ fontSize: 28, marginBottom: 12 }}>🍳</div>「在庫から提案する」を<br />クリックしてください</div>}
          {mealsState === 'generating' && <div style={{ padding: '50px 20px', textAlign: 'center' }}><div className="cam-pulse" style={{ width: 52, height: 52, borderRadius: 16, background: T.greenSoft, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}><Icon name="spark" size={24} color={T.green} /></div><div style={{ fontSize: 13, color: T.sub, fontWeight: 600 }}>献立を生成中…</div></div>}
          {(mealsState === 'results' || mealsState === 'low') && meals.map(m => {
            const [h, hP] = useHover();
            const on = selId === m.id;
            return (
              <div key={m.id} onClick={() => setSel(m.id)} {...hP} style={{ padding: '11px 14px', borderBottom: `1px solid ${T.line}`, cursor: 'pointer', background: on ? '#EDF5F1' : h ? 'rgba(40,39,35,0.03)' : 'transparent', transition: 'background 0.08s' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 5 }}>
                  <span style={{ fontSize: 22 }}>{m.emoji}</span>
                  <span style={{ fontSize: 14, fontWeight: 800, color: on ? T.greenInk : T.ink, flex: 1 }}>{m.name}</span>
                  {m.useNear && <span style={{ fontSize: 10, fontWeight: 800, padding: '2px 6px', borderRadius: 999, background: T.nearSoft, color: T.near }}>期限近い</span>}
                </div>
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                  <span style={{ fontSize: 10.5, fontWeight: 700, padding: '2px 7px', borderRadius: 999, background: m.device === 'hotcook' ? T.greenSoft : m.device === 'healsio' ? '#E8EEF8' : T.plentySoft, color: m.device === 'hotcook' ? T.greenInk : m.device === 'healsio' ? '#2A5CB8' : T.sub }}>{m.device === 'hotcook' ? '🍲 ホットクック' : m.device === 'healsio' ? '♨️ ヘルシオ' : '🔥 通常調理'}</span>
                  <span style={{ fontSize: 10.5, fontWeight: 700, padding: '2px 7px', borderRadius: 999, background: T.plentySoft, color: T.sub }}>⏱ {m.time}分</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: selMeal ? 0 : 30 }}>
        {!selMeal && <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10, textAlign: 'center', color: T.faint }}><div style={{ fontSize: 36 }}>🥘</div><div style={{ fontSize: 13, fontWeight: 700 }}>献立を選択してください</div></div>}
        {selMeal && (
          <div style={{ padding: '24px 28px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 20 }}>
              <span style={{ fontSize: 48 }}>{selMeal.emoji}</span>
              <div>
                <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink }}>{selMeal.name}</div>
                <div style={{ fontSize: 12.5, color: T.sub, marginTop: 4 }}>調理時間 {selMeal.time}分</div>
              </div>
              <div style={{ marginLeft: 'auto', display: 'flex', gap: 8 }}>
                <TBtn icon="list" label="買い物リストへ" onClick={() => {}} />
                <TBtn icon="check" label="献立に決める" primary onClick={() => {}} />
              </div>
            </div>
            <div style={{ fontWeight: 800, fontSize: 12, color: T.faint, letterSpacing: '0.06em', marginBottom: 10 }}>材料</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 22 }}>
              {selMeal.ingredients.map((ing, i) => <span key={i} style={{ padding: '5px 11px', borderRadius: 8, background: ing.inStock ? T.greenSoft : T.nearSoft, color: ing.inStock ? T.greenInk : T.near, fontSize: 12.5, fontWeight: 700 }}>{ing.emoji} {ing.name} {ing.qty}</span>)}
            </div>
            <div style={{ fontWeight: 800, fontSize: 12, color: T.faint, letterSpacing: '0.06em', marginBottom: 10 }}>手順</div>
            {selMeal.steps.map((s, i) => (
              <div key={i} style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
                <div style={{ width: 24, height: 24, borderRadius: 99, background: T.green, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 800, flexShrink: 0 }}>{i + 1}</div>
                <div style={{ fontSize: 13.5, color: T.ink, lineHeight: 1.65, fontWeight: 600, paddingTop: 3 }}>{s}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ── Screen 4: 買い物リスト ────────────────────────────────────────
function ShoppingScreen() {
  const [items, setItems] = React.useState(clone(SHOP_SEED));
  const [list, setList] = React.useState('買い物');
  const [done, setDone] = React.useState(false);
  const chosen = items.filter(i => i.checked);
  const lists = ['買い物', '日用品', '週末まとめ買い'];
  if (done) return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 14, padding: 40, textAlign: 'center' }}>
      <div className="sl-pop" style={{ width: 80, height: 80, borderRadius: 24, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 10px 30px rgba(31,122,85,0.3)' }}><Icon name="check" size={40} color="#fff" stroke={3} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink }}>{chosen.length}品を追加しました</div>
      <div style={{ fontSize: 14, color: T.sub }}>リマインダーの「{list}」で確認できます</div>
      <div style={{ display: 'flex', gap: 10, marginTop: 8 }}>
        <TBtn icon="open" label="リマインダーを開く" onClick={() => {}} />
        <TBtn icon="check" label="在庫に戻る" primary onClick={() => { setDone(false); setItems(clone(SHOP_SEED)); }} />
      </div>
    </div>
  );
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      <div style={{ flex: 1, overflow: 'auto', borderRight: `1px solid ${T.line}` }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px 16px 6px' }}>
          <div style={{ fontSize: 10.5, fontWeight: 800, color: T.faint, letterSpacing: '0.07em' }}>不足食材 {items.length}品</div>
          <button onClick={() => setItems(p => p.map(x => ({ ...x, checked: !items.every(i => i.checked) })))} style={{ border: `1px solid ${T.line}`, background: '#fff', cursor: 'pointer', padding: '4px 10px', borderRadius: 6, fontFamily: T.font, fontSize: 11.5, fontWeight: 700, color: T.ink }}>{items.every(i => i.checked) ? 'すべて解除' : 'すべて選択'}</button>
        </div>
        {items.map(it => {
          const [h, hP] = useHover();
          return (
            <div key={it.id} {...hP} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 16px', background: h ? 'rgba(40,39,35,0.03)' : 'transparent', opacity: it.checked ? 1 : 0.55, transition: 'all 0.08s' }}>
              <input type="checkbox" checked={it.checked} onChange={() => setItems(p => p.map(x => x.id === it.id ? { ...x, checked: !x.checked } : x))} style={{ width: 16, height: 16, accentColor: T.green, cursor: 'pointer', flexShrink: 0 }} />
              <CatTile item={{ cat: it.cat, emoji: it.emoji }} size={34} />
              <div style={{ flex: 1 }}><div style={{ fontSize: 13, fontWeight: 700, color: T.ink }}>{it.name}</div><div style={{ fontSize: 10.5, color: T.sub, fontWeight: 600 }}>{it.src} 用</div></div>
              <div style={{ display: 'flex', alignItems: 'center', background: T.plentySoft, borderRadius: 8 }}>
                <button onClick={() => setItems(p => p.map(x => x.id === it.id ? { ...x, qty: Math.max(1, x.qty - 1) } : x))} style={{ width: 28, height: 30, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="minus" size={12} color={T.ink} /></button>
                <span style={{ minWidth: 36, textAlign: 'center', fontSize: 12.5, fontWeight: 800, color: T.ink }}>{it.qty}{it.unit}</span>
                <button onClick={() => setItems(p => p.map(x => x.id === it.id ? { ...x, qty: x.qty + 1 } : x))} style={{ width: 28, height: 30, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="plus" size={12} color={T.ink} /></button>
              </div>
            </div>
          );
        })}
      </div>
      <div style={{ width: 340, flexShrink: 0, padding: 24, display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ fontSize: 12, fontWeight: 800, color: T.faint, letterSpacing: '0.07em' }}>追加先リスト</div>
        <div style={{ background: '#fff', borderRadius: 14, border: `1px solid ${T.line}`, overflow: 'hidden' }}>
          <div style={{ padding: '12px 14px', borderBottom: `1px solid ${T.line}`, display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="list" size={17} color={T.green} /></div>
            <div><div style={{ fontSize: 11, fontWeight: 700, color: T.faint }}>アプリ</div><div style={{ fontSize: 13.5, fontWeight: 800, color: T.ink }}>リマインダー（iOS）</div></div>
          </div>
          {lists.map((l, i) => {
            const on = list === l;
            return <button key={l} onClick={() => setList(l)} style={{ width: '100%', border: 'none', background: on ? T.greenSoft : 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 10, padding: '11px 14px', borderBottom: i < lists.length - 1 ? `1px solid ${T.line}` : 'none', fontFamily: T.font }}>
              <span style={{ width: 18, height: 18, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <Icon name="check" size={10} color="#fff" stroke={3} />}</span>
              <span style={{ fontSize: 13, fontWeight: 700, color: T.ink }}>{l}</span>
            </button>;
          })}
        </div>
        <TBtn icon="list" label={`「${list}」に追加（${chosen.length}件）`} primary onClick={() => setDone(true)} disabled={chosen.length === 0} />
      </div>
    </div>
  );
}

// ── Screen 5: 設定 ────────────────────────────────────────────────
function SettingsScreen() {
  const [nav, setNav] = React.useState('ai');
  const [lang, setLang] = React.useState('日本語');
  const [ai, setAi] = React.useState('claude');
  const [sync, setSync] = React.useState(true);
  const AI_LIST = [{ k: 'claude', name: 'Claude', co: 'Anthropic', vision: true, color: '#D97757' }, { k: 'openai', name: 'GPT-4o', co: 'OpenAI', vision: true, color: '#10A37F' }, { k: 'gemini', name: 'Gemini', co: 'Google', vision: true, color: '#4285F4' }, { k: 'grok', name: 'Grok', co: 'xAI', vision: false, color: '#1C1C1E' }];
  const SNAV = [['ai', 'AI設定', 'spark'], ['general', '一般', 'globe'], ['list', '買い物リスト', 'list'], ['appliance', '調理家電', 'pot'], ['data', 'データ', 'cloud'], ['support', 'サポート', 'coffee']];
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      <div style={{ width: 200, flexShrink: 0, padding: '10px 6px', borderRight: `1px solid ${T.line}`, background: '#FAFAF7' }}>
        {SNAV.map(([k, label, icon]) => { const on = nav === k; const [h, hP] = useHover(); return <button key={k} onClick={() => setNav(k)} {...hP} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8, padding: '7px 8px', borderRadius: 7, fontFamily: T.font, textAlign: 'left', background: on ? T.greenSoft : h ? 'rgba(40,39,35,0.05)' : 'transparent', marginBottom: 2 }}><Icon name={icon} size={13} color={on ? T.green : T.sub} stroke={2} /><span style={{ fontSize: 12.5, fontWeight: on ? 700 : 600, color: on ? T.greenInk : T.ink }}>{label}</span></button>; })}
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '20px 28px' }}>
        {nav === 'ai' && (
          <>
            <div style={{ fontFamily: T.brand, fontSize: 18, fontWeight: 700, color: T.ink, marginBottom: 16 }}>AI（食材認識・献立提案）</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 22 }}>
              {AI_LIST.map(p => { const on = ai === p.k; return <button key={p.k} onClick={() => setAi(p.k)} style={{ border: `2px solid ${on ? T.green : T.line}`, borderRadius: 12, padding: 14, cursor: 'pointer', fontFamily: T.font, textAlign: 'left', background: on ? T.greenSoft : '#fff', transition: 'all 0.12s' }}><div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}><div style={{ width: 28, height: 28, borderRadius: 8, background: p.color, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="spark" size={14} color="#fff" /></div><span style={{ fontSize: 14, fontWeight: 800, color: T.ink }}>{p.name}</span></div><div style={{ fontSize: 11, color: T.sub, fontWeight: 600 }}>{p.co} · {p.vision ? '画像認識あり' : '画像認識なし'}</div></button>; })}
            </div>
            <div style={{ background: '#fff', borderRadius: 12, border: `1px solid ${T.line}`, padding: '14px 16px' }}>
              <div style={{ fontSize: 12, fontWeight: 800, color: T.faint, marginBottom: 10, letterSpacing: '0.06em' }}>APIキー</div>
              <input placeholder="sk-ant-..." style={{ width: '100%', border: `1px solid ${T.line}`, borderRadius: 8, padding: '8px 12px', fontFamily: T.font, fontSize: 13, color: T.ink, outline: 'none', background: T.bg }} />
              <div style={{ fontSize: 11.5, color: T.faint, marginTop: 8, fontWeight: 600 }}>キーはこの端末内に安全に保存されます。各社のAPIサイトで取得できます。</div>
            </div>
          </>
        )}
        {nav === 'general' && (
          <>
            <div style={{ fontFamily: T.brand, fontSize: 18, fontWeight: 700, color: T.ink, marginBottom: 16 }}>一般</div>
            <div style={{ background: '#fff', borderRadius: 12, border: `1px solid ${T.line}`, overflow: 'hidden' }}>
              {['日本語', 'English', 'システムに従う'].map((l, i) => <button key={l} onClick={() => setLang(l)} style={{ width: '100%', border: 'none', background: lang === l ? T.greenSoft : 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '13px 16px', borderBottom: i < 2 ? `1px solid ${T.line}` : 'none', fontFamily: T.font, fontSize: 14, fontWeight: 700, color: lang === l ? T.greenInk : T.ink }}>{l}{lang === l && <Icon name="check" size={15} color={T.green} stroke={3} />}</button>)}
            </div>
          </>
        )}
        {nav === 'data' && (
          <>
            <div style={{ fontFamily: T.brand, fontSize: 18, fontWeight: 700, color: T.ink, marginBottom: 16 }}>データ同期</div>
            <div style={{ background: '#fff', borderRadius: 12, border: `1px solid ${T.line}`, padding: '14px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div><div style={{ fontSize: 14, fontWeight: 700, color: T.ink }}>iCloud 同期</div><div style={{ fontSize: 12, color: T.sub, marginTop: 3 }}>最終同期: 今日 9:41</div></div>
              <div onClick={() => setSync(v => !v)} style={{ width: 44, height: 26, borderRadius: 999, background: sync ? T.green : T.line, cursor: 'pointer', position: 'relative', transition: 'background 0.2s' }}><div style={{ width: 22, height: 22, borderRadius: 99, background: '#fff', position: 'absolute', top: 2, left: sync ? 20 : 2, transition: 'left 0.2s', boxShadow: '0 1px 4px rgba(0,0,0,0.2)' }} /></div>
            </div>
          </>
        )}
        {(nav === 'list' || nav === 'appliance' || nav === 'support') && <div style={{ color: T.faint, fontSize: 14, fontWeight: 600, paddingTop: 20 }}>（スマホ版と同じ設定画面）</div>}
      </div>
    </div>
  );
}

// ── Screen 7: オンボーディング ─────────────────────────────────────
function OnboardingScreen({ onComplete }) {
  const [step, setStep] = React.useState(0);
  const next = () => setStep(v => Math.min(5, v + 1));
  const back = step > 0 ? () => setStep(v => v - 1) : null;
  const skip = () => next();
  let content;
  if (step === 0) content = <MacWelcome onNext={next} />;
  else if (step === 1) content = <MacAIStep onNext={next} onBack={back} onSkip={skip} />;
  else if (step === 2) content = <MacLinkStep onNext={next} onBack={back} onSkip={skip} />;
  else if (step === 3) content = <MacListStep onNext={next} onBack={back} onSkip={skip} />;
  else if (step === 4) content = <MacApplianceStep onNext={next} onBack={back} onSkip={skip} />;
  else content = <MacFinish onStart={onComplete} />;
  return (
    <div style={{ height: '100%', display: 'flex' }}>
      <StepRail current={step} />
      <div style={{ flex: 1, overflow: 'hidden' }}>{content}</div>
    </div>
  );
}

// ── Screen 6: ヘルプ ──────────────────────────────────────────────
function HelpScreen() {
  return (
    <div style={{ height: '100%', overflow: 'auto' }}>
      <HelpAbout onBack={() => {}} />
    </div>
  );
}

// ── MacApp root ───────────────────────────────────────────────────
function MacApp() {
  const [nav, setNav] = React.useState('inventory');
  const [search, setSearch] = React.useState('');
  const [camState, setCamState] = React.useState('capture');
  const [mealsState, setMealsState] = React.useState('results');
  const scale = useFitMac();

  const toolbars = {
    inventory: <MacBar title="在庫"><VDiv /><TBtn icon="plus" label="食材を追加" kbd="⌘N" onClick={() => {}} /><TBtn icon="camera" label="カメラ登録" kbd="⌘K" onClick={() => setNav('camera')} /><VDiv /><TBtn icon="spark" label="献立を提案" kbd="⌘R" primary onClick={() => setNav('meals')} /><div style={{ flex: 1 }} /><MacSearch value={search} onChange={setSearch} placeholder="食材を検索…" /></MacBar>,
    camera: <MacBar title="カメラ登録"><VDiv />{['capture', 'analyzing', 'review'].map(s => <button key={s} onClick={() => setCamState(s)} style={{ padding: '4px 10px', borderRadius: 6, border: `1px solid ${camState === s ? T.green : T.line}`, background: camState === s ? T.greenSoft : 'transparent', fontFamily: T.font, fontSize: 12, fontWeight: 700, color: camState === s ? T.greenInk : T.ink, cursor: 'pointer' }}>{{capture:'撮影前',analyzing:'解析中',review:'候補確認'}[s]}</button>)}<div style={{ flex: 1 }} /></MacBar>,
    meals: <MacBar title="献立提案"><VDiv />{['before','generating','results','low'].map(s => <button key={s} onClick={() => setMealsState(s)} style={{ padding: '4px 10px', borderRadius: 6, border: `1px solid ${mealsState === s ? T.green : T.line}`, background: mealsState === s ? T.greenSoft : 'transparent', fontFamily: T.font, fontSize: 12, fontWeight: 700, color: mealsState === s ? T.greenInk : T.ink, cursor: 'pointer' }}>{{before:'提案前',generating:'生成中',results:'提案結果',low:'在庫わずか'}[s]}</button>)}<div style={{ flex: 1 }} /></MacBar>,
    shopping: <MacBar title="買い物リスト"><div style={{ flex: 1 }} /></MacBar>,
    settings: <MacBar title="設定"><div style={{ flex: 1 }} /></MacBar>,
    onboarding: <MacBar title="設定アシスタント"><div style={{ flex: 1 }} /></MacBar>,
    help: <MacBar title="ヘルプ"><div style={{ flex: 1 }} /><MacSearch placeholder="ヘルプを検索…" /></MacBar>,
  };

  const screens = {
    inventory: <InventoryScreen search={search} setSearch={setSearch} />,
    camera: <CameraScreen camState={camState} setCamState={setCamState} />,
    meals: <MealsScreen mealsState={mealsState} setMealsState={setMealsState} />,
    shopping: <ShoppingScreen />,
    settings: <SettingsScreen />,
    onboarding: <OnboardingScreen onComplete={() => setNav('inventory')} />,
    help: <HelpScreen />,
  };

  return (
    <div style={{ minHeight: '100vh', background: 'linear-gradient(145deg,#1E2D12 0%,#2E4A18 35%,#1A3A0F 65%,#243318 100%)', display: 'flex', flexDirection: 'column', alignItems: 'center', fontFamily: T.font }}>
      <div style={{ padding: '32px 20px 48px' }}>
        <div style={{ transform: `scale(${scale})`, transformOrigin: 'top center', width: 1280, marginLeft: (1280 * scale - 1280) / 2 }}>
          <MacAppWindow nav={nav} setNav={setNav} count={ITEMS.length} toolbar={toolbars[nav]}>
            {screens[nav]}
          </MacAppWindow>
        </div>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<MacApp />);
