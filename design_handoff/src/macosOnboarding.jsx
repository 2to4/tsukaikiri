// macosOnboarding.jsx — macOS Setup Assistant onboarding (6 steps)
const { T, Icon } = window;
const { TBtn, useHover, MFONT } = window.MacShell;

const OB_STEPS = ['ようこそ', 'AI を選ぶ', 'リマインダー連携', 'リストを選ぶ', '調理家電', '完了'];

function StepRail({ current }) {
  return (
    <div style={{ width: 220, flexShrink: 0, background: 'linear-gradient(180deg,#1A5C36 0%,#145030 100%)', padding: '28px 14px', display: 'flex', flexDirection: 'column', gap: 2 }}>
      <div style={{ fontFamily: T.brand, fontSize: 14.5, fontWeight: 700, color: '#fff', marginBottom: 22, padding: '0 6px' }}>設定アシスタント</div>
      {OB_STEPS.map((label, i) => {
        const done = i < current; const active = i === current;
        return (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 10px', borderRadius: 10, background: active ? 'rgba(255,255,255,0.15)' : 'transparent' }}>
            <div style={{ width: 22, height: 22, borderRadius: 99, border: `1.5px solid ${done ? T.green : active ? '#fff' : 'rgba(255,255,255,0.3)'}`, background: done ? T.green : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              {done ? <Icon name="check" size={12} color="#fff" stroke={3} /> : <span style={{ fontSize: 10, fontWeight: 800, color: active ? '#fff' : 'rgba(255,255,255,0.4)', fontFamily: MFONT }}>{i + 1}</span>}
            </div>
            <span style={{ fontSize: 12.5, fontWeight: active ? 700 : 600, color: active ? '#fff' : done ? 'rgba(255,255,255,0.7)' : 'rgba(255,255,255,0.4)' }}>{label}</span>
          </div>
        );
      })}
    </div>
  );
}

function MacOBContent({ title, sub, skip, onSkip, primary, onPrimary, onBack, children, maxW = 480 }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '32px 44px 20px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{ width: '100%', maxWidth: maxW }}>
          <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink, marginBottom: 8, textAlign: 'center' }}>{title}</div>
          {sub && <div style={{ fontSize: 14, fontWeight: 500, color: T.sub, lineHeight: 1.75, marginBottom: 22, textAlign: 'center' }}>{sub}</div>}
          {children}
        </div>
      </div>
      <div style={{ padding: '12px 32px 20px', borderTop: `1px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexShrink: 0 }}>
        <div style={{ display: 'flex', gap: 8 }}>
          {onBack && <TBtn label="戻る" onClick={onBack} />}
          {skip && onSkip && <button onClick={onSkip} style={{ border: 'none', background: 'transparent', cursor: 'pointer', fontFamily: T.font, fontSize: 13, fontWeight: 700, color: T.faint, padding: '5px 8px' }}>{skip}</button>}
        </div>
        <TBtn label={primary || '次へ'} kbd="⏎" primary onClick={onPrimary} />
      </div>
    </div>
  );
}

// ── Step screens ──────────────────────────────────────────────────
function MacWelcome({ onNext }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '30px 50px', textAlign: 'center' }}>
      <div className="sl-pop" style={{ width: 86, height: 86, borderRadius: 24, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 22, boxShadow: '0 12px 30px rgba(31,122,85,0.3)' }}>
        <span style={{ fontSize: 46 }}>🌿</span>
      </div>
      <div style={{ fontFamily: T.brand, fontSize: 26, fontWeight: 700, color: T.ink, marginBottom: 10 }}>つかいきりへようこそ</div>
      <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.8, maxWidth: 380, marginBottom: 26 }}>
        冷蔵庫の食材を登録して、食材を無駄なく使い切る献立を提案します。<br />まず簡単な設定をしましょう。
      </div>
      <div style={{ display: 'flex', gap: 12, marginBottom: 28 }}>
        {[['📷', '撮るだけ登録', 'カメラで食材を一括追加'], ['🍳', '使い切り献立', '期限間近の食材を優先'], ['🛒', '買い物リスト', '足りない食材を自動追加']].map(([e, t, s]) => (
          <div key={t} style={{ flex: 1, background: '#fff', borderRadius: 14, padding: '14px 12px', textAlign: 'center', boxShadow: '0 1px 2px rgba(40,39,35,0.05)', border: `1px solid ${T.line}` }}>
            <div style={{ fontSize: 24, marginBottom: 7 }}>{e}</div>
            <div style={{ fontSize: 12.5, fontWeight: 800, color: T.ink, marginBottom: 3 }}>{t}</div>
            <div style={{ fontSize: 11, fontWeight: 600, color: T.sub, lineHeight: 1.5 }}>{s}</div>
          </div>
        ))}
      </div>
      <TBtn label="はじめる" kbd="⏎" primary onClick={onNext} />
    </div>
  );
}

function MacAIStep({ onNext, onBack, onSkip }) {
  const [ai, setAi] = React.useState('claude');
  const [key, setKey] = React.useState('');
  const AIS = [{ k: 'claude', name: 'Claude', co: 'Anthropic', vision: true, col: '#D97757' }, { k: 'openai', name: 'GPT-4o', co: 'OpenAI', vision: true, col: '#10A37F' }, { k: 'gemini', name: 'Gemini', co: 'Google', vision: true, col: '#4285F4' }, { k: 'grok', name: 'Grok', co: 'xAI', vision: false, col: '#1C1C1E' }];
  const links = { claude: 'https://console.anthropic.com/', openai: 'https://platform.openai.com/', gemini: 'https://aistudio.google.com/', grok: 'https://console.x.ai/' };
  return (
    <MacOBContent title="AI プロバイダを選択" sub="食材の認識と献立提案に使う AI を選んでください。APIキーはこの Mac 内に安全に保存されます。" skip="あとで設定" onSkip={onSkip} onBack={onBack} onPrimary={onNext} maxW={520}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 16 }}>
        {AIS.map(p => { const on = ai === p.k; return (
          <button key={p.k} onClick={() => setAi(p.k)} style={{ border: `2px solid ${on ? T.green : T.line}`, borderRadius: 12, padding: '11px 13px', cursor: 'pointer', fontFamily: T.font, textAlign: 'left', background: on ? T.greenSoft : '#fff', transition: 'all 0.12s' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
              <div style={{ width: 24, height: 24, borderRadius: 7, background: p.col, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="spark" size={12} color="#fff" /></div>
              <span style={{ fontSize: 13.5, fontWeight: 800, color: T.ink }}>{p.name}</span>
              {on && <span style={{ marginLeft: 'auto', fontSize: 10, fontWeight: 700, padding: '2px 6px', borderRadius: 999, background: T.greenSoft, color: T.greenInk }}>選択中</span>}
            </div>
            <div style={{ fontSize: 11, color: T.sub, fontWeight: 600 }}>{p.co} · {p.vision ? '✓ 画像認識あり' : '画像認識なし'}</div>
          </button>
        ); })}
      </div>
      <div style={{ background: '#fff', borderRadius: 12, border: `1px solid ${T.line}`, padding: '12px 14px' }}>
        <div style={{ fontSize: 10.5, fontWeight: 800, color: T.faint, marginBottom: 7, letterSpacing: '0.06em' }}>APIキー</div>
        <input value={key} onChange={e => setKey(e.target.value)} placeholder="sk-ant-..." style={{ width: '100%', border: `1px solid ${T.line}`, borderRadius: 8, padding: '7px 11px', fontFamily: T.font, fontSize: 13, color: T.ink, outline: 'none', background: T.bg }} />
        <div style={{ marginTop: 7 }}>
          <a href={links[ai]} target="_blank" rel="noreferrer" style={{ fontSize: 11.5, fontWeight: 700, color: T.greenInk, textDecoration: 'none' }}>
            → {AIS.find(p => p.k === ai)?.co} で APIキーを取得する ↗
          </a>
        </div>
      </div>
    </MacOBContent>
  );
}

function MacLinkStep({ onNext, onBack, onSkip }) {
  const [linked, setLinked] = React.useState(false);
  return (
    <MacOBContent title="リマインダーと連携" sub="足りない食材を、macOS のリマインダーに自動で追加します。" skip="あとで" onSkip={onSkip} onBack={onBack} onPrimary={onNext} maxW={440}>
      <div style={{ background: '#fff', borderRadius: 14, border: `1px solid ${T.line}`, overflow: 'hidden', marginBottom: 14 }}>
        {[['アプリ', 'リマインダー（macOS）'], ['できること', '買い物リストへの項目追加'], ['プライバシー', '写真はこの Mac 内で処理']].map(([k, v], i) => (
          <div key={k} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', borderBottom: i < 2 ? `1px solid ${T.line}` : 'none' }}>
            <span style={{ fontSize: 13, fontWeight: 700, color: T.sub }}>{k}</span>
            <span style={{ fontSize: 13.5, fontWeight: 700, color: T.ink }}>{v}</span>
          </div>
        ))}
      </div>
      {!linked ? (
        <button onClick={() => setLinked(true)} style={{ width: '100%', height: 46, borderRadius: 12, border: `1.5px solid ${T.green}`, background: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 14, fontWeight: 800, color: T.greenInk }}>
          <Icon name="list" size={17} color={T.green} /> リマインダーへのアクセスを許可
        </button>
      ) : (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, padding: '14px 0', color: T.greenInk, fontSize: 14, fontWeight: 800 }}>
          <Icon name="check" size={18} color={T.green} stroke={3} /> リマインダーと連携しました
        </div>
      )}
    </MacOBContent>
  );
}

function MacListStep({ onNext, onBack, onSkip }) {
  const [sel, setSel] = React.useState('買い物');
  const [newName, setNew] = React.useState('');
  const [lists, setLists] = React.useState(['買い物', '日用品', '週末まとめ買い']);
  return (
    <MacOBContent title="追加先リストを選ぶ" sub="買い物リストを追加するリマインダーのリストを選んでください。" skip="あとで" onSkip={onSkip} onBack={onBack} onPrimary={onNext} maxW={420}>
      <div style={{ background: '#fff', borderRadius: 14, border: `1px solid ${T.line}`, overflow: 'hidden', marginBottom: 12 }}>
        {lists.map((l, i) => (
          <button key={l} onClick={() => setSel(l)} style={{ width: '100%', border: 'none', background: sel === l ? T.greenSoft : 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '11px 16px', borderBottom: i < lists.length - 1 ? `1px solid ${T.line}` : 'none', fontFamily: T.font }}>
            <span style={{ width: 18, height: 18, borderRadius: 99, border: sel === l ? 'none' : `2px solid ${T.line}`, background: sel === l ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{sel === l && <Icon name="check" size={10} color="#fff" stroke={3} />}</span>
            <span style={{ fontSize: 13.5, fontWeight: 700, color: T.ink }}>{l}</span>
          </button>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <input value={newName} onChange={e => setNew(e.target.value)} placeholder="新しいリスト名…" style={{ flex: 1, border: `1px solid ${T.line}`, borderRadius: 8, padding: '7px 11px', fontFamily: T.font, fontSize: 13, color: T.ink, outline: 'none', background: T.bg }} />
        <TBtn label="作成" onClick={() => { if (newName.trim()) { setLists(l => [...l, newName.trim()]); setSel(newName.trim()); setNew(''); } }} disabled={!newName.trim()} />
      </div>
    </MacOBContent>
  );
}

function MacApplianceStep({ onNext, onBack, onSkip }) {
  const [hc, setHc] = React.useState(false);
  const [hs, setHs] = React.useState(false);
  const HC_SERIES = ['KN-HW型（HW16F ほか）', 'KN-HT型（HT99B ほか）', 'KN-HW小容量型'];
  const HS_SERIES = ['AX-XA30型（XA30H ほか）', 'AX-XW30型', 'AX-RA20型'];
  return (
    <MacOBContent title="調理家電の登録" sub="お持ちの調理家電を選ぶと、それに合わせた献立を提案します。" skip="持っていない" onSkip={onSkip} onBack={onBack} onPrimary={onNext} maxW={460}>
      {[['ホットクック', '🍲', hc, setHc, HC_SERIES], ['ヘルシオ', '♨️', hs, setHs, HS_SERIES]].map(([name, emoji, on, setOn, series]) => (
        <div key={name} style={{ background: '#fff', borderRadius: 14, border: `1.5px solid ${on ? T.green : T.line}`, padding: '14px 16px', marginBottom: 12, transition: 'border-color 0.15s' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}><span style={{ fontSize: 22 }}>{emoji}</span><span style={{ fontSize: 14.5, fontWeight: 800, color: T.ink }}>{name}</span></div>
            <div onClick={() => setOn(v => !v)} style={{ width: 40, height: 24, borderRadius: 999, background: on ? T.green : T.line, cursor: 'pointer', position: 'relative', transition: 'background 0.2s', flexShrink: 0 }}>
              <div style={{ width: 20, height: 20, borderRadius: 99, background: '#fff', position: 'absolute', top: 2, left: on ? 18 : 2, transition: 'left 0.2s', boxShadow: '0 1px 4px rgba(0,0,0,0.2)' }} />
            </div>
          </div>
          {on && (
            <div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px solid ${T.line}` }}>
              <div style={{ fontSize: 10.5, fontWeight: 800, color: T.faint, marginBottom: 7, letterSpacing: '0.06em' }}>シリーズ</div>
              <select style={{ width: '100%', border: `1px solid ${T.line}`, borderRadius: 8, padding: '7px 10px', fontFamily: T.font, fontSize: 13, color: T.ink, background: T.bg, outline: 'none', cursor: 'pointer' }}>
                {series.map(s => <option key={s}>{s}</option>)}
              </select>
            </div>
          )}
        </div>
      ))}
    </MacOBContent>
  );
}

function MacFinish({ onStart }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '30px 50px', textAlign: 'center' }}>
      <div className="sl-pop" style={{ width: 86, height: 86, borderRadius: 24, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 22, boxShadow: '0 12px 30px rgba(31,122,85,0.3)' }}>
        <Icon name="check" size={44} color="#fff" stroke={3} />
      </div>
      <div style={{ fontFamily: T.brand, fontSize: 24, fontWeight: 700, color: T.ink, marginBottom: 10 }}>準備ができました</div>
      <div style={{ fontSize: 14, fontWeight: 500, color: T.sub, lineHeight: 1.8, maxWidth: 360, marginBottom: 24 }}>
        さっそく冷蔵庫の食材を登録して、使い切り献立をはじめましょう。
      </div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 26, flexWrap: 'wrap', justifyContent: 'center' }}>
        {[['AI', 'Claude'], ['リマインダー連携', '「買い物」リスト'], ['調理家電', 'ホットクック KN-HW型']].map(([k, v]) => (
          <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 8, background: '#fff', borderRadius: 12, padding: '10px 14px', boxShadow: '0 1px 2px rgba(40,39,35,0.05)', border: `1px solid ${T.line}` }}>
            <Icon name="check" size={13} color={T.green} stroke={3} />
            <span style={{ fontSize: 12, fontWeight: 700, color: T.sub }}>{k}</span>
            <span style={{ fontSize: 12, fontWeight: 800, color: T.ink }}>{v}</span>
          </div>
        ))}
      </div>
      <TBtn icon="camera" label="食材を登録してはじめる" kbd="⏎" primary onClick={onStart} />
    </div>
  );
}

window.MacOnboarding = { StepRail, MacWelcome, MacAIStep, MacLinkStep, MacListStep, MacApplianceStep, MacFinish, OB_STEPS };
