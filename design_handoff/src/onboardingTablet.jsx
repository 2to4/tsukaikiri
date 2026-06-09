// onboardingTablet.jsx — 初回オンボーディング タブレット（左レール / 右コンテンツ）
const { T, Icon } = window;
const CW = 1194, CH = 834;

const STEPS = [
  { k: 'welcome', label: 'ようこそ' },
  { k: 'ai',      label: 'AIを選ぶ' },
  { k: 'link',    label: '買い物リスト連携' },
  { k: 'list',    label: 'リストの選択' },
  { k: 'appliance', label: '調理家電' },
  { k: 'done',    label: '完了' },
];
const OB_AI_T = [
  { k: 'claude', name: 'Claude', sub: 'Anthropic', vision: true,  tile: '#EFE6D5', fg: '#9A5B2A', ph: 'sk-ant-...', url: 'console.anthropic.com/settings/keys' },
  { k: 'openai', name: 'OpenAI', sub: 'GPT-4o',    vision: true,  tile: '#E0EDE6', fg: '#2C7A56', ph: 'sk-...',     url: 'platform.openai.com/api-keys' },
  { k: 'gemini', name: 'Gemini', sub: 'Google',    vision: true,  tile: '#E1EAF1', fg: '#3A6491', ph: 'AIza...',    url: 'aistudio.google.com/app/apikey' },
  { k: 'grok',   name: 'Grok',   sub: 'xAI',       vision: false, tile: '#EAE7DF', fg: '#55514A', ph: 'xai-...',    url: 'console.x.ai' },
];

// ── left rail ──
function Rail({ i }) {
  return (
    <div style={{ width: 396, flexShrink: 0, background: T.green, color: '#fff', display: 'flex', flexDirection: 'column', padding: '46px 38px', position: 'relative', overflow: 'hidden' }}>
      <div style={{ position: 'absolute', right: -70, top: -60, width: 240, height: 240, borderRadius: 99, background: 'rgba(255,255,255,0.06)' }} />
      <div style={{ position: 'absolute', right: -30, bottom: -80, width: 200, height: 200, borderRadius: 99, background: 'rgba(255,255,255,0.05)' }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 52, height: 52, borderRadius: 16, background: 'rgba(255,255,255,0.16)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28 }}>🥗</div>
        <div style={{ fontFamily: T.brand, fontSize: 24, fontWeight: 700, letterSpacing: 1 }}>つかいきり</div>
      </div>
      <div style={{ fontSize: 14, fontWeight: 600, color: 'rgba(255,255,255,0.82)', marginTop: 14, lineHeight: 1.7 }}>はじめの設定をすませましょう。<br />あとから変更できます。</div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 4 }}>
        {STEPS.map((s, idx) => {
          const done = idx < i, cur = idx === i;
          return (
            <div key={s.k} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '13px 0', opacity: done || cur ? 1 : 0.5 }}>
              <span style={{ width: 32, height: 32, borderRadius: 99, flexShrink: 0, background: done ? '#fff' : (cur ? 'rgba(255,255,255,0.22)' : 'transparent'), border: done ? 'none' : `2px solid rgba(255,255,255,${cur ? 0.9 : 0.4})`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14, fontWeight: 800, color: done ? T.green : '#fff' }}>
                {done ? <Icon name="check" size={16} color={T.green} stroke={3} /> : idx + 1}
              </span>
              <span style={{ fontSize: 15.5, fontWeight: cur ? 800 : 600 }}>{s.label}</span>
            </div>
          );
        })}
      </div>
      <div style={{ fontSize: 12.5, fontWeight: 600, color: 'rgba(255,255,255,0.7)' }}>ステップ {Math.min(i + 1, 6)} / 6</div>
    </div>
  );
}

// content frame: title area + scroll + footer
function Content({ title, sub, skip, onSkip, primary, onPrimary, onBack, children, maxW = 560 }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: T.bg }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '52px 56px 20px' }}>
        <div style={{ maxWidth: maxW, margin: '0 auto' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16 }}>
            <div>
              <div style={{ fontFamily: T.brand, fontSize: 30, fontWeight: 700, color: T.ink, lineHeight: 1.25 }}>{title}</div>
              {sub && <div style={{ fontSize: 15, fontWeight: 500, color: T.sub, lineHeight: 1.7, marginTop: 10, maxWidth: 460 }}>{sub}</div>}
            </div>
            {skip && <button onClick={onSkip} style={{ flexShrink: 0, background: 'none', border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 14, fontWeight: 700, color: T.sub, marginTop: 6 }}>{skip}</button>}
          </div>
          <div style={{ marginTop: 28 }}>{children}</div>
        </div>
      </div>
      <div style={{ flexShrink: 0, borderTop: `1px solid ${T.line}`, padding: '18px 56px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} disabled={!onBack} style={{ height: 52, borderRadius: 16, padding: '0 22px', cursor: onBack ? 'pointer' : 'default', background: onBack ? '#fff' : 'transparent', border: onBack ? `1.5px solid ${T.line}` : '1.5px solid transparent', fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.ink, opacity: onBack ? 1 : 0, display: 'flex', alignItems: 'center', gap: 7 }}>
          <span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={17} color={T.ink} /></span> もどる
        </button>
        <button onClick={onPrimary} style={{ height: 56, borderRadius: 16, padding: '0 38px', cursor: 'pointer', border: 'none', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', gap: 9, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>{primary}</button>
      </div>
    </div>
  );
}

// ── 1 welcome ──
function WelcomeT({ onNext }) {
  return (
    <Content title="つかいきりへ、ようこそ" sub="冷蔵庫にある食材から献立を提案。「使い切る」毎日を、かんたんに。" primary={<>はじめる <span style={{ display: 'flex' }}><Icon name="chevron" size={19} color="#fff" stroke={2.4} /></span></>} onPrimary={onNext} maxW={640}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 14 }}>
        {[['camera', '撮るだけ在庫登録', 'カメラでまとめて食材を登録'], ['spark', '使い切り献立', '期限が近い食材から提案'], ['bag', '買い物リスト連携', '足りない食材を自動で追加']].map(([ic, t, s]) => (
          <div key={t} style={{ background: '#fff', borderRadius: 18, padding: '20px 18px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
            <div style={{ width: 50, height: 50, borderRadius: 15, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}><Icon name={ic} size={25} color={T.green} /></div>
            <div style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>{t}</div>
            <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 4, lineHeight: 1.6 }}>{s}</div>
          </div>
        ))}
      </div>
      <div style={{ textAlign: 'center', fontSize: 13, fontWeight: 600, color: T.faint, marginTop: 22 }}>設定はあとからいつでも変更できます</div>
    </Content>
  );
}

// ── 2 AI ──
function AIT({ onNext, onBack, onSkip }) {
  const [sel, setSel] = React.useState('claude');
  const [key, setKey] = React.useState('');
  const p = OB_AI_T.find((x) => x.k === sel);
  return (
    <Content title="AIを選ぶ" sub="食材の認識と献立提案に使うAIを選びます。お持ちのAPIキーを使います。あとで変更できます。" skip="あとで" onSkip={onSkip} primary="次へ" onPrimary={onNext} onBack={onBack} maxW={640}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 11 }}>
        {OB_AI_T.map((o) => {
          const on = sel === o.k;
          return (
            <button key={o.k} onClick={() => setSel(o.k)} style={{ border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '14px 15px', borderRadius: 16, background: on ? T.greenSoft : '#fff', boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)' }}>
              <div style={{ width: 42, height: 42, borderRadius: 12, background: o.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 800, color: o.fg, flexShrink: 0 }}>{o.name[0]}</div>
              <div style={{ flex: 1, minWidth: 0, textAlign: 'left' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 7, flexWrap: 'wrap' }}>
                  <span style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>{o.name}</span>
                  <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, padding: '2px 7px', borderRadius: 999, background: o.vision ? T.greenSoft : '#F0EEE7' }}>
                    <span style={{ width: 5, height: 5, borderRadius: 99, background: o.vision ? T.green : T.faint }} />
                    <span style={{ fontSize: 10.5, fontWeight: 700, color: o.vision ? T.greenInk : T.faint }}>{o.vision ? 'Vision対応' : 'Vision非対応'}</span>
                  </span>
                </div>
                <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 2 }}>{o.sub}</div>
              </div>
              <span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>
            </button>
          );
        })}
      </div>
      <div style={{ fontSize: 12.5, fontWeight: 700, color: T.faint, margin: '20px 2px 9px' }}>{p.name} のAPIキー</div>
      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8, background: '#fff', borderRadius: 14, padding: '4px 6px 4px 14px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          <input value={key} onChange={(e) => setKey(e.target.value)} placeholder={p.ph} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', padding: '12px 0', fontFamily: 'ui-monospace, monospace', fontSize: 14, fontWeight: 600, color: T.ink }} />
        </div>
        <button style={{ flexShrink: 0, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 10, padding: '0 16px', borderRadius: 14, background: '#fff', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          <div style={{ width: 30, height: 30, borderRadius: 9, background: p.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="key" size={16} color={p.fg} stroke={2} /></div>
          <div style={{ textAlign: 'left' }}>
            <div style={{ fontSize: 13, fontWeight: 800, color: T.greenInk }}>APIキーを取得</div>
            <div style={{ fontSize: 10.5, fontWeight: 600, color: T.faint, marginTop: 1 }}>{p.url}</div>
          </div>
          <Icon name="open" size={15} color={T.sub} />
        </button>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 11, padding: '0 2px' }}>
        <span style={{ width: 7, height: 7, borderRadius: 99, background: key ? T.green : T.near }} />
        <span style={{ fontSize: 12, fontWeight: 700, color: key ? T.greenInk : T.sub }}>{key ? 'キーが入力されました' : 'あとで設定でも登録できます'}</span>
      </div>
    </Content>
  );
}

// ── 3 link ──
function LinkT({ onNext, onBack, onSkip }) {
  const [connected, setConnected] = React.useState(false);
  return (
    <Content title="買い物リストと連携" sub="足りない食材を、お使いのリマインダーに自動で追加します。許可すると連携できます。" skip="あとで" onSkip={onSkip} primary="次へ" onPrimary={onNext} onBack={onBack}>
      <div style={{ display: 'flex', gap: 20, alignItems: 'stretch' }}>
        <div style={{ flex: 1, background: '#fff', borderRadius: 18, padding: '8px 20px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          {[['アプリ', 'リマインダー（iOS）'], ['できること', '買い物リストへの項目追加'], ['プライバシー', '在庫の写真は端末内で処理']].map(([k, v], i) => (
            <div key={k} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 0', borderBottom: i < 2 ? `1px solid ${T.line}` : 'none' }}>
              <span style={{ fontSize: 14, fontWeight: 600, color: T.sub }}>{k}</span>
              <span style={{ fontSize: 14.5, fontWeight: 700, color: T.ink }}>{v}</span>
            </div>
          ))}
        </div>
        <div style={{ width: 240, flexShrink: 0, background: connected ? T.greenSoft : '#fff', borderRadius: 18, padding: 22, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 12, boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          <div style={{ width: 72, height: 72, borderRadius: 22, background: connected ? '#fff' : T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={connected ? 'check' : 'list'} size={34} color={T.green} stroke={connected ? 3 : 2} /></div>
          {connected ? <div style={{ fontSize: 15, fontWeight: 800, color: T.greenInk }}>連携しました</div> : (
            <button onClick={() => setConnected(true)} style={{ width: '100%', height: 48, borderRadius: 14, cursor: 'pointer', background: T.green, border: 'none', fontFamily: T.font, fontSize: 14, fontWeight: 800, color: '#fff' }}>アクセスを許可</button>
          )}
        </div>
      </div>
    </Content>
  );
}

// ── 3 list ──
function ListT({ onNext, onBack, onSkip }) {
  const lists = ['買い物', '日用品', '週末まとめ買い'];
  const [sel, setSel] = React.useState('買い物');
  const [creating, setCreating] = React.useState(false);
  const [newName, setNewName] = React.useState('');
  return (
    <Content title="追加先のリストを選ぶ" sub="不足食材をどのリストに追加するか選びます。あとで変更できます。" skip="あとで" onSkip={onSkip} primary="次へ" onPrimary={onNext} onBack={onBack}>
      <div style={{ fontSize: 12.5, fontWeight: 700, color: T.faint, margin: '0 2px 10px' }}>リマインダーの既存リスト</div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 11 }}>
        {lists.map((l) => {
          const on = !creating && sel === l;
          return (
            <button key={l} onClick={() => { setSel(l); setCreating(false); }} style={{ border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '15px 16px', borderRadius: 16, background: on ? T.greenSoft : '#fff', boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)' }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: on ? '#fff' : T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="list" size={20} color={T.green} /></div>
              <span style={{ flex: 1, textAlign: 'left', fontSize: 15.5, fontWeight: 700, color: T.ink }}>{l}</span>
              <span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>
            </button>
          );
        })}
        {/* new list cell */}
        <button onClick={() => setCreating(true)} style={{ gridColumn: creating ? '1 / -1' : 'auto', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: creating ? 8 : '15px 16px', borderRadius: 16, background: creating ? T.greenSoft : '#fff', boxShadow: creating ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)', textAlign: 'left' }}>
          {!creating ? (
            <>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="plus" size={20} color={T.green} /></div>
              <span style={{ flex: 1, fontSize: 15.5, fontWeight: 700, color: T.ink }}>新規リストを作成</span>
            </>
          ) : (
            <input autoFocus value={newName} onChange={(e) => setNewName(e.target.value)} onClick={(e) => e.stopPropagation()} placeholder="例：つかいきりの買い物" style={{ flex: 1, border: 'none', outline: 'none', background: '#fff', borderRadius: 12, padding: '13px 14px', fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.ink }} />
          )}
        </button>
      </div>
    </Content>
  );
}

// ── 4 appliance ──
function AppToggleT({ icon, name, on, onToggle, children }) {
  return (
    <div style={{ background: '#fff', borderRadius: 18, boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)', overflow: 'hidden' }}>
      <button onClick={onToggle} style={{ width: '100%', border: 'none', cursor: 'pointer', background: 'transparent', display: 'flex', alignItems: 'center', gap: 13, padding: '16px 18px' }}>
        <div style={{ width: 50, height: 50, borderRadius: 15, background: on ? T.greenSoft : '#F1EEE7', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={26} color={on ? T.green : T.sub} stroke={1.9} /></div>
        <div style={{ flex: 1, textAlign: 'left', minWidth: 0 }}>
          <div style={{ fontSize: 17, fontWeight: 800, color: T.ink, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</div>
          <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 1 }}>{on ? '持っている' : 'タップで選択'}</div>
        </div>
        <div style={{ width: 50, height: 29, borderRadius: 99, background: on ? T.green : '#DDD8CE', padding: 3, display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start', transition: 'all .2s', flexShrink: 0 }}><div style={{ width: 23, height: 23, borderRadius: 99, background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)' }} /></div>
      </button>
      {on && children}
    </div>
  );
}
function PickerRow({ label, opts, val, setVal }) {
  return (
    <div>
      <div style={{ fontSize: 12, fontWeight: 700, color: T.faint, marginBottom: 7 }}>{label}</div>
      <div style={{ display: 'flex', gap: 7, flexWrap: 'wrap' }}>
        {opts.map((o) => { const on = val === o; return <button key={o} onClick={() => setVal(o)} style={{ border: 'none', cursor: 'pointer', padding: '9px 15px', borderRadius: 999, fontFamily: T.font, fontSize: 13, fontWeight: 700, background: on ? T.ink : '#F1EEE7', color: on ? '#fff' : T.ink }}>{o}</button>; })}
      </div>
    </div>
  );
}
function ApplianceT({ onNext, onBack, onSkip }) {
  const [hc, setHc] = React.useState(true);
  const [hcS, setHcS] = React.useState('KN-HW型'); const [hcC, setHcC] = React.useState('2.4L');
  const [he, setHe] = React.useState(false);
  const [heS, setHeS] = React.useState('AX-XA型'); const [heC, setHeC] = React.useState('30L');
  return (
    <Content title="お使いの調理家電は？" sub="お持ちの家電に合わせて献立を提案します。なくても使えます。あとで変更できます。" skip="持っていない" onSkip={onSkip} primary="次へ" onPrimary={onNext} onBack={onBack} maxW={640}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, alignItems: 'start' }}>
        <AppToggleT icon="pot" name="ホットクック" on={hc} onToggle={() => setHc((v) => !v)}>
          <div style={{ borderTop: `1px solid ${T.line}`, padding: '14px 18px 18px', display: 'flex', flexDirection: 'column', gap: 14 }}>
            <PickerRow label="シリーズ" opts={['KN-HW型', 'KN-HT型']} val={hcS} setVal={setHcS} />
            <PickerRow label="容量" opts={['1.0L', '1.6L', '2.4L']} val={hcC} setVal={setHcC} />
          </div>
        </AppToggleT>
        <AppToggleT icon="oven" name="ヘルシオ" on={he} onToggle={() => setHe((v) => !v)}>
          <div style={{ borderTop: `1px solid ${T.line}`, padding: '14px 18px 18px', display: 'flex', flexDirection: 'column', gap: 14 }}>
            <PickerRow label="シリーズ" opts={['AX-XA型', 'AX-LSX型']} val={heS} setVal={setHeS} />
            <PickerRow label="容量" opts={['26L', '30L']} val={heC} setVal={setHeC} />
          </div>
        </AppToggleT>
      </div>
      <div style={{ display: 'flex', gap: 9, marginTop: 16, padding: '13px 16px', background: T.greenSoft, borderRadius: 14 }}>
        <Icon name="spark" size={19} color={T.green} />
        <div style={{ fontSize: 13, fontWeight: 700, color: T.greenInk, lineHeight: 1.6 }}>家電に合わせて「ほったらかし調理」のレシピを優先表示します。</div>
      </div>
    </Content>
  );
}

// ── 5 done ──
function FinishT({ onStart }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', background: T.bg, textAlign: 'center', padding: 40 }}>
      <div className="sl-pop" style={{ width: 116, height: 116, borderRadius: 36, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 24, boxShadow: '0 18px 40px rgba(31,122,85,0.32)' }}><Icon name="check" size={58} color="#fff" stroke={3} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 30, fontWeight: 700, color: T.ink }}>準備ができました</div>
      <div style={{ fontSize: 16, fontWeight: 600, color: T.sub, marginTop: 12, lineHeight: 1.8, maxWidth: 380 }}>さっそく冷蔵庫の食材を登録して、使い切り献立をはじめましょう。</div>
      <div style={{ display: 'flex', gap: 12, marginTop: 26 }}>
        {[['AI', 'Claude'], ['リマインダー連携', '「買い物」リスト'], ['調理家電', 'ホットクック KN-HW型']].map(([k, v]) => (
          <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 9, background: '#fff', borderRadius: 14, padding: '14px 18px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
            <Icon name="check" size={17} color={T.green} stroke={3} />
            <div style={{ textAlign: 'left' }}><div style={{ fontSize: 11.5, fontWeight: 700, color: T.faint }}>{k}</div><div style={{ fontSize: 14, fontWeight: 800, color: T.ink, marginTop: 1 }}>{v}</div></div>
          </div>
        ))}
      </div>
      <button onClick={onStart} style={{ height: 62, borderRadius: 18, padding: '0 40px', marginTop: 34, cursor: 'pointer', border: 'none', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', gap: 10, fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
        <Icon name="camera" size={22} color="#fff" /> 食材を登録してはじめる
      </button>
    </div>
  );
}

window.OnboardingTablet = { STEPS, Rail, WelcomeT, AIT, LinkT, ListT, ApplianceT, FinishT, Content, CW, CH };
