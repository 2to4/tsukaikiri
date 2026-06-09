// settings.jsx — 設定画面（スマホ・リスト形式 / カテゴリ別グループ）
const { T, Icon } = window;

const AI_PROVIDERS = {
  claude: { name: 'Claude', sub: 'Anthropic', vision: true,  models: 'Claude 3.5 Sonnet', placeholder: 'sk-ant-...', tile: '#EFE6D5', fg: '#9A5B2A', keyUrl: 'console.anthropic.com', keyPath: '/settings/keys' },
  openai: { name: 'OpenAI', sub: 'GPT-4o',    vision: true,  models: 'GPT-4o',           placeholder: 'sk-...',     tile: '#E0EDE6', fg: '#2C7A56', keyUrl: 'platform.openai.com', keyPath: '/api-keys' },
  gemini: { name: 'Gemini', sub: 'Google',    vision: true,  models: 'Gemini 1.5 Pro',   placeholder: 'AIza...',    tile: '#E1EAF1', fg: '#3A6491', keyUrl: 'aistudio.google.com', keyPath: '/app/apikey' },
  grok:   { name: 'Grok',   sub: 'xAI',       vision: false, models: 'Grok 2',           placeholder: 'xai-...',    tile: '#EAE7DF', fg: '#55514A', keyUrl: 'console.x.ai', keyPath: '' },
};
const AI_ORDER = ['claude', 'openai', 'gemini', 'grok'];

function VisionTag({ ok, small }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, padding: small ? '2px 7px' : '4px 9px', borderRadius: 999, background: ok ? T.greenSoft : '#F0EEE7' }}>
      <span style={{ width: 5, height: 5, borderRadius: 99, background: ok ? T.green : T.faint }} />
      <span style={{ fontSize: small ? 10.5 : 11.5, fontWeight: 700, color: ok ? T.greenInk : T.faint }}>{ok ? 'Vision対応' : 'Vision非対応'}</span>
    </span>
  );
}

// ── building blocks ──
function Section({ title, note, children }) {
  return (
    <div style={{ marginBottom: 22 }}>
      {title && <div style={{ fontSize: 12, fontWeight: 800, color: T.faint, letterSpacing: 0.4, padding: '0 6px 8px' }}>{title}</div>}
      <div style={{ background: '#fff', borderRadius: 18, overflow: 'hidden', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>{children}</div>
      {note && <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.6, padding: '8px 6px 0' }}>{note}</div>}
    </div>
  );
}
function Row({ icon, iconBg, label, value, valueColor, right, onClick, last, danger }) {
  const Tag = onClick ? 'button' : 'div';
  return (
    <Tag onClick={onClick} disabled={onClick ? false : undefined} style={{ width: '100%', border: 'none', background: 'transparent', cursor: onClick ? 'pointer' : 'default',
      display: 'flex', alignItems: 'center', gap: 13, padding: '13px 15px', textAlign: 'left',
      borderBottom: last ? 'none' : `1px solid ${T.line}` }}>
      {icon && <div style={{ width: 34, height: 34, borderRadius: 10, background: iconBg || T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={19} color={danger ? T.over : T.green} stroke={2} /></div>}
      <span style={{ flex: 1, fontSize: 15.5, fontWeight: 700, color: danger ? T.over : T.ink }}>{label}</span>
      {value && <span style={{ fontSize: 14, fontWeight: 700, color: valueColor || T.sub, maxWidth: 168, textAlign: 'right', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', flexShrink: 0 }}>{value}</span>}
      {right}
      {onClick && <span style={{ display: 'flex', marginLeft: 2 }}><Icon name="chevron" size={17} color={T.faint} stroke={2.2} /></span>}
    </Tag>
  );
}
function Toggle({ on, onClick }) {
  return (
    <button onClick={onClick} style={{ width: 48, height: 28, borderRadius: 99, background: on ? T.green : '#DDD8CE', padding: 3, display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start', transition: 'all .2s', border: 'none', cursor: 'pointer', flexShrink: 0 }}>
      <div style={{ width: 22, height: 22, borderRadius: 99, background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)' }} />
    </button>
  );
}

// ── main list ──
function SettingsMain({ state, lang, ai, list, sync, lastSync, onOpen, onToggleSync }) {
  const aiP = AI_PROVIDERS[ai];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ padding: `${T.statusPad}px 18px 10px`, flexShrink: 0 }}>
        <div style={{ fontFamily: T.brand, fontSize: 28, fontWeight: 700, color: T.ink }}>設定</div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '6px 16px 30px' }}>
        {/* 一般 */}
        <Section title="一般">
          <Row icon="globe" label="言語" value={lang} onClick={() => onOpen('lang')} last />
        </Section>
        {/* AI */}
        <Section title="AI（食材認識・献立提案）" note="APIキーはこの端末内に安全に保存され、各社のAIへ直接送信されます。">
          <Row icon="spark" label="AIプロバイダ" value={aiP.name} onClick={() => onOpen('ai')} />
          <Row icon="key" label="APIキー" right={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 7 }}><span style={{ fontSize: 13.5, fontWeight: 700, color: state === 'nokey' ? T.near : T.green }}>{state === 'nokey' ? '未登録' : '登録済み'}</span></span>} onClick={() => onOpen('ai')} />
          <Row icon="camera" iconBg={aiP.vision ? T.greenSoft : '#F0EEE7'} label="画像認識（Vision）" right={<VisionTag ok={aiP.vision} />} last />
        </Section>
        {/* 連携 */}
        <Section title="連携">
          <Row icon="list" label="買い物リスト" value={`リマインダー・${list}`} onClick={() => onOpen('list')} />
          <Row icon="pot" label="調理家電" value="ホットクック ほか" onClick={() => onOpen('appliance')} last />
        </Section>
        {/* データ */}
        <Section title="データ" note={sync ? `最終同期：${lastSync}` : '同期はオフです。この端末のみにデータが保存されます。'}>
          <Row icon="cloud" label="iCloud 同期" right={<Toggle on={sync} onClick={onToggleSync} />} last />
        </Section>
        {/* サポート */}
        <Section title="サポート">
          <Row icon="coffee" iconBg="#F6ECD6" label="作者をサポート" value="Buy Me a Coffee" right={<span style={{ display: 'flex', marginLeft: 2 }}><Icon name="open" size={16} color={T.faint} /></span>} onClick={() => onOpen('coffee')} />
          <Row icon="help" label="ヘルプ" onClick={() => onOpen('help')} />
          <Row icon="info" label="このアプリについて" value="v1.0.0" onClick={() => onOpen('about')} last />
        </Section>
        <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, padding: '6px 0 2px' }}>つかいきり ・ v1.0.0 (128)</div>
      </div>
    </div>
  );
}

// ── detail: language ──
function DetailHeader({ title, onBack }) {
  return (
    <div style={{ padding: `${T.statusPad}px 16px 8px`, flexShrink: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span></button>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>{title}</div>
      </div>
    </div>
  );
}
function LangDetail({ lang, setLang, onBack }) {
  const opts = ['日本語', 'English', 'システムに従う'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <DetailHeader title="言語" onBack={onBack} />
      <div style={{ flex: 1, overflow: 'auto', padding: '12px 16px' }}>
        <Section>
          {opts.map((o, i) => {
            const on = lang === o;
            return <Row key={o} label={o} last={i === opts.length - 1} onClick={() => setLang(o)} right={<span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>} />;
          })}
        </Section>
        <div style={{ fontSize: 12, fontWeight: 600, color: T.faint, padding: '2px 6px', lineHeight: 1.6 }}>「システムに従う」を選ぶと、端末の言語設定に合わせて表示します。</div>
      </div>
    </div>
  );
}

// ── detail: AI provider + key ──
function AIDetail({ ai, setAi, keys, setKeys, onBack }) {
  const p = AI_PROVIDERS[ai];
  const [show, setShow] = React.useState(false);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <DetailHeader title="AIプロバイダ" onBack={onBack} />
      <div style={{ flex: 1, overflow: 'auto', padding: '12px 16px 24px' }}>
        <Section title="プロバイダを選択">
          {AI_ORDER.map((k, i) => {
            const pp = AI_PROVIDERS[k]; const on = ai === k; const has = !!keys[k];
            return (
              <button key={k} onClick={() => setAi(k)} style={{ width: '100%', border: 'none', background: on ? T.greenSoft : 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', textAlign: 'left', borderBottom: i === AI_ORDER.length - 1 ? 'none' : `1px solid ${T.line}` }}>
                <div style={{ width: 40, height: 40, borderRadius: 12, background: pp.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 800, color: pp.fg, flexShrink: 0 }}>{pp.name[0]}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}><span style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>{pp.name}</span><VisionTag ok={pp.vision} small /></div>
                  <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 2 }}>{pp.sub} ・ {has ? 'キー登録済み' : 'キー未登録'}</div>
                </div>
                <span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>
              </button>
            );
          })}
        </Section>
        <Section title={`${p.name} のAPIキー`} note={`使用モデル：${p.models}${p.vision ? '' : '（このプロバイダは画像認識に非対応。カメラ登録は手動補正が必要です）'}`}>
          <div style={{ padding: '14px 15px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: '#F4F1EB', borderRadius: 13, padding: '4px 6px 4px 14px' }}>
              <input value={keys[ai] || ''} onChange={(e) => setKeys({ ...keys, [ai]: e.target.value })} placeholder={p.placeholder} type={show ? 'text' : 'password'} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', padding: '10px 0', fontFamily: 'ui-monospace, monospace', fontSize: 14, fontWeight: 600, color: T.ink }} />
              <button onClick={() => setShow((s) => !s)} style={{ flexShrink: 0, border: 'none', background: '#fff', cursor: 'pointer', borderRadius: 9, padding: '7px 12px', fontFamily: T.font, fontSize: 12.5, fontWeight: 700, color: T.sub }}>{show ? '隠す' : '表示'}</button>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 12 }}>
              <span style={{ width: 7, height: 7, borderRadius: 99, background: keys[ai] ? T.green : T.near }} />
              <span style={{ fontSize: 12.5, fontWeight: 700, color: keys[ai] ? T.greenInk : T.near }}>{keys[ai] ? 'キーが登録されています' : 'キーを入力してください'}</span>
            </div>
          </div>
          {!keys[ai] && (
            <button onClick={() => {}} style={{ width: '100%', border: 'none', borderTop: `1px solid ${T.line}`, background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 11, padding: '14px 15px', textAlign: 'left' }}>
              <div style={{ width: 34, height: 34, borderRadius: 10, background: p.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="key" size={18} color={p.fg} stroke={2} /></div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14.5, fontWeight: 800, color: T.greenInk }}>{p.name} のAPIキーを取得</div>
                <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, marginTop: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.keyUrl}{p.keyPath}</div>
              </div>
              <Icon name="open" size={17} color={T.sub} />
            </button>
          )}
        </Section>
        {!keys[ai] && (
          <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.6, padding: '2px 6px' }}>登録ページを外部ブラウザで開きます。発行したキーをコピーして、上の欄に貼り付けてください。</div>
        )}
      </div>
    </div>
  );
}

// ── detail: list ──
function ListDetail({ list, setList, onBack }) {
  const lists = ['買い物', '日用品', '週末まとめ買い'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <DetailHeader title="買い物リスト" onBack={onBack} />
      <div style={{ flex: 1, overflow: 'auto', padding: '12px 16px' }}>
        <Section title="連携先アプリ">
          <Row icon="list" label="リマインダー" value="連携済み" valueColor={T.greenInk} last />
        </Section>
        <Section title="追加先リスト">
          {lists.map((l, i) => { const on = list === l;
            return <Row key={l} label={l} last={i === lists.length - 1} onClick={() => setList(l)} right={<span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>} />; })}
        </Section>
      </div>
    </div>
  );
}

// ── detail: appliance ──
function ApplPicker({ label, opts, val, setVal }) {
  return (
    <div>
      <div style={{ fontSize: 12, fontWeight: 700, color: T.faint, marginBottom: 7 }}>{label}</div>
      <div style={{ display: 'flex', gap: 7, flexWrap: 'wrap' }}>
        {opts.map((o) => { const on = val === o;
          return <button key={o} onClick={() => setVal(o)} style={{ border: 'none', cursor: 'pointer', padding: '8px 14px', borderRadius: 999, fontFamily: T.font, fontSize: 13, fontWeight: 700, background: on ? T.ink : '#F1EEE7', color: on ? '#fff' : T.ink }}>{o}</button>; })}
      </div>
    </div>
  );
}
function ApplCard({ icon, name, on, onToggle, series, setSeries, seriesOpts, cap, setCap, capOpts }) {
  return (
    <div style={{ background: '#fff', borderRadius: 18, overflow: 'hidden', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 15px' }}>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: on ? T.greenSoft : '#F1EEE7', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={21} color={on ? T.green : T.sub} stroke={1.9} /></div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>{name}</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 1 }}>{on ? `${series} ・ ${cap}` : '持っていない'}</div>
        </div>
        <Toggle on={on} onClick={onToggle} />
      </div>
      {on && (
        <div style={{ borderTop: `1px solid ${T.line}`, padding: '14px 15px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <ApplPicker label="型（シリーズ）" opts={seriesOpts} val={series} setVal={setSeries} />
          <ApplPicker label="容量" opts={capOpts} val={cap} setVal={setCap} />
        </div>
      )}
    </div>
  );
}
function ApplianceDetail({ onBack }) {
  const [hc, setHc] = React.useState(true);
  const [hcS, setHcS] = React.useState('KN-HW型'); const [hcC, setHcC] = React.useState('2.4L');
  const [he, setHe] = React.useState(false);
  const [heS, setHeS] = React.useState('AX-XA型'); const [heC, setHeC] = React.useState('30L');
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <DetailHeader title="調理家電" onBack={onBack} />
      <div style={{ flex: 1, overflow: 'auto', padding: '12px 16px 24px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <ApplCard icon="pot" name="ホットクック" on={hc} onToggle={() => setHc((v) => !v)} series={hcS} setSeries={setHcS} seriesOpts={['KN-HW型', 'KN-HT型']} cap={hcC} setCap={setHcC} capOpts={['1.0L', '1.6L', '2.4L']} />
          <ApplCard icon="oven" name="ヘルシオ" on={he} onToggle={() => setHe((v) => !v)} series={heS} setSeries={setHeS} seriesOpts={['AX-XA型', 'AX-LSX型']} cap={heC} setCap={setHeC} capOpts={['26L', '30L']} />
        </div>
        <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.6, padding: '12px 6px 0' }}>登録すると、その家電で作れる「ほったらかし調理」レシピを優先表示します。型・容量に合わせて分量も調整します。</div>
      </div>
    </div>
  );
}

// ── detail: coffee ──
function CoffeeDetail({ onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <DetailHeader title="作者をサポート" onBack={onBack} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 30px' }}>
        <div style={{ width: 96, height: 96, borderRadius: 30, background: '#F6ECD6', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}><Icon name="coffee" size={46} color="#9A5B2A" /></div>
        <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink }}>つかいきりを応援する</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.8, marginTop: 10, maxWidth: 280 }}>個人開発のアプリです。コーヒー1杯ぶんの応援が、開発の励みになります。</div>
      </div>
      <div style={{ padding: '0 16px 30px' }}>
        <button style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer', background: '#FFDD00', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#2A2723', boxShadow: '0 12px 26px rgba(214,185,40,0.34)' }}>
          <Icon name="coffee" size={22} color="#2A2723" /> Buy Me a Coffee を開く
        </button>
        <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, marginTop: 12 }}>外部ブラウザで buymeacoffee.com を開きます</div>
      </div>
    </div>
  );
}

// ── detail: about / help (simple) ──
function AboutDetail({ onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <DetailHeader title="このアプリについて" onBack={onBack} />
      <div style={{ flex: 1, overflow: 'auto', padding: '12px 16px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '20px 0 26px' }}>
          <div style={{ width: 84, height: 84, borderRadius: 26, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 44, marginBottom: 14, boxShadow: '0 12px 26px rgba(31,122,85,0.28)' }}>🥗</div>
          <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink }}>つかいきり</div>
          <div style={{ fontSize: 13, fontWeight: 600, color: T.sub, marginTop: 4 }}>バージョン 1.0.0 (128)</div>
        </div>
        <Section>
          <Row icon="help" label="ヘルプ・よくある質問" onClick={() => {}} />
          <Row icon="info" label="利用規約" onClick={() => {}} />
          <Row icon="info" label="プライバシーポリシー" onClick={() => {}} last />
        </Section>
        <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.7, padding: '4px 20px' }}>冷蔵庫の在庫を使い切るための献立提案アプリ。<br />© 2026 つかいきり</div>
      </div>
    </div>
  );
}

window.Settings = { AI_PROVIDERS, AI_ORDER, Section, Row, Toggle, VisionTag, DetailHeader, ApplPicker, ApplCard, SettingsMain, LangDetail, AIDetail, ListDetail, ApplianceDetail, CoffeeDetail, AboutDetail };
