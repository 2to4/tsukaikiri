// androidPlatform.jsx — Android platform setup
// Load AFTER shared.jsx. Sets T.statusPad, patches shopping DEST, exports tablet frame + UI helpers.
const { T } = window;
const PAGE_BG = '#E9E6E0';

// Android status bar is part of the AndroidDevice frame — no extra top padding needed
T.statusPad = 12;

// Patch shopping DEST for Google ToDo (safe even if shopping files aren't loaded yet)
function patchAndroidShopping() {
  if (window.ShoppingPhone?.DEST) {
    window.ShoppingPhone.DEST.app = 'Google ToDo';
    window.ShoppingPhone.DEST.lists = ['買い物', '食料品', '週末まとめ買い'];
  }
  if (window.ShoppingTablet?.DEST) {
    window.ShoppingTablet.DEST.app = 'Google ToDo';
    window.ShoppingTablet.DEST.lists = ['買い物', '食料品', '週末まとめ買い'];
  }
}
patchAndroidShopping();

// ── Android tablet bezel (1194×834, same canvas as iPad) ──
const AT_PAD = 14;
const AT_CW = 1194, AT_CH = 834;
const ATW = AT_CW + AT_PAD * 2, ATH = AT_CH + AT_PAD * 2;

function AndroidTabletFrame({ children }) {
  return (
    <div style={{ width: ATW, height: ATH, borderRadius: 22, background: '#252527', padding: AT_PAD,
      boxSizing: 'border-box', position: 'relative',
      boxShadow: '0 40px 80px rgba(0,0,0,0.22), 0 0 0 1px rgba(0,0,0,0.18)' }}>
      <div style={{ position: 'absolute', top: 5, left: '50%', transform: 'translateX(-50%)', width: 10, height: 10, borderRadius: 99, background: '#3A3A3C' }} />
      <div style={{ width: AT_CW, height: AT_CH, borderRadius: 12, overflow: 'hidden', background: T.bg }}>{children}</div>
    </div>
  );
}

// ── Sticky page header with state toggle ──
function AndroidPageHeader({ title, subtitle, right }) {
  return (
    <div style={{ position: 'sticky', top: 0, zIndex: 50, background: 'rgba(233,230,224,0.86)',
      backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)',
      borderBottom: '1px solid rgba(40,39,35,0.07)', padding: '16px 28px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 14 }}>
      <div>
        <div style={{ fontFamily: T.brand, fontSize: 20, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>
          つかいきり <span style={{ fontFamily: T.font, fontSize: 14, fontWeight: 600, color: T.sub }}>／ {title}</span>
        </div>
        <div style={{ fontSize: 12.5, fontWeight: 500, color: T.sub, marginTop: 3 }}>{subtitle}</div>
      </div>
      {right}
    </div>
  );
}

function AndroidSeg({ value, onChange, opts }) {
  return (
    <div style={{ display: 'inline-flex', background: '#fff', borderRadius: 12, padding: 4, gap: 2, boxShadow: 'inset 0 0 0 1px rgba(40,39,35,0.06)' }}>
      {opts.map(([v, l]) => { const on = value === v;
        return <button key={v} onClick={() => onChange(v)} style={{ border: 'none', cursor: 'pointer', padding: '8px 13px', borderRadius: 9, fontFamily: T.font, fontSize: 13.5, fontWeight: 700, background: on ? T.green : 'transparent', color: on ? '#fff' : T.sub }}>{l}</button>;
      })}
    </div>
  );
}

function useFitAndroid(w, h, padX = 80, padY = 190) {
  const [s, setS] = React.useState(1);
  React.useEffect(() => {
    const f = () => setS(Math.min(1, (window.innerWidth - padX) / w, (window.innerHeight - padY) / h));
    f(); window.addEventListener('resize', f); return () => window.removeEventListener('resize', f);
  }, [w, h, padX, padY]);
  return s;
}

window.AndroidPlatform = { AndroidTabletFrame, AndroidPageHeader, AndroidSeg, useFitAndroid, ATW, ATH, AT_CW, AT_CH, PAGE_BG };
