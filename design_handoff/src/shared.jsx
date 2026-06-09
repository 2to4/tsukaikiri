// shared.jsx — つかいきり design tokens, data + shared UI parts
// Exports to window: T, CATS, ITEMS, expiryOf, sortItems,
//   Icon, ExpiryBadge, CatTile, Chips, BottomActions, EmptyState, LoadingState

// ─────────────────────────────────────────────────────────────
// Tokens
// ─────────────────────────────────────────────────────────────
const T = {
  bg: '#F7F5F0', card: '#FFFFFF', ink: '#2A2723', sub: '#8C877C',
  faint: '#B8B2A6', line: '#EDE9E1',
  green: '#1F7A55', greenInk: '#15613F', greenSoft: '#E8F3EC',
  plenty: '#A8A296', plentySoft: '#F0EEE7',
  near: '#E0892F', nearSoft: '#FBEBD8',
  over: '#D14B3D', overSoft: '#F8E2DD',
  font: "'M PLUS Rounded 1c', system-ui, sans-serif",
  brand: "'Zen Maru Gothic', system-ui, sans-serif",
  // device content needs to clear the status bar / dynamic island
  statusPad: 56,
};

const CATS = {
  '肉':   { tile: '#F3E1DB' },
  '魚':   { tile: '#E1EAF1' },
  '野菜': { tile: '#E6F0E1' },
  '乳製品': { tile: '#F4ECD9' },
  '調味料': { tile: '#EFE6D5' },
  '常備品': { tile: '#EAE7DF' },
};
const CAT_ORDER = ['肉', '魚', '野菜', '乳製品', '調味料', '常備品'];

// remaining-days drives the colour state. sorted soonest-first.
const ITEMS = [
  { id: 'a', name: '鶏むね肉',   emoji: '🍗', qty: '2', unit: '枚',     cat: '肉',   days: -1 },
  { id: 'b', name: '牛乳',       emoji: '🥛', qty: '1', unit: '本',     cat: '乳製品', days: 1 },
  { id: 'c', name: 'ほうれん草', emoji: '🥬', qty: '1', unit: '袋',     cat: '野菜', days: 2 },
  { id: 'd', name: '生鮭',       emoji: '🐟', qty: '2', unit: '切れ',   cat: '魚',   days: 2 },
  { id: 'e', name: 'ミニトマト', emoji: '🍅', qty: '8', unit: '個',     cat: '野菜', days: 3 },
  { id: 'f', name: '卵',         emoji: '🥚', qty: '6', unit: '個',     cat: '常備品', days: 5 },
  { id: 'g', name: 'にんじん',   emoji: '🥕', qty: '3', unit: '本',     cat: '野菜', days: 8 },
  { id: 'h', name: 'バター',     emoji: '🧈', qty: '1', unit: '箱',     cat: '乳製品', days: 18 },
  { id: 'i', name: '味噌',       emoji: '🫙', qty: '1', unit: 'パック', cat: '調味料', days: 34 },
];

function expiryOf(days) {
  if (days < 0)  return { status: 'over',   label: '期限切れ', short: `${-days}日`, note: `${-days}日超過`, color: T.over,   soft: T.overSoft };
  if (days <= 3) return { status: 'near',   label: days === 0 ? '今日まで' : `あと${days}日`, short: days === 0 ? '今日' : `${days}日`, note: days === 0 ? '今日まで' : `あと${days}日`, color: T.near, soft: T.nearSoft };
  return            { status: 'plenty', label: `あと${days}日`, short: `${days}日`, note: `あと${days}日`, color: T.plenty, soft: T.plentySoft };
}

const sortItems = (arr) => [...arr].sort((x, y) => x.days - y.days);

// ─────────────────────────────────────────────────────────────
// Minimal geometric line icons
// ─────────────────────────────────────────────────────────────
function Icon({ name, size = 22, color = T.ink, stroke = 2 }) {
  const p = { fill: 'none', stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    camera: <g {...p}><path d="M3 8.5a2 2 0 0 1 2-2h2l1.3-2h7.4L19 6.5h2a2 2 0 0 1 2 2V18a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" transform="translate(-1,-0.5)"/><circle cx="11" cy="12.5" r="3.6"/></g>,
    plus: <g {...p}><path d="M12 5v14M5 12h14"/></g>,
    chevron: <g {...p}><path d="M9 6l6 6-6 6"/></g>,
    spark: <g {...p}><path d="M12 4l1.8 4.7L18.5 10l-4.7 1.8L12 16l-1.8-4.2L5.5 10l4.7-1.3z"/></g>,
    filter: <g {...p}><path d="M4 6h16M7 12h10M10 18h4"/></g>,
    search: <g {...p}><circle cx="11" cy="11" r="6"/><path d="M20 20l-4-4"/></g>,
    leaf: <g {...p}><path d="M5 19c0-7 5-12 14-12 0 9-5 14-12 14a8 8 0 0 1-2-2z"/><path d="M9 15c2-3 4-4 7-5"/></g>,
    box: <g {...p}><path d="M4 8l8-4 8 4v8l-8 4-8-4z"/><path d="M4 8l8 4 8-4M12 12v8"/></g>,
    minus: <g {...p}><path d="M5 12h14"/></g>,
    check: <g {...p}><path d="M5 12.5l4.5 4.5L19 7"/></g>,
    trash: <g {...p}><path d="M5 7h14M10 7V5h4v2M6 7l1 13h10l1-13"/></g>,
    edit: <g {...p}><path d="M5 19h14M14 5l4 4-9 9H5v-4z"/></g>,
    bag: <g {...p}><path d="M6 8h12l-1 12H7zM9 8a3 3 0 0 1 6 0"/></g>,
    book: <g {...p}><path d="M5 5h10a3 3 0 0 1 3 3v11H8a3 3 0 0 0-3 3z" transform="translate(0,-1)"/><path d="M5 4v16"/></g>,
    close: <g {...p}><path d="M6 6l12 12M18 6L6 18"/></g>,
    image: <g {...p}><rect x="3.5" y="5.5" width="17" height="13" rx="2.5"/><circle cx="9" cy="10" r="1.6"/><path d="M5 17l4.5-4 3 2.5L16 12l3 3.5"/></g>,
    wifi: <g {...p}><path d="M2.5 9.5a14 14 0 0 1 19 0M5.5 13a9 9 0 0 1 13 0M8.5 16.3a4.5 4.5 0 0 1 7 0"/><circle cx="12" cy="19.5" r="0.6" fill={color} stroke="none"/></g>,
    refresh: <g {...p}><path d="M4 12a8 8 0 0 1 14-5.3L20 8M20 4v4h-4M20 12a8 8 0 0 1-14 5.3L4 16M4 20v-4h4"/></g>,
    sliders: <g {...p}><path d="M5 8h14M5 16h14"/><circle cx="9" cy="8" r="2.2"/><circle cx="15" cy="16" r="2.2"/></g>,
    clock: <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/></g>,
    pot: <g {...p}><path d="M4 10h16v5a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3z"/><path d="M3 10h18M7.5 10V7.5M16.5 10V7.5"/><path d="M9 6.2c0-1 1.2-1 1.2-2M14 6.2c0-1 1.2-1 1.2-2" /></g>,
    oven: <g {...p}><rect x="4" y="4.5" width="16" height="15" rx="2.5"/><path d="M4 9h16M7 6.6h0.01M10 6.6h0.01"/><rect x="7" y="11.5" width="10" height="5.5" rx="1.5"/></g>,
    flame: <g {...p}><path d="M12 3c3 3.5 5 6 5 9a5 5 0 0 1-10 0c0-1.4.6-2.6 1.5-3.7C9 9.8 9.5 11 11 11.4 10 9 11 5.5 12 3z"/></g>,
    people: <g {...p}><circle cx="12" cy="8" r="3.2"/><path d="M5.5 19c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6"/></g>,
    list: <g {...p}><path d="M9 7h11M9 12h11M9 17h11"/><circle cx="4.5" cy="7" r="1.3" fill={color} stroke="none"/><circle cx="4.5" cy="12" r="1.3" fill={color} stroke="none"/><circle cx="4.5" cy="17" r="1.3" fill={color} stroke="none"/></g>,
    open: <g {...p}><path d="M14 4h6v6M19.5 4.5L11 13M18 14v4a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4"/></g>,
    alert: <g {...p}><path d="M12 4.5l8.6 14.8a1 1 0 0 1-.86 1.5H4.26a1 1 0 0 1-.86-1.5z"/><path d="M12 10v4.2"/><circle cx="12" cy="17.2" r="0.5" fill={color} stroke={color}/></g>,
    globe: <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17M12 3.5c2.5 2.4 2.5 14.6 0 17M12 3.5c-2.5 2.4-2.5 14.6 0 17"/></g>,
    key: <g {...p}><circle cx="8" cy="12" r="3.6"/><path d="M11.4 12.4H20l-1.6 1.6M16.4 12.4v3"/></g>,
    cloud: <g {...p}><path d="M7 18a4 4 0 0 1-.3-8A5.2 5.2 0 0 1 17 10.2 3.9 3.9 0 0 1 16.7 18z"/></g>,
    coffee: <g {...p}><path d="M4 8h13v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4z"/><path d="M17 9h1.6a2.4 2.4 0 0 1 0 4.8H17"/><path d="M7.5 3.4c-.5.6-.5 1.2 0 1.8M11 3.4c-.5.6-.5 1.2 0 1.8"/></g>,
    help: <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M9.6 9.6a2.4 2.4 0 0 1 4.6.9c0 1.6-2.2 2-2.2 3.3"/><circle cx="12" cy="17" r="0.5" fill={color} stroke={color}/></g>,
    info: <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M12 11v5.2"/><circle cx="12" cy="7.8" r="0.5" fill={color} stroke={color}/></g>,
    heart: <g {...p}><path d="M12 20s-7-4.3-7-9.2A3.8 3.8 0 0 1 12 8a3.8 3.8 0 0 1 7 2.8C19 15.7 12 20 12 20z"/></g>,
    doc: <g {...p}><path d="M7 3h7l5 5v13H7z" transform="translate(-1,0)"/><path d="M13 3v5h5"/><path d="M8.5 13h6M8.5 16.5h6"/></g>,
    shield: <g {...p}><path d="M12 3l7 2.5v5c0 4.5-3 8-7 9.5-4-1.5-7-5-7-9.5v-5z"/><path d="M9 12l2 2 4-4"/></g>,
    database: <g {...p}><ellipse cx="12" cy="6" rx="7" ry="2.6"/><path d="M5 6v6c0 1.4 3.1 2.6 7 2.6s7-1.2 7-2.6V6"/><path d="M5 12v6c0 1.4 3.1 2.6 7 2.6s7-1.2 7-2.6v-6"/></g>,
  };
  return <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block' }}>{paths[name]}</svg>;
}

// ─────────────────────────────────────────────────────────────
// Expiry badge — number + colour dot
// ─────────────────────────────────────────────────────────────
function ExpiryBadge({ days, size = 'md' }) {
  const e = expiryOf(days);
  const big = size === 'lg';
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: big ? '6px 11px' : '5px 9px', borderRadius: 999,
      background: e.soft, whiteSpace: 'nowrap',
    }}>
      <span style={{ width: 7, height: 7, borderRadius: 99, background: e.color, flexShrink: 0 }} />
      <span style={{ fontSize: big ? 14 : 12.5, fontWeight: 700, color: e.color, letterSpacing: 0.2 }}>{e.label}</span>
    </div>
  );
}

// category-tinted rounded tile holding the food emoji
function CatTile({ item, size = 52 }) {
  const c = CATS[item.cat] || { tile: '#EEE' };
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.32, background: c.tile,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontSize: size * 0.5, flexShrink: 0,
    }}>{item.emoji}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Category filter chips (horizontal scroll)
// ─────────────────────────────────────────────────────────────
function Chips({ active, onPick }) {
  const list = ['すべて', ...CAT_ORDER];
  return (
    <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '2px 16px 2px', WebkitOverflowScrolling: 'touch', scrollbarWidth: 'none' }}>
      {list.map((c) => {
        const on = active === c;
        return (
          <button key={c} onClick={() => onPick && onPick(c)} style={{
            flexShrink: 0, border: 'none', cursor: 'pointer',
            padding: '8px 15px', borderRadius: 999,
            fontFamily: T.font, fontSize: 14, fontWeight: on ? 700 : 600,
            background: on ? T.green : '#fff',
            color: on ? '#fff' : T.sub,
            boxShadow: on ? 'none' : `inset 0 0 0 1px ${T.line}`,
            transition: 'all .15s',
          }}>{c}</button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Bottom actions — big 献立提案 bar + camera FAB
// ─────────────────────────────────────────────────────────────
function BottomActions({ disabled = false }) {
  return (
    <div style={{
      position: 'sticky', bottom: 0, zIndex: 30,
      padding: '20px 16px 26px',
      background: `linear-gradient(to top, ${T.bg} 64%, ${T.bg}EE 82%, transparent)`,
      pointerEvents: 'none',
    }}>
      {/* camera FAB — floats above the bar, distinct treatment */}
      <button title="カメラで登録" style={{
        pointerEvents: 'auto', position: 'absolute', right: 18, top: -34,
        width: 60, height: 60, borderRadius: 20, cursor: 'pointer',
        background: '#fff', border: `1.5px solid ${T.greenSoft}`,
        boxShadow: '0 10px 24px rgba(31,122,85,0.20), 0 2px 6px rgba(0,0,0,0.08)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon name="camera" size={27} color={T.green} stroke={2} />
      </button>
      {/* primary 献立提案 bar */}
      <button disabled={disabled} style={{
        pointerEvents: 'auto', width: '100%', border: 'none', cursor: disabled ? 'default' : 'pointer',
        height: 64, borderRadius: 20, padding: '0 22px',
        background: disabled ? '#D8D4CB' : T.green,
        boxShadow: disabled ? 'none' : '0 12px 26px rgba(31,122,85,0.30)',
        display: 'flex', alignItems: 'center', gap: 12, textAlign: 'left',
        fontFamily: T.font,
      }}>
        <Icon name="spark" size={24} color="#fff" stroke={2} />
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 17, fontWeight: 800, color: '#fff', lineHeight: 1.2 }}>献立を提案</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: 'rgba(255,255,255,0.82)', marginTop: 1 }}>使い切りメニューを見る</div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 30, height: 30, borderRadius: 99, background: 'rgba(255,255,255,0.18)' }}>
          <Icon name="chevron" size={18} color="#fff" stroke={2.4} />
        </div>
      </button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────
function EmptyState() {
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', padding: '0 24px' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 6 }}>
        <div style={{
          width: 104, height: 104, borderRadius: 32, background: T.greenSoft,
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 46, marginBottom: 10,
        }}>🧺</div>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>在庫はまだ空っぽ</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.7, maxWidth: 248 }}>
          食材を登録すると、賞味期限の近いものから<br />使い切りメニューを提案します。
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, paddingBottom: 34 }}>
        <button style={{
          width: '100%', height: 60, borderRadius: 20, border: 'none', cursor: 'pointer',
          background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff',
        }}>
          <Icon name="camera" size={23} color="#fff" /> カメラで登録
        </button>
        <button style={{
          width: '100%', height: 54, borderRadius: 18, cursor: 'pointer',
          background: '#fff', border: `1.5px solid ${T.line}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink,
        }}>
          <Icon name="plus" size={20} color={T.ink} /> 手動で追加
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Loading skeleton — layout: 'list' | 'grid'
// ─────────────────────────────────────────────────────────────
function Skel({ w, h, r = 8, style = {} }) {
  return <div className="tk-shimmer" style={{ width: w, height: h, borderRadius: r, ...style }} />;
}
function LoadingState({ layout = 'list', chips = true }) {
  return (
    <div style={{ padding: '4px 16px' }}>
      {chips && (
        <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
          {[60, 44, 44, 52].map((w, i) => <Skel key={i} w={w} h={34} r={999} />)}
        </div>
      )}
      {layout === 'grid' ? (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} style={{ background: '#fff', borderRadius: 18, padding: 14, display: 'flex', flexDirection: 'column', gap: 10 }}>
              <Skel w={46} h={46} r={14} />
              <Skel w={'70%'} h={14} />
              <Skel w={'45%'} h={11} />
            </div>
          ))}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} style={{ background: '#fff', borderRadius: 18, padding: 14, display: 'flex', alignItems: 'center', gap: 14 }}>
              <Skel w={52} h={52} r={16} />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
                <Skel w={'55%'} h={14} />
                <Skel w={'35%'} h={11} />
              </div>
              <Skel w={58} h={26} r={999} />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

Object.assign(window, {
  T, CATS, CAT_ORDER, ITEMS, expiryOf, sortItems,
  Icon, ExpiryBadge, CatTile, Chips, BottomActions, EmptyState, LoadingState, Skel,
});
