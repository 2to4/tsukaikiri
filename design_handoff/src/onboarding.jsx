// onboarding.jsx — 初回オンボーディング（スマホ・ステップ式）
const { T, Icon } = window;

// progress dots/bar
function StepBar({ step, total }) {
  return (
    <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, i) => {
        const done = i < step, cur = i === step;
        return <div key={i} style={{ height: 6, borderRadius: 99, flex: cur ? 1.6 : 1, background: done || cur ? T.green : '#E2DED5', transition: 'all .3s' }} />;
      })}
    </div>
  );
}

// shared shell: top bar (back + steps + skip) / scroll body / bottom button
function Shell({ step, total, onBack, onSkip, skipLabel, primary, onPrimary, primaryDisabled, secondary, children }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ padding: `${T.statusPad}px 18px 6px`, flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 16 }}>
          <button onClick={onBack} disabled={!onBack} style={{ width: 38, height: 38, borderRadius: 12, flexShrink: 0, cursor: onBack ? 'pointer' : 'default', background: onBack ? '#fff' : 'transparent', border: onBack ? `1.5px solid ${T.line}` : '1.5px solid transparent', display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: onBack ? 1 : 0 }}>
            <span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={18} color={T.ink} /></span>
          </button>
          <div style={{ flex: 1 }}><StepBar step={step} total={total} /></div>
          {onSkip ? <button onClick={onSkip} style={{ flexShrink: 0, background: 'none', border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 13.5, fontWeight: 700, color: T.sub }}>{skipLabel || 'スキップ'}</button> : <div style={{ width: 44 }} />}
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '6px 24px 8px' }}>{children}</div>
      <div style={{ flexShrink: 0, padding: '12px 20px 26px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {secondary}
        <button onClick={onPrimary} disabled={primaryDisabled} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: primaryDisabled ? 'default' : 'pointer',
          background: primaryDisabled ? '#D8D4CB' : T.green, boxShadow: primaryDisabled ? 'none' : '0 12px 26px rgba(31,122,85,0.3)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          {primary}
        </button>
      </div>
    </div>
  );
}

// ── 1. Welcome ──
function Welcome({ onNext }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 30px' }}>
        <div style={{ width: 116, height: 116, borderRadius: 36, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 60, marginBottom: 26, boxShadow: '0 18px 40px rgba(31,122,85,0.3)' }}>🥗</div>
        <div style={{ fontFamily: T.brand, fontSize: 32, fontWeight: 700, color: T.ink, letterSpacing: 1 }}>つかいきり</div>
        <div style={{ fontSize: 16, fontWeight: 600, color: T.ink, marginTop: 14, lineHeight: 1.8, maxWidth: 290 }}>
          冷蔵庫にある食材から献立を提案。<br />「使い切る」毎日を、かんたんに。
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14, marginTop: 30, width: '100%', maxWidth: 300 }}>
          {[['camera', '撮るだけ在庫登録', 'カメラでまとめて食材を登録'], ['spark', '使い切り献立', '期限が近い食材から提案'], ['bag', '買い物リスト連携', '足りない食材を自動で追加']].map(([ic, t, s]) => (
            <div key={t} style={{ display: 'flex', alignItems: 'center', gap: 13, background: '#fff', borderRadius: 16, padding: '13px 15px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)', textAlign: 'left' }}>
              <div style={{ width: 42, height: 42, borderRadius: 13, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={ic} size={21} color={T.green} /></div>
              <div><div style={{ fontSize: 14.5, fontWeight: 800, color: T.ink }}>{t}</div><div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 1 }}>{s}</div></div>
            </div>
          ))}
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '8px 20px 28px' }}>
        <button onClick={onNext} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          はじめる <span style={{ display: 'flex' }}><Icon name="chevron" size={20} color="#fff" stroke={2.4} /></span>
        </button>
        <div style={{ textAlign: 'center', fontSize: 12, fontWeight: 600, color: T.faint, marginTop: 14 }}>設定はあとから変更できます</div>
      </div>
    </div>
  );
}

// ── 2. AI provider ──
const OB_AI = [
  { k: 'claude', name: 'Claude', sub: 'Anthropic', vision: true,  tile: '#EFE6D5', fg: '#9A5B2A', ph: 'sk-ant-...', url: 'console.anthropic.com/settings/keys' },
  { k: 'openai', name: 'OpenAI', sub: 'GPT-4o',    vision: true,  tile: '#E0EDE6', fg: '#2C7A56', ph: 'sk-...',     url: 'platform.openai.com/api-keys' },
  { k: 'gemini', name: 'Gemini', sub: 'Google',    vision: true,  tile: '#E1EAF1', fg: '#3A6491', ph: 'AIza...',    url: 'aistudio.google.com/app/apikey' },
  { k: 'grok',   name: 'Grok',   sub: 'xAI',       vision: false, tile: '#EAE7DF', fg: '#55514A', ph: 'xai-...',    url: 'console.x.ai' },
];
function AIStep({ step, total, onBack, onNext, onSkip }) {
  const [sel, setSel] = React.useState('claude');
  const [key, setKey] = React.useState('');
  const p = OB_AI.find((x) => x.k === sel);
  return (
    <Shell step={step} total={total} onBack={onBack} onSkip={onSkip} skipLabel="あとで"
      primary="次へ" onPrimary={onNext}>
      <div style={{ paddingTop: 4 }}>
        <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink }}>AIを選ぶ</div>
        <div style={{ fontSize: 14, fontWeight: 500, color: T.sub, lineHeight: 1.7, marginTop: 8 }}>食材の認識と献立提案に使うAIを選びます。お持ちのAPIキーを使います。あとで変更できます。</div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 9, marginTop: 20 }}>
        {OB_AI.map((o) => {
          const on = sel === o.k;
          return (
            <button key={o.k} onClick={() => setSel(o.k)} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '13px 14px', borderRadius: 16, background: on ? T.greenSoft : '#fff', boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)' }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: o.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 800, color: o.fg, flexShrink: 0 }}>{o.name[0]}</div>
              <div style={{ flex: 1, minWidth: 0, textAlign: 'left' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
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
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: '#fff', borderRadius: 14, padding: '4px 6px 4px 14px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
        <input value={key} onChange={(e) => setKey(e.target.value)} placeholder={p.ph} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', padding: '11px 0', fontFamily: 'ui-monospace, monospace', fontSize: 14, fontWeight: 600, color: T.ink }} />
      </div>
      <button style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 11, padding: '12px 13px', marginTop: 10, borderRadius: 14, background: '#fff', boxShadow: '0 1px 2px rgba(40,39,35,0.04)', textAlign: 'left' }}>
        <div style={{ width: 32, height: 32, borderRadius: 10, background: p.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="key" size={17} color={p.fg} stroke={2} /></div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 13.5, fontWeight: 800, color: T.greenInk }}>{p.name} のAPIキーを取得</div>
          <div style={{ fontSize: 11, fontWeight: 600, color: T.faint, marginTop: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.url}</div>
        </div>
        <Icon name="open" size={16} color={T.sub} />
      </button>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 11, padding: '0 2px' }}>
        <span style={{ width: 7, height: 7, borderRadius: 99, background: key ? T.green : T.near }} />
        <span style={{ fontSize: 12, fontWeight: 700, color: key ? T.greenInk : T.sub }}>{key ? 'キーが入力されました' : 'あとで設定でも登録できます'}</span>
      </div>
    </Shell>
  );
}

// ── 3. Link permission ──
function LinkStep({ step, total, onBack, onNext, onSkip }) {
  const [connected, setConnected] = React.useState(false);
  return (
    <Shell step={step} total={total} onBack={onBack} onSkip={onSkip} skipLabel="あとで"
      primary={connected ? '次へ' : '次へ'} onPrimary={onNext} primaryDisabled={false}>
      <div style={{ textAlign: 'center', paddingTop: 6 }}>
        <div style={{ width: 88, height: 88, borderRadius: 28, background: connected ? T.greenSoft : '#fff', border: connected ? 'none' : `1.5px solid ${T.line}`, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18, transition: 'all .2s' }}>
          <Icon name={connected ? 'check' : 'list'} size={40} color={T.green} stroke={connected ? 3 : 2} />
        </div>
        <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink, lineHeight: 1.35 }}>買い物リストと連携</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.8, marginTop: 10, maxWidth: 300, marginInline: 'auto' }}>
          足りない食材を、お使いの<b style={{ color: T.ink }}>リマインダー</b>に自動で追加します。許可すると連携できます。
        </div>
      </div>
      <div style={{ background: '#fff', borderRadius: 18, padding: '16px 16px', marginTop: 24, boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
        {[['アプリ', 'リマインダー（iOS）'], ['できること', '買い物リストへの項目追加'], ['プライバシー', '在庫の写真は端末内で処理']].map(([k, v], i) => (
          <div key={k} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 0', borderBottom: i < 2 ? `1px solid ${T.line}` : 'none' }}>
            <span style={{ fontSize: 13.5, fontWeight: 600, color: T.sub }}>{k}</span>
            <span style={{ fontSize: 14, fontWeight: 700, color: T.ink, textAlign: 'right', maxWidth: 200 }}>{v}</span>
          </div>
        ))}
      </div>
      {!connected ? (
        <button onClick={() => setConnected(true)} style={{ width: '100%', height: 56, borderRadius: 16, marginTop: 16, cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.green}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 15.5, fontWeight: 800, color: T.greenInk }}>
          <Icon name="list" size={20} color={T.green} /> リマインダーへのアクセスを許可
        </button>
      ) : (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 18, color: T.greenInk, fontSize: 14.5, fontWeight: 800 }}>
          <Icon name="check" size={19} color={T.green} stroke={3} /> 連携しました
        </div>
      )}
    </Shell>
  );
}

// ── 3. List select ──
function ListSelectStep({ step, total, onBack, onNext, onSkip }) {
  const lists = ['買い物', '日用品', '週末まとめ買い'];
  const [sel, setSel] = React.useState('買い物');
  const [creating, setCreating] = React.useState(false);
  const [newName, setNewName] = React.useState('');
  return (
    <Shell step={step} total={total} onBack={onBack} onSkip={onSkip} skipLabel="あとで"
      primary="次へ" onPrimary={onNext}>
      <div style={{ paddingTop: 4 }}>
        <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink }}>追加先のリストを選ぶ</div>
        <div style={{ fontSize: 14, fontWeight: 500, color: T.sub, lineHeight: 1.7, marginTop: 8 }}>不足食材をどのリストに追加するか選びます。あとで変更できます。</div>
      </div>
      <div style={{ fontSize: 12.5, fontWeight: 700, color: T.faint, margin: '22px 2px 10px' }}>リマインダーの既存リスト</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
        {lists.map((l) => {
          const on = !creating && sel === l;
          return (
            <button key={l} onClick={() => { setSel(l); setCreating(false); }} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '14px 15px', borderRadius: 16, background: on ? T.greenSoft : '#fff', boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)' }}>
              <div style={{ width: 38, height: 38, borderRadius: 11, background: on ? '#fff' : T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="list" size={19} color={T.green} /></div>
              <span style={{ flex: 1, textAlign: 'left', fontSize: 15.5, fontWeight: 700, color: T.ink }}>{l}</span>
              <span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>
            </button>
          );
        })}
      </div>
      <div style={{ fontSize: 12.5, fontWeight: 700, color: T.faint, margin: '22px 2px 10px' }}>新しく作る</div>
      <div style={{ background: creating ? T.greenSoft : '#fff', borderRadius: 16, padding: creating ? 6 : 0, boxShadow: creating ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)', transition: 'all .15s' }}>
        {!creating ? (
          <button onClick={() => setCreating(true)} style={{ width: '100%', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '14px 15px', borderRadius: 16, background: 'transparent' }}>
            <div style={{ width: 38, height: 38, borderRadius: 11, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="plus" size={20} color={T.green} /></div>
            <span style={{ flex: 1, textAlign: 'left', fontSize: 15.5, fontWeight: 700, color: T.ink }}>新規リストを作成</span>
          </button>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 10px' }}>
            <input autoFocus value={newName} onChange={(e) => setNewName(e.target.value)} placeholder="例：つかいきりの買い物" style={{ flex: 1, border: 'none', outline: 'none', background: '#fff', borderRadius: 11, padding: '12px 13px', fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.ink }} />
          </div>
        )}
      </div>
    </Shell>
  );
}

// ── 4. Appliances ──
function ApplianceToggle({ icon, name, on, onToggle, children }) {
  return (
    <div style={{ background: '#fff', borderRadius: 18, boxShadow: on ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)', overflow: 'hidden', transition: 'box-shadow .15s' }}>
      <button onClick={onToggle} style={{ width: '100%', border: 'none', cursor: 'pointer', background: 'transparent', display: 'flex', alignItems: 'center', gap: 13, padding: '14px 15px' }}>
        <div style={{ width: 46, height: 46, borderRadius: 14, background: on ? T.greenSoft : '#F1EEE7', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={24} color={on ? T.green : T.sub} stroke={1.9} /></div>
        <div style={{ flex: 1, textAlign: 'left' }}>
          <div style={{ fontSize: 16, fontWeight: 800, color: T.ink }}>{name}</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 1 }}>{on ? '持っている' : 'タップで選択'}</div>
        </div>
        <div style={{ width: 48, height: 28, borderRadius: 99, background: on ? T.green : '#DDD8CE', padding: 3, display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start', transition: 'all .2s', flexShrink: 0 }}>
          <div style={{ width: 22, height: 22, borderRadius: 99, background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)' }} />
        </div>
      </button>
      {on && children}
    </div>
  );
}
function ModelPicker({ series, setSeries, cap, setCap, opts, caps }) {
  return (
    <div style={{ borderTop: `1px solid ${T.line}`, padding: '13px 15px 15px', display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div>
        <div style={{ fontSize: 12, fontWeight: 700, color: T.faint, marginBottom: 7 }}>シリーズ</div>
        <div style={{ display: 'flex', gap: 7, flexWrap: 'wrap' }}>
          {opts.map((o) => { const on = series === o; return <button key={o} onClick={() => setSeries(o)} style={{ border: 'none', cursor: 'pointer', padding: '8px 14px', borderRadius: 999, fontFamily: T.font, fontSize: 13, fontWeight: 700, background: on ? T.ink : '#F1EEE7', color: on ? '#fff' : T.ink }}>{o}</button>; })}
        </div>
      </div>
      <div>
        <div style={{ fontSize: 12, fontWeight: 700, color: T.faint, marginBottom: 7 }}>容量</div>
        <div style={{ display: 'flex', gap: 7, flexWrap: 'wrap' }}>
          {caps.map((o) => { const on = cap === o; return <button key={o} onClick={() => setCap(o)} style={{ border: 'none', cursor: 'pointer', padding: '8px 14px', borderRadius: 999, fontFamily: T.font, fontSize: 13, fontWeight: 700, background: on ? T.ink : '#F1EEE7', color: on ? '#fff' : T.ink }}>{o}</button>; })}
        </div>
      </div>
    </div>
  );
}
function ApplianceStep({ step, total, onBack, onNext, onSkip }) {
  const [hc, setHc] = React.useState(true);
  const [hcSeries, setHcSeries] = React.useState('KN-HW型');
  const [hcCap, setHcCap] = React.useState('2.4L');
  const [he, setHe] = React.useState(false);
  const [heSeries, setHeSeries] = React.useState('AX-XA型');
  const [heCap, setHeCap] = React.useState('30L');
  return (
    <Shell step={step} total={total} onBack={onBack} onSkip={onSkip} skipLabel="持っていない"
      primary="次へ" onPrimary={onNext}>
      <div style={{ paddingTop: 4 }}>
        <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink }}>お使いの調理家電は？</div>
        <div style={{ fontSize: 14, fontWeight: 500, color: T.sub, lineHeight: 1.7, marginTop: 8 }}>お持ちの家電に合わせて献立を提案します。なくても使えます。あとで変更できます。</div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 22 }}>
        <ApplianceToggle icon="pot" name="ホットクック" on={hc} onToggle={() => setHc((v) => !v)}>
          <ModelPicker series={hcSeries} setSeries={setHcSeries} cap={hcCap} setCap={setHcCap} opts={['KN-HW型', 'KN-HT型']} caps={['1.0L', '1.6L', '2.4L']} />
        </ApplianceToggle>
        <ApplianceToggle icon="oven" name="ヘルシオ" on={he} onToggle={() => setHe((v) => !v)}>
          <ModelPicker series={heSeries} setSeries={setHeSeries} cap={heCap} setCap={setHeCap} opts={['AX-XA型', 'AX-LSX型']} caps={['26L', '30L']} />
        </ApplianceToggle>
      </div>
      <div style={{ display: 'flex', gap: 9, marginTop: 16, padding: '12px 14px', background: T.greenSoft, borderRadius: 14 }}>
        <Icon name="spark" size={18} color={T.green} />
        <div style={{ fontSize: 12.5, fontWeight: 700, color: T.greenInk, lineHeight: 1.6 }}>家電に合わせて「ほったらかし調理」のレシピを優先表示します。</div>
      </div>
    </Shell>
  );
}

// ── 5. Done ──
function Finish({ onStart }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 30px' }}>
        <div className="sl-pop" style={{ width: 116, height: 116, borderRadius: 36, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 24, boxShadow: '0 18px 40px rgba(31,122,85,0.32)' }}><Icon name="check" size={58} color="#fff" stroke={3} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 27, fontWeight: 700, color: T.ink }}>準備ができました</div>
        <div style={{ fontSize: 15, fontWeight: 600, color: T.sub, marginTop: 12, lineHeight: 1.8, maxWidth: 290 }}>さっそく冷蔵庫の食材を登録して、使い切り献立をはじめましょう。</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 26, width: '100%', maxWidth: 300 }}>
          {[['AI', 'Claude'], ['リマインダー連携', '「買い物」リスト'], ['調理家電', 'ホットクック KN-HW型']].map(([k, v]) => (
            <div key={k} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: '#fff', borderRadius: 14, padding: '13px 16px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13.5, fontWeight: 700, color: T.sub }}><Icon name="check" size={16} color={T.green} stroke={3} />{k}</span>
              <span style={{ fontSize: 13.5, fontWeight: 800, color: T.ink }}>{v}</span>
            </div>
          ))}
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '8px 20px 28px' }}>
        <button onClick={onStart} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          <Icon name="camera" size={22} color="#fff" /> 食材を登録してはじめる
        </button>
      </div>
    </div>
  );
}

window.Onboarding = { Welcome, AIStep, LinkStep, ListSelectStep, ApplianceStep, Finish, Shell, StepBar };
