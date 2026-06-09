// phoneB.jsx — 案B 確定形：グルーピング一覧 + スワイプ操作 + 食材詳細 + 状態トグル
const { T, CATS, ITEMS, expiryOf, sortItems, Icon, ExpiryBadge, CatTile,
        BottomActions, EmptyState, LoadingState } = window;

// base date = 6/7(土). returns "6月6日(金)" style label from days-offset
const WD = ['日', '月', '火', '水', '木', '金', '土'];
function dateLabel(days) {
  const base = new Date(2026, 5, 7);
  const d = new Date(base.getTime() + days * 86400000);
  return `${d.getMonth() + 1}月${d.getDate()}日(${WD[d.getDay()]})`;
}

const GROUPS = [
  { key: 'now',    title: '今日・もうすぐ使い切りたい', tone: T.near,   test: (d) => d <= 3 },
  { key: 'week',   title: '今週のうちに',               tone: T.green,  test: (d) => d > 3 && d <= 9 },
  { key: 'plenty', title: 'まだ余裕',                   tone: T.plenty, test: (d) => d > 9 },
];

// ─────────────────────────────────────────────────────────────
// Swipeable row — tap to open detail, drag left for quick actions
// ─────────────────────────────────────────────────────────────
function SwipeRow({ item, isOpen, setOpen, onTap, onUsedUp, onDelete }) {
  const actions = [
    { key: 'used', label: '使い切った', icon: 'check', bg: T.green, onClick: onUsedUp },
    { key: 'del',  label: '削除',       icon: 'trash', bg: T.over,  onClick: onDelete },
  ];
  const W = actions.length * 80;
  const [x, setX] = React.useState(0);
  const xRef = React.useRef(0);
  const setBoth = (nx) => { xRef.current = nx; setX(nx); };
  const drag = React.useRef(false);
  const moved = React.useRef(false);
  const sx = React.useRef(0);
  const sTx = React.useRef(0);
  React.useEffect(() => { setBoth(isOpen ? -W : 0); }, [isOpen, W]);

  const down = (e) => { drag.current = true; moved.current = false; sx.current = e.clientX; sTx.current = xRef.current;
    try { e.currentTarget.setPointerCapture(e.pointerId); } catch (_) {} };
  const move = (e) => { if (!drag.current) return; const d = e.clientX - sx.current;
    if (Math.abs(d) > 4) moved.current = true; let nx = sTx.current + d; nx = Math.max(-W - 24, Math.min(0, nx)); setBoth(nx); };
  const up = () => { if (!drag.current) return; drag.current = false; const willOpen = xRef.current < -W / 2; setOpen(willOpen ? item.id : null); setBoth(willOpen ? -W : 0); };
  const click = () => { if (moved.current) return; if (isOpen) { setOpen(null); return; } onTap(); };
  const e = expiryOf(item.days);

  return (
    <div style={{ position: 'relative', borderRadius: 16, overflow: 'hidden', background: '#fff',
      boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
      {/* quick actions behind */}
      <div style={{ position: 'absolute', inset: 0, display: 'flex', justifyContent: 'flex-end' }}>
        {actions.map((a) => (
          <button key={a.key} onClick={a.onClick} style={{ width: 80, border: 'none', cursor: 'pointer',
            background: a.bg, color: '#fff', display: 'flex', flexDirection: 'column', gap: 4,
            alignItems: 'center', justifyContent: 'center', fontFamily: T.font, fontSize: 12, fontWeight: 700 }}>
            <Icon name={a.icon} size={20} color="#fff" /> {a.label}
          </button>
        ))}
      </div>
      {/* foreground card */}
      <div onPointerDown={down} onPointerMove={move} onPointerUp={up} onPointerCancel={up} onClick={click}
        style={{ position: 'relative', transform: `translateX(${x}px)`, transition: drag.current ? 'none' : 'transform .22s cubic-bezier(.2,.8,.2,1)',
          background: '#fff', padding: '9px 12px 9px 9px', display: 'flex', alignItems: 'center', gap: 11,
          touchAction: 'pan-y', cursor: 'pointer', userSelect: 'none' }}>
        <div style={{ width: 4, alignSelf: 'stretch', borderRadius: 99, background: e.color, opacity: 0.9 }} />
        <CatTile item={item} size={42} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 700, color: T.ink, lineHeight: 1.2 }}>{item.name}</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 2 }}>{item.cat} ・ {item.qty}{item.unit}</div>
        </div>
        <ExpiryBadge days={item.days} />
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Header — title + search + add
// ─────────────────────────────────────────────────────────────
function HeaderB({ count }) {
  return (
    <div style={{ padding: `${T.statusPad}px 18px 12px` }}>
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginBottom: 2 }}>6月7日(土)</div>
          <div style={{ fontFamily: T.brand, fontSize: 28, fontWeight: 700, color: T.ink, lineHeight: 1 }}>在庫</div>
        </div>
        <div style={{ display: 'flex', gap: 9 }}>
          {['search', 'plus'].map((n) => (
            <button key={n} style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer',
              border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name={n} size={21} color={T.ink} />
            </button>
          ))}
        </div>
      </div>
      {count != null && (
        <div style={{ fontSize: 13, fontWeight: 600, color: T.sub, marginTop: 6 }}>
          冷蔵庫に <b style={{ color: T.ink }}>{count}</b> 点 ・ 使い切りたい順
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Detail screen
// ─────────────────────────────────────────────────────────────
function StepRow({ label, children }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 4px',
      borderBottom: `1px solid ${T.line}` }}>
      <span style={{ fontSize: 14.5, fontWeight: 600, color: T.sub }}>{label}</span>
      {children}
    </div>
  );
}
function Detail({ item, onBack, onQty, onUsedUp, toast }) {
  const e = expiryOf(item.days);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg }}>
      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* nav */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: `${T.statusPad}px 14px 6px` }}>
          <button onClick={onBack} style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer',
            border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span>
          </button>
          <button style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer',
            border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="edit" size={19} color={T.ink} />
          </button>
        </div>
        {/* hero */}
        <div style={{ padding: '8px 20px 4px', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ width: 96, height: 96, borderRadius: 28, background: CATS[item.cat].tile,
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 52 }}>{item.emoji}</div>
          <div style={{ fontFamily: T.brand, fontSize: 24, fontWeight: 700, color: T.ink, marginTop: 14 }}>{item.name}</div>
          <div style={{ marginTop: 10 }}><ExpiryBadge days={item.days} size="lg" /></div>
        </div>
        {/* info card */}
        <div style={{ margin: '16px 16px 0', background: '#fff', borderRadius: 20, padding: '4px 16px' }}>
          <StepRow label="数量">
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <button onClick={() => onQty(-1)} style={stepBtn}><Icon name="minus" size={18} color={T.ink} /></button>
              <span style={{ fontSize: 17, fontWeight: 800, minWidth: 54, textAlign: 'center' }}>{item.qty}{item.unit}</span>
              <button onClick={() => onQty(1)} style={stepBtn}><Icon name="plus" size={18} color={T.ink} /></button>
            </div>
          </StepRow>
          <StepRow label="カテゴリ">
            <span style={{ padding: '4px 12px', borderRadius: 999, background: CATS[item.cat].tile, fontSize: 13.5, fontWeight: 700, color: T.ink }}>{item.cat}</span>
          </StepRow>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 4px' }}>
            <span style={{ fontSize: 14.5, fontWeight: 600, color: T.sub }}>賞味期限</span>
            <span style={{ fontSize: 15, fontWeight: 800, color: e.color }}>{dateLabel(item.days)} <span style={{ color: T.faint, fontWeight: 600, fontSize: 13 }}>／ {e.note}</span></span>
          </div>
        </div>
        {/* secondary actions */}
        <div style={{ display: 'flex', gap: 10, padding: '14px 16px 0' }}>
          {[['bag', '買い物リストに追加', '買い物リストに追加しました'], ['book', 'レシピを見る', 'レシピ提案を準備中です']].map(([ic, lb, ms]) => (
            <button key={lb} onClick={() => toast(ms)} style={{ flex: 1, height: 50, borderRadius: 16, cursor: 'pointer',
              background: '#fff', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7,
              fontFamily: T.font, fontSize: 13.5, fontWeight: 700, color: T.ink }}>
              <Icon name={ic} size={18} color={T.green} /> {lb}
            </button>
          ))}
        </div>
      </div>
      {/* primary */}
      <div style={{ padding: '12px 16px 26px', background: `linear-gradient(to top, ${T.bg} 70%, transparent)` }}>
        <button onClick={onUsedUp} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer',
          background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9,
          fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="check" size={22} color="#fff" /> 使い切った
        </button>
      </div>
    </div>
  );
}
const stepBtn = { width: 36, height: 36, borderRadius: 11, background: '#F4F1EB', border: 'none', cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center' };

// ─────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────
function PhoneB({ state }) {
  const seed = sortItems(ITEMS).map((i) => ({ ...i, qty: parseInt(i.qty, 10), _unit: i.unit }));
  const [items, setItems] = React.useState(seed);
  const [openId, setOpenId] = React.useState(null);
  const [sel, setSel] = React.useState(null);
  const [toastMsg, setToastMsg] = React.useState(null);
  const tRef = React.useRef(null);

  React.useEffect(() => { setItems(seed); setSel(null); setOpenId(null); /* reset on state change */ }, [state]);

  const toast = (m) => { setToastMsg(m); clearTimeout(tRef.current); tRef.current = setTimeout(() => setToastMsg(null), 1900); };
  const usedUp = (id) => { setItems((p) => p.filter((x) => x.id !== id)); setOpenId(null); setSel(null); toast('使い切りました'); };
  const del = (id) => { setItems((p) => p.filter((x) => x.id !== id)); setOpenId(null); toast('削除しました'); };
  const chgQty = (id, d) => setItems((p) => p.map((x) => x.id === id ? { ...x, qty: Math.max(1, x.qty + d) } : x));

  const selItem = items.find((x) => x.id === sel);

  let body;
  if (state === 'empty') body = <div style={{ height: '100%', minHeight: '100%', background: T.bg, fontFamily: T.font, display: 'flex', flexDirection: 'column' }}><div style={{ padding: `${T.statusPad}px 18px 4px`, flexShrink: 0 }}><div style={{ fontFamily: T.brand, fontSize: 28, fontWeight: 700, color: T.ink }}>在庫</div></div><EmptyState /></div>;
  else if (state === 'loading') body = <div style={{ minHeight: '100%', background: T.bg, fontFamily: T.font }}><HeaderB /><LoadingState layout="list" /></div>;
  else body = (
    <div style={{ minHeight: '100%', background: T.bg, display: 'flex', flexDirection: 'column', fontFamily: T.font, color: T.ink }}>
      <HeaderB count={items.length} />
      <div style={{ flex: 1, padding: '8px 16px 8px' }} onClick={() => openId && setOpenId(null)}>
        {GROUPS.map((g) => {
          const list = items.filter((it) => g.test(it.days));
          if (!list.length) return null;
          return (
            <div key={g.key} style={{ marginBottom: 20 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 2px 9px' }}>
                <span style={{ width: 9, height: 9, borderRadius: 99, background: g.tone }} />
                <span style={{ fontSize: 13.5, fontWeight: 800, color: T.ink }}>{g.title}</span>
                <span style={{ fontSize: 12, fontWeight: 700, color: T.faint }}>{list.length}</span>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
                {list.map((it) => (
                  <SwipeRow key={it.id} item={{ ...it, unit: it._unit }} isOpen={openId === it.id} setOpen={setOpenId}
                    onTap={() => setSel(it.id)} onUsedUp={() => usedUp(it.id)} onDelete={() => del(it.id)} />
                ))}
              </div>
            </div>
          );
        })}
        <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, padding: '2px 0 4px' }}>← カードを左にスワイプでクイック操作</div>
      </div>
      <BottomActions />
    </div>
  );

  return (
    <div style={{ position: 'relative', height: '100%', overflow: 'hidden' }}>
      <div style={{ height: '100%', overflow: 'auto' }}>{body}</div>
      {/* detail overlay */}
      <div style={{ position: 'absolute', inset: 0, zIndex: 60, background: T.bg, transform: selItem ? 'translateX(0)' : 'translateX(100%)',
        transition: 'transform .28s cubic-bezier(.2,.8,.2,1)', boxShadow: selItem ? '-12px 0 30px rgba(0,0,0,0.08)' : 'none' }}>
        {selItem && <Detail item={{ ...selItem, unit: selItem._unit }} onBack={() => setSel(null)}
          onQty={(d) => chgQty(selItem.id, d)} onUsedUp={() => usedUp(selItem.id)} toast={toast} />}
      </div>
      {/* toast */}
      {toastMsg && (
        <div style={{ position: 'absolute', left: '50%', bottom: 104, transform: 'translateX(-50%)', zIndex: 80,
          background: 'rgba(42,39,35,0.94)', color: '#fff', padding: '11px 20px', borderRadius: 999,
          fontFamily: T.font, fontSize: 13.5, fontWeight: 700, whiteSpace: 'nowrap',
          boxShadow: '0 8px 24px rgba(0,0,0,0.22)' }}>{toastMsg}</div>
      )}
    </div>
  );
}

Object.assign(window, { PhoneB });
