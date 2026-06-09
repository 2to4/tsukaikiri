// shoppingPhone.jsx — 買い物リスト確認（スマホ・iOS=リマインダー）
const { T, Icon, CatTile, CATS } = window;

const SHOP_SEED = [
  { id: 1, name: '玉ねぎ',     emoji: '🧅', qty: 2,   unit: '個', cat: '野菜',   src: 'チキンカレー', checked: true },
  { id: 2, name: 'じゃがいも', emoji: '🥔', qty: 2,   unit: '個', cat: '野菜',   src: 'チキンカレー', checked: true },
  { id: 3, name: '鶏もも肉',   emoji: '🍗', qty: 300, unit: 'g', cat: '肉',     src: 'チキンカレー', checked: true },
  { id: 4, name: 'カレールー', emoji: '🍛', qty: 1,   unit: '箱', cat: '調味料', src: 'チキンカレー', checked: true },
  { id: 5, name: 'キャベツ',   emoji: '🥬', qty: 2,   unit: '枚', cat: '野菜',   src: '鮭のちゃんちゃん焼き', checked: true },
  { id: 6, name: '小ねぎ',     emoji: '🌿', qty: 1,   unit: '束', cat: '野菜',   src: 'トマトと卵の炒め', checked: false },
];
const DEST = { app: 'リマインダー', lists: ['買い物', '日用品', '週末まとめ買い'] };
const stepInc = (id, d, set) => set((p) => p.map((x) => x.id === id ? { ...x, qty: Math.max(1, x.qty + d) } : x));

function Check({ on, onClick, size = 26 }) {
  return (
    <button onClick={onClick} style={{ width: size, height: size, borderRadius: 8, cursor: 'pointer', flexShrink: 0,
      border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {on && <Icon name="check" size={size * 0.62} color="#fff" stroke={3} />}
    </button>
  );
}
function ItemRow({ it, onToggle, onQty }) {
  const off = !it.checked;
  return (
    <div style={{ background: off ? '#FBFAF7' : '#fff', borderRadius: 16, padding: '11px 13px', display: 'flex', alignItems: 'center', gap: 12,
      boxShadow: '0 1px 2px rgba(40,39,35,0.04)', opacity: off ? 0.7 : 1, transition: 'opacity .15s' }}>
      <Check on={it.checked} onClick={onToggle} size={24} />
      <CatTile item={{ cat: it.cat, emoji: it.emoji }} size={44} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15.5, fontWeight: 700, color: T.ink, lineHeight: 1.2 }}>{it.name}</div>
        <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, marginTop: 2 }}>{it.src} 用</div>
      </div>
      <div style={{ display: 'inline-flex', alignItems: 'center', background: '#F4F1EB', borderRadius: 11 }}>
        <button onClick={() => onQty(-1)} style={qStep}><Icon name="minus" size={15} color={T.ink} /></button>
        <span style={{ minWidth: 40, textAlign: 'center', fontSize: 14, fontWeight: 800, color: T.ink }}>{it.qty}{it.unit}</span>
        <button onClick={() => onQty(1)} style={qStep}><Icon name="plus" size={15} color={T.ink} /></button>
      </div>
    </div>
  );
}
const qStep = { width: 32, height: 34, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' };

function DestCard({ list, onChange }) {
  const [open, setOpen] = React.useState(false);
  return (
    <div style={{ background: '#fff', borderRadius: 16, boxShadow: '0 1px 2px rgba(40,39,35,0.04)', overflow: 'hidden' }}>
      <button onClick={() => setOpen((o) => !o)} style={{ width: '100%', border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
        <div style={{ width: 40, height: 40, borderRadius: 12, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="list" size={21} color={T.green} /></div>
        <div style={{ flex: 1, textAlign: 'left' }}>
          <div style={{ fontSize: 11.5, fontWeight: 700, color: T.faint }}>追加先</div>
          <div style={{ fontSize: 15, fontWeight: 800, color: T.ink, marginTop: 1 }}>{DEST.app} <span style={{ color: T.faint }}>・</span> {list}</div>
        </div>
        <span style={{ display: 'flex', alignItems: 'center', gap: 4, color: T.sub, fontSize: 13, fontWeight: 700 }}>変更<span style={{ transform: open ? 'rotate(90deg)' : 'none', display: 'flex', transition: 'transform .15s' }}><Icon name="chevron" size={15} color={T.sub} stroke={2.4} /></span></span>
      </button>
      {open && (
        <div style={{ borderTop: `1px solid ${T.line}`, padding: '6px 8px 8px' }}>
          {DEST.lists.map((l) => {
            const on = l === list;
            return (
              <button key={l} onClick={() => { onChange(l); setOpen(false); }} style={{ width: '100%', border: 'none', background: on ? T.greenSoft : 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 10, padding: '11px 12px', borderRadius: 10, marginTop: 2 }}>
                <span style={{ width: 20, height: 20, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <Icon name="check" size={12} color="#fff" stroke={3} />}</span>
                <span style={{ flex: 1, textAlign: 'left', fontSize: 14.5, fontWeight: 700, color: T.ink }}>{l}</span>
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ── 通常 ──
function ListScreen({ items, setItems, list, setList, onAdd, onBack }) {
  const chosen = items.filter((i) => i.checked).length;
  const allOn = chosen === items.length;
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ padding: `${T.statusPad}px 16px 8px` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={onBack} style={navBtn}><span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span></button>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>買い物リスト</div>
            <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 2 }}>献立に足りない食材です</div>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 14 }}>
          <div style={{ fontSize: 13, fontWeight: 700, color: T.sub }}>不足 {items.length}品 ・ <b style={{ color: T.green }}>{chosen}品</b>を追加</div>
          <button onClick={() => setItems((p) => p.map((x) => ({ ...x, checked: !allOn })))} style={{ border: `1.5px solid ${T.line}`, background: '#fff', cursor: 'pointer', padding: '7px 12px', borderRadius: 999, fontFamily: T.font, fontSize: 12.5, fontWeight: 700, color: T.ink }}>{allOn ? 'すべて解除' : 'すべて選択'}</button>
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 16px 8px', display: 'flex', flexDirection: 'column', gap: 9 }}>
        {items.map((it) => <ItemRow key={it.id} it={it} onToggle={() => setItems((p) => p.map((x) => x.id === it.id ? { ...x, checked: !x.checked } : x))} onQty={(d) => stepInc(it.id, d, setItems)} />)}
      </div>
      <div style={{ padding: '12px 16px 26px', background: `linear-gradient(to top, ${T.bg} 76%, transparent)`, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <DestCard list={list} onChange={setList} />
        <button onClick={onAdd} disabled={chosen === 0} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none', cursor: chosen ? 'pointer' : 'default',
          background: chosen ? T.green : '#D8D4CB', boxShadow: chosen ? '0 12px 26px rgba(31,122,85,0.3)' : 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="list" size={21} color="#fff" /> 「{list}」に追加（{chosen}件）
        </button>
      </div>
    </div>
  );
}
const navBtn = { width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 };

// ── 追加中 ──
function AddingScreen({ list, count }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, background: T.bg, fontFamily: T.font, padding: 30, textAlign: 'center' }}>
      <div className="cam-pulse" style={{ width: 92, height: 92, borderRadius: 30, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="list" size={40} color={T.green} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>{DEST.app}に追加中…</div>
      <div style={{ fontSize: 14, fontWeight: 600, color: T.sub }}>「{list}」に {count}件 を送信しています</div>
      <div style={{ width: 200, height: 6, borderRadius: 99, background: '#E6E2D9', overflow: 'hidden', marginTop: 14 }}><div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} /></div>
    </div>
  );
}

// ── 完了 ──
function DoneScreen({ list, items, onOpen, onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 28, textAlign: 'center' }}>
        <div className="sl-pop" style={{ width: 100, height: 100, borderRadius: 32, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 10, boxShadow: '0 14px 30px rgba(31,122,85,0.32)' }}><Icon name="check" size={50} color="#fff" stroke={3} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink }}>{items.length}品を追加しました</div>
        <div style={{ fontSize: 14.5, fontWeight: 600, color: T.sub, lineHeight: 1.7 }}>{DEST.app}の「<b style={{ color: T.greenInk }}>{list}</b>」で<br />確認・チェックできます</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7, justifyContent: 'center', marginTop: 16, maxWidth: 300 }}>
          {items.map((it) => <span key={it.id} style={{ padding: '5px 11px', borderRadius: 999, background: '#fff', boxShadow: `inset 0 0 0 1px ${T.line}`, color: T.ink, fontSize: 12.5, fontWeight: 700 }}>{it.emoji} {it.name}</span>)}
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, padding: '0 16px 32px' }}>
        <button onClick={onOpen} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="open" size={20} color="#fff" /> {DEST.app}を開く
        </button>
        <button onClick={onBack} style={{ width: '100%', height: 54, borderRadius: 16, cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>在庫にもどる</button>
      </div>
    </div>
  );
}

// ── エラー ──
function ShopError({ onRetry, onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 30, textAlign: 'center' }}>
        <div style={{ width: 96, height: 96, borderRadius: 30, background: T.nearSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="alert" size={42} color={T.near} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>リストに追加できませんでした</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.75, maxWidth: 280 }}>時間をおいて、もう一度お試しください。<br />解決しない場合は、リマインダーへの<br />アクセス許可をご確認ください。</div>
        <div style={{ marginTop: 6, fontSize: 12.5, fontWeight: 600, color: T.faint, background: '#fff', borderRadius: 10, padding: '8px 13px' }}>選択した内容は保持されています</div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, padding: '0 16px 32px' }}>
        <button onClick={onRetry} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}><Icon name="refresh" size={21} color="#fff" /> もう一度試す</button>
        <button onClick={onBack} style={{ width: '100%', height: 54, borderRadius: 16, cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>もどる</button>
      </div>
    </div>
  );
}

window.ShoppingPhone = { SHOP_SEED, DEST, ListScreen, AddingScreen, DoneScreen, ShopError };
