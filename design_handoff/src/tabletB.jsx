// tabletB.jsx — 在庫画面 タブレット横向き・二ペイン（案Bのデザイン言語を継承）
const { T, CATS, CAT_ORDER, ITEMS, expiryOf, sortItems, Icon, ExpiryBadge, CatTile,
        Chips, EmptyState, LoadingState, Skel } = window;

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
const CW = 1194, CH = 834; // landscape canvas

// ─────────────────────────────────────────────────────────────
// iPad landscape frame
// ─────────────────────────────────────────────────────────────
function TabletFrame({ children }) {
  return (
    <div style={{ width: CW + 36, height: CH + 36, borderRadius: 46, background: '#1B1A18',
      padding: 18, boxSizing: 'border-box', position: 'relative',
      boxShadow: '0 50px 100px rgba(0,0,0,0.22), 0 0 0 1px rgba(0,0,0,0.2)' }}>
      <div style={{ position: 'absolute', top: '50%', left: 9, transform: 'translateY(-50%)', width: 5, height: 5, borderRadius: 99, background: '#34322E' }} />
      <div style={{ width: CW, height: CH, borderRadius: 30, overflow: 'hidden', background: T.bg, position: 'relative' }}>
        {children}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Left pane — list
// ─────────────────────────────────────────────────────────────
function ListRow({ item, selected, onClick }) {
  const e = expiryOf(item.days);
  return (
    <div onClick={onClick} style={{ position: 'relative', borderRadius: 16, cursor: 'pointer',
      background: selected ? T.greenSoft : '#fff',
      boxShadow: selected ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)',
      padding: '11px 14px 11px 10px', display: 'flex', alignItems: 'center', gap: 12, transition: 'background .15s' }}>
      <div style={{ width: 4, alignSelf: 'stretch', borderRadius: 99, background: e.color, opacity: 0.9 }} />
      <CatTile item={item} size={46} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, fontWeight: 700, color: T.ink, lineHeight: 1.2 }}>{item.name}</div>
        <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 2 }}>{item.cat} ・ {item.qty}{item.unit}</div>
      </div>
      <ExpiryBadge days={item.days} />
    </div>
  );
}

function LeftPane({ state, items, cat, setCat, selId, setSel }) {
  if (state === 'empty') {
    return (
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '26px 26px 6px', flexShrink: 0 }}>
          <div style={{ fontFamily: T.brand, fontSize: 27, fontWeight: 700, color: T.ink }}>在庫</div>
        </div>
        <EmptyState />
      </div>
    );
  }
  const filtered = items.filter((it) => cat === 'すべて' || it.cat === cat);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* header */}
      <div style={{ padding: '26px 24px 10px', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontSize: 13, fontWeight: 600, color: T.sub, marginBottom: 2 }}>6月7日(土)</div>
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
        <div style={{ fontSize: 13, fontWeight: 600, color: T.sub, marginTop: 6 }}>
          冷蔵庫に <b style={{ color: T.ink }}>{items.length}</b> 点 ・ 使い切りたい順
        </div>
      </div>
      {/* category chips */}
      <div style={{ flexShrink: 0, paddingBottom: 6 }}><Chips active={cat} onPick={setCat} /></div>
      {/* list */}
      <div style={{ flex: 1, overflow: 'auto', padding: '6px 18px 12px' }}>
        {state === 'loading' ? <LoadingState layout="list" chips={false} /> : (
          GROUPS.map((g) => {
            const list = filtered.filter((it) => g.test(it.days));
            if (!list.length) return null;
            return (
              <div key={g.key} style={{ marginBottom: 18 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 2px 8px' }}>
                  <span style={{ width: 9, height: 9, borderRadius: 99, background: g.tone }} />
                  <span style={{ fontSize: 13.5, fontWeight: 800, color: T.ink }}>{g.title}</span>
                  <span style={{ fontSize: 12, fontWeight: 700, color: T.faint }}>{list.length}</span>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
                  {list.map((it) => <ListRow key={it.id} item={it} selected={selId === it.id} onClick={() => setSel(it.id)} />)}
                </div>
              </div>
            );
          })
        )}
        {state === 'normal' && filtered.length === 0 && (
          <div style={{ textAlign: 'center', color: T.faint, fontSize: 13.5, fontWeight: 600, padding: '40px 0' }}>
            「{cat}」の食材はありません
          </div>
        )}
      </div>
      {/* bottom action */}
      <div style={{ flexShrink: 0, padding: '12px 18px 18px', display: 'flex', gap: 12,
        borderTop: `1px solid ${T.line}`, background: T.bg }}>
        <button style={{ flex: 1, height: 58, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green,
          boxShadow: '0 10px 22px rgba(31,122,85,0.26)', display: 'flex', alignItems: 'center', gap: 11, padding: '0 20px',
          fontFamily: T.font, textAlign: 'left' }}>
          <Icon name="spark" size={22} color="#fff" />
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 16, fontWeight: 800, color: '#fff', lineHeight: 1.2 }}>献立を提案</div>
            <div style={{ fontSize: 11.5, fontWeight: 600, color: 'rgba(255,255,255,0.82)' }}>使い切りメニューを見る</div>
          </div>
        </button>
        <button title="カメラで登録" style={{ width: 58, height: 58, borderRadius: 18, cursor: 'pointer', background: '#fff',
          border: `1.5px solid ${T.greenSoft}`, boxShadow: '0 8px 18px rgba(31,122,85,0.16)',
          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="camera" size={26} color={T.green} />
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Right pane — detail / edit
// ─────────────────────────────────────────────────────────────
const stepBtn = { width: 40, height: 40, borderRadius: 12, background: '#F4F1EB', border: 'none', cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center' };

function Field({ label, children, alignTop }) {
  return (
    <div style={{ padding: '18px 0', borderBottom: `1px solid ${T.line}`, display: 'flex',
      alignItems: alignTop ? 'flex-start' : 'center', justifyContent: 'space-between', gap: 16 }}>
      <span style={{ fontSize: 15, fontWeight: 700, color: T.sub, paddingTop: alignTop ? 4 : 0 }}>{label}</span>
      <div>{children}</div>
    </div>
  );
}

function RightPane({ state, item, onQty, onCat, onUsedUp, onDelete, toast }) {
  if (state === 'loading') {
    return (
      <div style={{ height: '100%', padding: 40, display: 'flex', flexDirection: 'column', gap: 24 }}>
        <div style={{ display: 'flex', gap: 22, alignItems: 'center' }}>
          <Skel w={120} h={120} r={32} />
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 12 }}>
            <Skel w={'50%'} h={26} /><Skel w={'34%'} h={16} /><Skel w={120} h={30} r={999} />
          </div>
        </div>
        {[0, 1, 2].map((i) => <Skel key={i} w={'100%'} h={56} r={14} />)}
      </div>
    );
  }
  if (!item) {
    return (
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        textAlign: 'center', gap: 14, padding: 40 }}>
        <div style={{ width: 92, height: 92, borderRadius: 28, background: '#fff', border: `1.5px solid ${T.line}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="box" size={40} color={T.faint} />
        </div>
        <div style={{ fontFamily: T.brand, fontSize: 19, fontWeight: 700, color: T.sub }}>
          {state === 'empty' ? 'まだ食材がありません' : '食材を選んでください'}
        </div>
        <div style={{ fontSize: 14, fontWeight: 500, color: T.faint, lineHeight: 1.7, maxWidth: 280 }}>
          {state === 'empty'
            ? '左から登録すると、ここで詳細を編集できます。'
            : '左の一覧から食材をタップすると、\nここに詳細と編集が表示されます。'}
        </div>
      </div>
    );
  }
  const e = expiryOf(item.days);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '40px 44px 8px' }}>
        {/* hero */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 24 }}>
          <div style={{ width: 124, height: 124, borderRadius: 34, background: CATS[item.cat].tile,
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 66, flexShrink: 0 }}>{item.emoji}</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: T.brand, fontSize: 32, fontWeight: 700, color: T.ink, lineHeight: 1.15 }}>{item.name}</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 12 }}>
              <ExpiryBadge days={item.days} size="lg" />
              <span style={{ fontSize: 14.5, fontWeight: 700, color: T.faint }}>{dateLabel(item.days)} まで</span>
            </div>
          </div>
        </div>
        {/* fields */}
        <div style={{ marginTop: 26 }}>
          <Field label="数量">
            <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
              <button onClick={() => onQty(-1)} style={stepBtn}><Icon name="minus" size={19} color={T.ink} /></button>
              <span style={{ fontSize: 19, fontWeight: 800, minWidth: 64, textAlign: 'center' }}>{item.qty}{item.unit}</span>
              <button onClick={() => onQty(1)} style={stepBtn}><Icon name="plus" size={19} color={T.ink} /></button>
            </div>
          </Field>
          <Field label="カテゴリ" alignTop>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'flex-end', maxWidth: 380 }}>
              {CAT_ORDER.map((c) => {
                const on = item.cat === c;
                return (
                  <button key={c} onClick={() => onCat(c)} style={{ border: 'none', cursor: 'pointer',
                    padding: '8px 14px', borderRadius: 999, fontFamily: T.font, fontSize: 13.5, fontWeight: 700,
                    background: on ? T.ink : CATS[c].tile, color: on ? '#fff' : T.ink }}>{c}</button>
                );
              })}
            </div>
          </Field>
          <Field label="賞味期限">
            <span style={{ fontSize: 17, fontWeight: 800, color: e.color }}>
              {dateLabel(item.days)} <span style={{ color: T.faint, fontWeight: 600, fontSize: 14 }}>／ {e.note}</span>
            </span>
          </Field>
          <Field label="登録日">
            <span style={{ fontSize: 15.5, fontWeight: 700, color: T.ink }}>{dateLabel(item.days - 4)}</span>
          </Field>
        </div>
        {/* secondary actions */}
        <div style={{ display: 'flex', gap: 12, marginTop: 26 }}>
          {[['bag', '買い物リストに追加', '買い物リストに追加しました'], ['book', 'レシピを見る', 'レシピ提案を準備中です']].map(([ic, lb, ms]) => (
            <button key={lb} onClick={() => toast(ms)} style={{ flex: 1, height: 54, borderRadius: 16, cursor: 'pointer',
              background: '#fff', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9,
              fontFamily: T.font, fontSize: 14.5, fontWeight: 700, color: T.ink }}>
              <Icon name={ic} size={19} color={T.green} /> {lb}
            </button>
          ))}
        </div>
      </div>
      {/* primary actions */}
      <div style={{ flexShrink: 0, padding: '16px 44px 26px', borderTop: `1px solid ${T.line}`,
        display: 'flex', gap: 14, alignItems: 'center' }}>
        <button onClick={onUsedUp} style={{ flex: 1, height: 62, borderRadius: 18, border: 'none', cursor: 'pointer',
          background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          <Icon name="check" size={23} color="#fff" /> 使い切った
        </button>
        <button onClick={onDelete} title="削除" style={{ width: 62, height: 62, borderRadius: 18, cursor: 'pointer',
          background: '#fff', border: `1.5px solid ${T.overSoft}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="trash" size={23} color={T.over} />
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────
function TabletB({ state }) {
  const seed = sortItems(ITEMS).map((i) => ({ ...i, qty: parseInt(i.qty, 10) }));
  const [items, setItems] = React.useState(seed);
  const [cat, setCat] = React.useState('すべて');
  const [selId, setSel] = React.useState(seed[0].id);
  const [toastMsg, setToastMsg] = React.useState(null);
  const tRef = React.useRef(null);

  React.useEffect(() => { setItems(seed); setCat('すべて'); setSel(state === 'normal' ? seed[0].id : null); }, [state]);

  const toast = (m) => { setToastMsg(m); clearTimeout(tRef.current); tRef.current = setTimeout(() => setToastMsg(null), 1900); };
  const sel = items.find((x) => x.id === selId) || null;
  const removeSel = (msg) => {
    setItems((p) => {
      const idx = p.findIndex((x) => x.id === selId);
      const next = p.filter((x) => x.id !== selId);
      setSel(next.length ? next[Math.min(idx, next.length - 1)].id : null);
      return next;
    });
    toast(msg);
  };

  return (
    <div style={{ display: 'flex', height: '100%', fontFamily: T.font, color: T.ink, position: 'relative' }}>
      {/* status bar (slim) */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 0, zIndex: 5 }} />
      {/* left */}
      <div style={{ width: 452, flexShrink: 0, borderRight: `1px solid ${T.line}`, background: '#FBFAF7' }}>
        <LeftPane state={state} items={items} cat={cat} setCat={setCat} selId={selId} setSel={setSel} />
      </div>
      {/* right */}
      <div style={{ flex: 1, background: T.bg }}>
        <RightPane state={state} item={state === 'empty' ? null : sel}
          onQty={(d) => setItems((p) => p.map((x) => x.id === selId ? { ...x, qty: Math.max(1, x.qty + d) } : x))}
          onCat={(c) => setItems((p) => p.map((x) => x.id === selId ? { ...x, cat: c } : x))}
          onUsedUp={() => removeSel('使い切りました')} onDelete={() => removeSel('削除しました')} toast={toast} />
      </div>
      {/* toast */}
      {toastMsg && (
        <div style={{ position: 'absolute', left: 226, bottom: 30, transform: 'translateX(-50%)', zIndex: 80,
          background: 'rgba(42,39,35,0.94)', color: '#fff', padding: '12px 22px', borderRadius: 999,
          fontFamily: T.font, fontSize: 14, fontWeight: 700, whiteSpace: 'nowrap', boxShadow: '0 8px 24px rgba(0,0,0,0.22)' }}>{toastMsg}</div>
      )}
    </div>
  );
}

Object.assign(window, { TabletB, TabletFrame, CW, CH });
