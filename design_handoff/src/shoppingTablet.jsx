// shoppingTablet.jsx — 買い物リスト確認 タブレット（左=不足一覧 / 右=追加先・操作）
const { T, Icon, CatTile } = window;
const CW = 1194, CH = 834;

const SHOP_SEED = [
  { id: 1, name: '玉ねぎ',     emoji: '🧅', qty: 2,   unit: '個', cat: '野菜',   src: 'チキンカレー', checked: true },
  { id: 2, name: 'じゃがいも', emoji: '🥔', qty: 2,   unit: '個', cat: '野菜',   src: 'チキンカレー', checked: true },
  { id: 3, name: '鶏もも肉',   emoji: '🍗', qty: 300, unit: 'g', cat: '肉',     src: 'チキンカレー', checked: true },
  { id: 4, name: 'カレールー', emoji: '🍛', qty: 1,   unit: '箱', cat: '調味料', src: 'チキンカレー', checked: true },
  { id: 5, name: 'キャベツ',   emoji: '🥬', qty: 2,   unit: '枚', cat: '野菜',   src: '鮭のちゃんちゃん焼き', checked: true },
  { id: 6, name: '小ねぎ',     emoji: '🌿', qty: 1,   unit: '束', cat: '野菜',   src: 'トマトと卵の炒め', checked: false },
];
const DEST = { app: 'リマインダー', lists: ['買い物', '日用品', '週末まとめ買い'] };

function Check({ on, onClick, size = 26 }) {
  return (
    <button onClick={onClick} style={{ width: size, height: size, borderRadius: 8, cursor: 'pointer', flexShrink: 0, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {on && <Icon name="check" size={size * 0.62} color="#fff" stroke={3} />}
    </button>
  );
}
const qStep = { width: 34, height: 36, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' };
function ItemRow({ it, onToggle, onQty }) {
  const off = !it.checked;
  return (
    <div style={{ background: off ? '#FBFAF7' : '#fff', borderRadius: 16, padding: '12px 15px', display: 'flex', alignItems: 'center', gap: 13, boxShadow: '0 1px 2px rgba(40,39,35,0.04)', opacity: off ? 0.7 : 1 }}>
      <Check on={it.checked} onClick={onToggle} size={26} />
      <CatTile item={{ cat: it.cat, emoji: it.emoji }} size={46} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, fontWeight: 700, color: T.ink, lineHeight: 1.2 }}>{it.name}</div>
        <div style={{ fontSize: 12, fontWeight: 600, color: T.faint, marginTop: 2 }}>{it.src} 用</div>
      </div>
      <div style={{ display: 'inline-flex', alignItems: 'center', background: '#F4F1EB', borderRadius: 12 }}>
        <button onClick={() => onQty(-1)} style={qStep}><Icon name="minus" size={16} color={T.ink} /></button>
        <span style={{ minWidth: 48, textAlign: 'center', fontSize: 15, fontWeight: 800, color: T.ink }}>{it.qty}{it.unit}</span>
        <button onClick={() => onQty(1)} style={qStep}><Icon name="plus" size={16} color={T.ink} /></button>
      </div>
    </div>
  );
}

// right action panel
function DestPanel({ list, setList, chosen, onAdd }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '30px 24px 8px' }}>
        <div style={{ fontFamily: T.brand, fontSize: 20, fontWeight: 700, color: T.ink }}>追加先</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 14, background: '#fff', borderRadius: 16, padding: '13px 14px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          <div style={{ width: 44, height: 44, borderRadius: 13, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="list" size={22} color={T.green} /></div>
          <div>
            <div style={{ fontSize: 11.5, fontWeight: 700, color: T.faint }}>アプリ</div>
            <div style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>{DEST.app}</div>
          </div>
        </div>
        <div style={{ fontSize: 13, fontWeight: 700, color: T.sub, margin: '20px 2px 10px' }}>リストを選択</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {DEST.lists.map((l) => {
            const on = l === list;
            return (
              <button key={l} onClick={() => setList(l)} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 11, padding: '13px 14px', borderRadius: 14, background: on ? T.greenSoft : '#fff', boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)' }}>
                <span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>
                <span style={{ flex: 1, textAlign: 'left', fontSize: 15, fontWeight: 700, color: T.ink }}>{l}</span>
              </button>
            );
          })}
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '16px 24px 24px', borderTop: `1px solid ${T.line}` }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: T.sub, marginBottom: 12, textAlign: 'center' }}>選択中 <b style={{ color: T.green, fontSize: 15 }}>{chosen}</b> 品を追加します</div>
        <button onClick={onAdd} disabled={chosen === 0} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none', cursor: chosen ? 'pointer' : 'default', background: chosen ? T.green : '#D8D4CB', boxShadow: chosen ? '0 12px 26px rgba(31,122,85,0.3)' : 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="list" size={21} color="#fff" /> 「{list}」に追加（{chosen}件）
        </button>
      </div>
    </div>
  );
}

function NormalPane({ items, setItems, list, setList, onAdd }) {
  const chosen = items.filter((i) => i.checked).length;
  const allOn = chosen === items.length;
  return (
    <div style={{ height: '100%', display: 'flex', fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '30px 28px 12px' }}>
          <div style={{ fontFamily: T.brand, fontSize: 27, fontWeight: 700, color: T.ink }}>買い物リスト</div>
          <div style={{ fontSize: 14, fontWeight: 600, color: T.sub, marginTop: 4 }}>献立に足りない食材を、リマインダーに追加します</div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 16 }}>
            <div style={{ fontSize: 13.5, fontWeight: 700, color: T.sub }}>不足 {items.length}品 ・ <b style={{ color: T.green }}>{chosen}品</b>を追加</div>
            <button onClick={() => setItems((p) => p.map((x) => ({ ...x, checked: !allOn })))} style={{ border: `1.5px solid ${T.line}`, background: '#fff', cursor: 'pointer', padding: '8px 14px', borderRadius: 999, fontFamily: T.font, fontSize: 13, fontWeight: 700, color: T.ink }}>{allOn ? 'すべて解除' : 'すべて選択'}</button>
          </div>
        </div>
        <div style={{ flex: 1, overflow: 'auto', padding: '6px 24px 20px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {items.map((it) => <ItemRow key={it.id} it={it} onToggle={() => setItems((p) => p.map((x) => x.id === it.id ? { ...x, checked: !x.checked } : x))} onQty={(d) => setItems((p) => p.map((x) => x.id === it.id ? { ...x, qty: Math.max(1, x.qty + d) } : x))} />)}
        </div>
      </div>
      <div style={{ width: 404, flexShrink: 0, borderLeft: `1px solid ${T.line}`, background: '#FBFAF7' }}>
        <DestPanel list={list} setList={setList} chosen={chosen} onAdd={onAdd} />
      </div>
    </div>
  );
}

function AddingFull({ list, count }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, background: T.bg, fontFamily: T.font, padding: 40, textAlign: 'center' }}>
      <div className="cam-pulse" style={{ width: 104, height: 104, borderRadius: 32, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 6 }}><Icon name="list" size={46} color={T.green} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 26, fontWeight: 700, color: T.ink }}>{DEST.app}に追加中…</div>
      <div style={{ fontSize: 15, fontWeight: 600, color: T.sub }}>「{list}」に {count}件 を送信しています</div>
      <div style={{ width: 260, height: 7, borderRadius: 99, background: '#E6E2D9', overflow: 'hidden', marginTop: 16 }}><div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} /></div>
    </div>
  );
}
function DoneFull({ list, items, onOpen, onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, background: T.bg, fontFamily: T.font, padding: 40, textAlign: 'center' }}>
      <div className="sl-pop" style={{ width: 104, height: 104, borderRadius: 32, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8, boxShadow: '0 14px 30px rgba(31,122,85,0.32)' }}><Icon name="check" size={52} color="#fff" stroke={3} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 26, fontWeight: 700, color: T.ink }}>{items.length}品を追加しました</div>
      <div style={{ fontSize: 15, fontWeight: 600, color: T.sub, lineHeight: 1.7 }}>{DEST.app}の「<b style={{ color: T.greenInk }}>{list}</b>」で確認・チェックできます</div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'center', marginTop: 18, maxWidth: 440 }}>
        {items.map((it) => <span key={it.id} style={{ padding: '6px 13px', borderRadius: 999, background: '#fff', boxShadow: `inset 0 0 0 1px ${T.line}`, color: T.ink, fontSize: 13.5, fontWeight: 700 }}>{it.emoji} {it.name}</span>)}
      </div>
      <div style={{ display: 'flex', gap: 12, marginTop: 28 }}>
        <button onClick={onBack} style={{ height: 58, borderRadius: 18, padding: '0 26px', cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>在庫にもどる</button>
        <button onClick={onOpen} style={{ height: 58, borderRadius: 18, padding: '0 30px', cursor: 'pointer', border: 'none', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', gap: 9, fontFamily: T.font, fontSize: 16, fontWeight: 800, color: '#fff' }}><Icon name="open" size={20} color="#fff" /> {DEST.app}を開く</button>
      </div>
    </div>
  );
}
function ErrorFull({ onRetry, onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, background: T.bg, fontFamily: T.font, padding: 40, textAlign: 'center' }}>
      <div style={{ width: 104, height: 104, borderRadius: 32, background: T.nearSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="alert" size={46} color={T.near} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 25, fontWeight: 700, color: T.ink }}>リストに追加できませんでした</div>
      <div style={{ fontSize: 15.5, fontWeight: 500, color: T.sub, lineHeight: 1.75, maxWidth: 400 }}>時間をおいて、もう一度お試しください。解決しない場合は、リマインダーへのアクセス許可をご確認ください。</div>
      <div style={{ marginTop: 8, fontSize: 13, fontWeight: 600, color: T.faint, background: '#fff', borderRadius: 12, padding: '9px 15px' }}>選択した内容は保持されています</div>
      <div style={{ display: 'flex', gap: 12, marginTop: 26 }}>
        <button onClick={onBack} style={{ height: 58, borderRadius: 18, padding: '0 26px', cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>もどる</button>
        <button onClick={onRetry} style={{ height: 58, borderRadius: 18, padding: '0 30px', cursor: 'pointer', border: 'none', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', gap: 9, fontFamily: T.font, fontSize: 16, fontWeight: 800, color: '#fff' }}><Icon name="refresh" size={21} color="#fff" /> もう一度試す</button>
      </div>
    </div>
  );
}

window.ShoppingTablet = { SHOP_SEED, DEST, NormalPane, AddingFull, DoneFull, ErrorFull, CW, CH };
