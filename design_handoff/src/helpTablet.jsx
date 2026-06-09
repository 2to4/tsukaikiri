// helpTablet.jsx — ヘルプ / このアプリについて タブレット（左=目次 / 右=本文）
const { T, Icon } = window;
const { HelpBody } = window.HelpAbout;
const CW = 1194, CH = 834;

const TOC = [
  { k: 'top',     icon: 'info',   label: 'このアプリについて' },
  { k: 'guide',   icon: 'help',   label: 'かんたんな使い方' },
  { k: 'data',    icon: 'database', label: '賞味期限データについて' },
  { k: 'source',  icon: 'open',   label: '出典・参考データ' },
  { k: 'edit',    icon: 'edit',   label: '賞味期限の手動修正' },
  { k: 'legal',   icon: 'shield', label: '規約・プライバシー' },
];

function HelpTablet() {
  const [active, setActive] = React.useState('top');
  const scRef = React.useRef(null);

  const jump = (k) => {
    setActive(k);
    const root = scRef.current; if (!root) return;
    const el = root.querySelector(`[data-help-sec="${k}"]`);
    if (el) root.scrollTo({ top: Math.max(0, el.offsetTop - 24), behavior: 'smooth' });
  };
  const onScroll = () => {
    const root = scRef.current; if (!root) return;
    const secs = [...root.querySelectorAll('[data-help-sec]')];
    const y = root.scrollTop + 80;
    let cur = secs[0]?.getAttribute('data-help-sec');
    for (const s of secs) { if (s.offsetTop <= y) cur = s.getAttribute('data-help-sec'); }
    if (cur) setActive(cur);
  };

  return (
    <div style={{ height: '100%', display: 'flex', fontFamily: T.font }}>
      {/* left TOC */}
      <div style={{ width: 348, flexShrink: 0, borderRight: `1px solid ${T.line}`, background: '#FBFAF7', display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '34px 24px 16px' }}>
          <div style={{ fontFamily: T.brand, fontSize: 24, fontWeight: 700, color: T.ink, lineHeight: 1.3 }}>ヘルプ /<br />このアプリについて</div>
        </div>
        <div style={{ flex: 1, overflow: 'auto', padding: '4px 14px' }}>
          {TOC.map((t) => { const on = active === t.k;
            return (
              <button key={t.k} onClick={() => jump(t.k)} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', borderRadius: 13, marginBottom: 3, background: on ? T.greenSoft : 'transparent', textAlign: 'left' }}>
                <div style={{ width: 34, height: 34, borderRadius: 10, background: on ? '#fff' : '#F1EEE7', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={t.icon} size={18} color={on ? T.green : T.sub} stroke={2} /></div>
                <span style={{ flex: 1, fontSize: 14.5, fontWeight: on ? 800 : 700, color: on ? T.greenInk : T.ink }}>{t.label}</span>
              </button>
            );
          })}
        </div>
        <div style={{ padding: '12px 24px 18px', fontSize: 11, fontWeight: 600, color: T.faint }}>つかいきり ・ v1.0.0 (128)</div>
      </div>
      {/* right body */}
      <div ref={scRef} onScroll={onScroll} style={{ flex: 1, overflow: 'auto', background: T.bg }}>
        <div style={{ maxWidth: 680, margin: '0 auto' }}>
          <HelpBody pad="8px 48px 56px" anchored />
        </div>
      </div>
    </div>
  );
}

window.HelpTablet = { HelpTablet, TOC, CW, CH };
