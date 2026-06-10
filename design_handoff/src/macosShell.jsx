// macosShell.jsx — つかいきり macOS shell: sidebar, toolbar, window, utilities
const { T, Icon } = window;
const { MacGlass, MacTrafficLights } = window;
const MFONT = '-apple-system,BlinkMacSystemFont,"SF Pro Text",Helvetica,sans-serif';

function useHover() {
  const [h, setH] = React.useState(false);
  return [h, { onMouseEnter: () => setH(true), onMouseLeave: () => setH(false) }];
}

function Kbd({ k }) {
  return <span style={{ fontSize: 10, fontWeight: 700, color: T.faint, fontFamily: MFONT, background: 'rgba(40,39,35,0.09)', padding: '2px 5px', borderRadius: 4, marginLeft: 2, letterSpacing: '-0.1px' }}>{k}</span>;
}

function TBtn({ icon, label, kbd, primary, onClick, disabled, sm }) {
  const [h, hP] = useHover();
  const pad = sm ? '4px 9px' : '5px 12px';
  return (
    <button onClick={onClick} disabled={disabled} {...hP} style={{
      display: 'flex', alignItems: 'center', gap: 5, padding: pad, borderRadius: 7,
      border: `1px solid ${primary ? 'transparent' : T.line}`, cursor: disabled ? 'default' : 'pointer',
      fontFamily: T.font, fontSize: sm ? 12 : 12.5, fontWeight: 700,
      background: disabled ? 'rgba(40,39,35,0.04)' : primary ? T.green : h ? '#fff' : 'rgba(255,255,255,0.82)',
      color: disabled ? T.faint : primary ? '#fff' : T.ink, opacity: disabled ? 0.55 : 1,
      boxShadow: primary && !disabled ? '0 2px 8px rgba(31,122,85,0.22)' : '0 1px 2px rgba(0,0,0,0.05)',
      transition: 'background 0.09s', whiteSpace: 'nowrap',
    }}>
      {icon && <Icon name={icon} size={sm ? 11 : 12} color={disabled ? T.faint : primary ? '#fff' : T.sub} stroke={2.2} />}
      {label}{kbd && <Kbd k={kbd} />}
    </button>
  );
}

function VDiv() { return <div style={{ width: 1, height: 18, background: T.line, flexShrink: 0 }} />; }

function MacBar({ children, title }) {
  return (
    <div style={{
      height: 50, display: 'flex', alignItems: 'center', gap: 8, padding: '0 14px',
      borderBottom: `1px solid ${T.line}`, background: 'rgba(247,245,240,0.94)',
      backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)', flexShrink: 0,
    }}>
      {title && <div style={{ fontFamily: T.brand, fontSize: 15, fontWeight: 700, color: T.ink, marginRight: 2 }}>{title}</div>}
      {children}
    </div>
  );
}

function MacSearch({ placeholder = '検索', value, onChange }) {
  const [f, setF] = React.useState(false);
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 6, padding: '0 9px', height: 30, borderRadius: 7,
      background: f ? '#fff' : 'rgba(255,255,255,0.7)', border: `1px solid ${f ? T.green : T.line}`,
      transition: 'all 0.14s', minWidth: 150,
    }}>
      <Icon name="search" size={12} color={T.faint} stroke={2} />
      <input value={value} onChange={e => onChange && onChange(e.target.value)}
        onFocus={() => setF(true)} onBlur={() => setF(false)}
        placeholder={placeholder}
        style={{ border: 'none', background: 'transparent', fontSize: 12.5, fontFamily: T.font, color: T.ink, outline: 'none', width: '100%', fontWeight: 600 }} />
    </div>
  );
}

function MacNavItem({ item, selected, onClick }) {
  const [h, hP] = useHover();
  return (
    <button onClick={onClick} {...hP} style={{
      width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8,
      padding: '6px 8px', borderRadius: 8, fontFamily: T.font, textAlign: 'left',
      background: selected ? T.greenSoft : h ? 'rgba(40,39,35,0.05)' : 'transparent', transition: 'background 0.08s',
    }}>
      <span style={{
        width: 26, height: 26, borderRadius: 7, display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0, background: selected ? T.green : 'rgba(40,39,35,0.08)',
      }}>
        <Icon name={item.icon} size={13} color={selected ? '#fff' : T.sub} stroke={2} />
      </span>
      <span style={{ flex: 1, fontSize: 12.5, fontWeight: selected ? 700 : 600, color: selected ? T.greenInk : T.ink }}>{item.label}</span>
      {item.kb && <span style={{ fontSize: 10, color: T.faint, fontFamily: MFONT }}>{item.kb}</span>}
    </button>
  );
}

const MAC_NAVS = [
  { k: 'inventory', icon: 'book',   label: '在庫',         kb: '⌘1' },
  { k: 'camera',    icon: 'camera', label: 'カメラ登録',   kb: '⌘2' },
  { k: 'meals',     icon: 'spark',  label: '献立提案',     kb: '⌘3' },
  { k: 'shopping',  icon: 'list',   label: '買い物リスト', kb: '⌘4' },
];
const MAC_NAVS2 = [
  { k: 'onboarding', icon: 'people', label: '設定アシスタント', kb: '' },
  { k: 'settings',   icon: 'key',    label: '設定',           kb: '⌘,' },
  { k: 'help',       icon: 'help',   label: 'ヘルプ',         kb: '' },
];

function AppSidebar({ nav, setNav, count }) {
  return (
    <div style={{
      width: 216, flexShrink: 0, height: '100%',
      background: 'rgba(238,234,226,0.82)',
      backdropFilter: 'blur(50px) saturate(200%)', WebkitBackdropFilter: 'blur(50px) saturate(200%)',
      borderRight: `1px solid rgba(255,255,255,0.5)`,
      display: 'flex', flexDirection: 'column',
    }}>
      <div style={{ padding: '17px 14px 6px' }}><MacTrafficLights /></div>
      <div style={{ padding: '4px 12px 14px', display: 'flex', alignItems: 'center', gap: 9 }}>
        <div style={{ width: 34, height: 34, borderRadius: 10, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, boxShadow: '0 3px 10px rgba(31,122,85,0.28)' }}>
          <span style={{ fontSize: 18 }}>🌿</span>
        </div>
        <div>
          <div style={{ fontFamily: T.brand, fontSize: 14, fontWeight: 700, color: T.ink, lineHeight: 1.2 }}>つかいきり</div>
          <div style={{ fontSize: 10.5, color: T.sub, fontFamily: T.font, fontWeight: 600 }}>{count}品の食材</div>
        </div>
      </div>
      <div style={{ flex: 1, padding: '0 6px', overflow: 'auto' }}>
        <div style={{ fontSize: 9.5, fontWeight: 800, color: T.faint, fontFamily: T.font, padding: '4px 8px 2px', letterSpacing: '0.08em' }}>メイン</div>
        {MAC_NAVS.map(n => <MacNavItem key={n.k} item={n} selected={nav === n.k} onClick={() => setNav(n.k)} />)}
        <div style={{ fontSize: 9.5, fontWeight: 800, color: T.faint, fontFamily: T.font, padding: '12px 8px 2px', letterSpacing: '0.08em' }}>その他</div>
        {MAC_NAVS2.map(n => <MacNavItem key={n.k} item={n} selected={nav === n.k} onClick={() => setNav(n.k)} />)}
      </div>
      <div style={{ padding: '8px 12px 14px', borderTop: `1px solid rgba(40,39,35,0.07)` }}>
        <div style={{ fontSize: 10, fontWeight: 600, color: T.faint, fontFamily: T.font }}>最終更新: 今日 9:41</div>
      </div>
    </div>
  );
}

function MacAppWindow({ nav, setNav, count, toolbar, children }) {
  return (
    <div style={{
      width: 1280, height: 800, borderRadius: 14, overflow: 'hidden', background: T.bg,
      boxShadow: '0 0 0 0.5px rgba(0,0,0,0.28), 0 30px 90px rgba(0,0,0,0.5), 0 10px 30px rgba(0,0,0,0.18)',
      display: 'flex', fontFamily: T.font,
    }}>
      <AppSidebar nav={nav} setNav={setNav} count={count} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
        {toolbar}
        <div style={{ flex: 1, overflow: 'hidden' }}>{children}</div>
      </div>
    </div>
  );
}

function useFitMac() {
  const [s, setS] = React.useState(1);
  React.useEffect(() => {
    const f = () => setS(Math.min(1, (window.innerWidth - 40) / 1280, (window.innerHeight - 120) / 800));
    f(); window.addEventListener('resize', f); return () => window.removeEventListener('resize', f);
  }, []);
  return s;
}

window.MacShell = { useHover, Kbd, TBtn, MacBar, VDiv, MacSearch, MacAppWindow, useFitMac, MFONT };
