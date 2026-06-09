// settingsTablet.jsx — 設定 タブレット（左ナビ / 右セクション内容）
const { T, Icon, CATS } = window;
const { AI_PROVIDERS, AI_ORDER, Section, Row, Toggle, VisionTag } = window.Settings;
const CW = 1194, CH = 834;

const NAV = [
  { k: 'general', icon: 'globe', label: '一般', sub: '言語' },
  { k: 'ai',      icon: 'spark', label: 'AI（食材認識・献立提案）', sub: 'プロバイダ・APIキー' },
  { k: 'list',    icon: 'list',  label: '買い物リスト連携', sub: 'リマインダー' },
  { k: 'appliance', icon: 'pot', label: '調理家電', sub: 'ホットクック ほか' },
  { k: 'data',    icon: 'cloud', label: 'データ', sub: 'iCloud 同期' },
  { k: 'support', icon: 'coffee', label: 'サポート', sub: '応援・ヘルプ・情報' },
];

// ── reusable pickers ──
function Radio({ on }) {
  return <span style={{ width: 22, height: 22, borderRadius: 99, border: on ? 'none' : `2px solid ${T.line}`, background: on ? T.green : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{on && <Icon name="check" size={13} color="#fff" stroke={3} />}</span>;
}
function Chips({ opts, val, setVal }) {
  return (
    <div style={{ display: 'flex', gap: 7, flexWrap: 'wrap' }}>
      {opts.map((o) => { const on = val === o;
        return <button key={o} onClick={() => setVal(o)} style={{ border: 'none', cursor: 'pointer', padding: '9px 15px', borderRadius: 999, fontFamily: T.font, fontSize: 13.5, fontWeight: 700, background: on ? T.ink : '#F1EEE7', color: on ? '#fff' : T.ink }}>{o}</button>; })}
    </div>
  );
}

// ── right panes ──
function PaneWrap({ title, children }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '34px 40px 12px', flexShrink: 0 }}>
        <div style={{ fontFamily: T.brand, fontSize: 26, fontWeight: 700, color: T.ink }}>{title}</div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '6px 40px 36px' }}><div style={{ maxWidth: 620 }}>{children}</div></div>
    </div>
  );
}

function GeneralPane({ lang, setLang }) {
  const opts = ['日本語', 'English', 'システムに従う'];
  return (
    <PaneWrap title="一般">
      <Section title="言語" note="「システムに従う」を選ぶと、端末の言語設定に合わせて表示します。">
        {opts.map((o, i) => <Row key={o} label={o} last={i === opts.length - 1} onClick={() => setLang(o)} right={<Radio on={lang === o} />} />)}
      </Section>
    </PaneWrap>
  );
}

function AIPane({ state, ai, setAi, keys, setKeys }) {
  const p = AI_PROVIDERS[ai];
  const [show, setShow] = React.useState(false);
  return (
    <PaneWrap title="AI（食材認識・献立提案）">
      <Section title="プロバイダを選択">
        {AI_ORDER.map((k, i) => { const pp = AI_PROVIDERS[k]; const on = ai === k; const has = !!keys[k];
          return (
            <button key={k} onClick={() => setAi(k)} style={{ width: '100%', border: 'none', background: on ? T.greenSoft : 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '13px 15px', textAlign: 'left', borderBottom: i === AI_ORDER.length - 1 ? 'none' : `1px solid ${T.line}` }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: pp.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 800, color: pp.fg, flexShrink: 0 }}>{pp.name[0]}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}><span style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>{pp.name}</span><VisionTag ok={pp.vision} small /></div>
                <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 2 }}>{pp.sub} ・ {has ? 'キー登録済み' : 'キー未登録'}</div>
              </div>
              <Radio on={on} />
            </button>
          );
        })}
      </Section>
      <Section title={`${p.name} のAPIキー`} note={`使用モデル：${p.models}${p.vision ? '' : '（このプロバイダは画像認識に非対応。カメラ登録は手動補正が必要です）'}`}>
        <div style={{ padding: '14px 15px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: '#F4F1EB', borderRadius: 13, padding: '4px 6px 4px 14px' }}>
            <input value={keys[ai] || ''} onChange={(e) => setKeys({ ...keys, [ai]: e.target.value })} placeholder={p.placeholder} type={show ? 'text' : 'password'} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', padding: '11px 0', fontFamily: 'ui-monospace, monospace', fontSize: 14, fontWeight: 600, color: T.ink }} />
            <button onClick={() => setShow((s) => !s)} style={{ flexShrink: 0, border: 'none', background: '#fff', cursor: 'pointer', borderRadius: 9, padding: '8px 13px', fontFamily: T.font, fontSize: 12.5, fontWeight: 700, color: T.sub }}>{show ? '隠す' : '表示'}</button>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 12 }}>
            <span style={{ width: 7, height: 7, borderRadius: 99, background: keys[ai] ? T.green : T.near }} />
            <span style={{ fontSize: 12.5, fontWeight: 700, color: keys[ai] ? T.greenInk : T.near }}>{keys[ai] ? 'キーが登録されています' : 'キーを入力してください'}</span>
          </div>
        </div>
        {!keys[ai] && (
          <button style={{ width: '100%', border: 'none', borderTop: `1px solid ${T.line}`, background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 11, padding: '14px 15px', textAlign: 'left' }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: p.tile, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="key" size={18} color={p.fg} stroke={2} /></div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14.5, fontWeight: 800, color: T.greenInk }}>{p.name} のAPIキーを取得</div>
              <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, marginTop: 1 }}>{p.keyUrl}{p.keyPath}</div>
            </div>
            <Icon name="open" size={17} color={T.sub} />
          </button>
        )}
      </Section>
      <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.6, padding: '2px 6px' }}>APIキーはこの端末内に安全に保存され、各社のAIへ直接送信されます。</div>
    </PaneWrap>
  );
}

function ListPane({ list, setList }) {
  const lists = ['買い物', '日用品', '週末まとめ買い'];
  return (
    <PaneWrap title="買い物リスト連携">
      <Section title="連携先アプリ"><Row icon="list" label="リマインダー" value="連携済み" valueColor={T.greenInk} last /></Section>
      <Section title="追加先リスト">
        {lists.map((l, i) => <Row key={l} label={l} last={i === lists.length - 1} onClick={() => setList(l)} right={<Radio on={list === l} />} />)}
      </Section>
    </PaneWrap>
  );
}

function AppCard({ icon, name, on, onToggle, series, setSeries, seriesOpts, cap, setCap, capOpts }) {
  return (
    <div style={{ background: '#fff', borderRadius: 18, overflow: 'hidden', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px' }}>
        <div style={{ width: 42, height: 42, borderRadius: 13, background: on ? T.greenSoft : '#F1EEE7', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={23} color={on ? T.green : T.sub} stroke={1.9} /></div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 16, fontWeight: 800, color: T.ink }}>{name}</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 1 }}>{on ? `${series} ・ ${cap}` : '持っていない'}</div>
        </div>
        <Toggle on={on} onClick={onToggle} />
      </div>
      {on && (
        <div style={{ borderTop: `1px solid ${T.line}`, padding: '15px 16px 17px', display: 'flex', flexDirection: 'column', gap: 15 }}>
          <div><div style={{ fontSize: 12, fontWeight: 700, color: T.faint, marginBottom: 8 }}>型（シリーズ）</div><Chips opts={seriesOpts} val={series} setVal={setSeries} /></div>
          <div><div style={{ fontSize: 12, fontWeight: 700, color: T.faint, marginBottom: 8 }}>容量</div><Chips opts={capOpts} val={cap} setVal={setCap} /></div>
        </div>
      )}
    </div>
  );
}
function AppliancePane() {
  const [hc, setHc] = React.useState(true);
  const [hcS, setHcS] = React.useState('KN-HW型'); const [hcC, setHcC] = React.useState('2.4L');
  const [he, setHe] = React.useState(false);
  const [heS, setHeS] = React.useState('AX-XA型'); const [heC, setHeC] = React.useState('30L');
  return (
    <PaneWrap title="調理家電">
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, alignItems: 'start' }}>
        <AppCard icon="pot" name="ホットクック" on={hc} onToggle={() => setHc((v) => !v)} series={hcS} setSeries={setHcS} seriesOpts={['KN-HW型', 'KN-HT型']} cap={hcC} setCap={setHcC} capOpts={['1.0L', '1.6L', '2.4L']} />
        <AppCard icon="oven" name="ヘルシオ" on={he} onToggle={() => setHe((v) => !v)} series={heS} setSeries={setHeS} seriesOpts={['AX-XA型', 'AX-LSX型']} cap={heC} setCap={setHeC} capOpts={['26L', '30L']} />
      </div>
      <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.6, padding: '14px 6px 0' }}>登録すると、その家電で作れる「ほったらかし調理」レシピを優先表示します。型・容量に合わせて分量も調整します。</div>
    </PaneWrap>
  );
}

function DataPane({ sync, setSync, lastSync }) {
  return (
    <PaneWrap title="データ">
      <Section note={sync ? `最終同期：${lastSync}` : '同期はオフです。この端末のみにデータが保存されます。'}>
        <Row icon="cloud" label="iCloud 同期" right={<Toggle on={sync} onClick={() => setSync((v) => !v)} />} last />
      </Section>
    </PaneWrap>
  );
}

function SupportPane() {
  return (
    <PaneWrap title="サポート">
      <Section title="作者を応援">
        <div style={{ padding: '18px 16px', display: 'flex', alignItems: 'center', gap: 16 }}>
          <div style={{ width: 60, height: 60, borderRadius: 18, background: '#F6ECD6', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="coffee" size={30} color="#9A5B2A" /></div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15.5, fontWeight: 800, color: T.ink }}>つかいきりを応援する</div>
            <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 3, lineHeight: 1.6 }}>個人開発のアプリです。コーヒー1杯ぶんの応援が開発の励みになります。</div>
          </div>
          <button style={{ flexShrink: 0, height: 48, borderRadius: 14, padding: '0 20px', cursor: 'pointer', border: 'none', background: '#FFDD00', display: 'flex', alignItems: 'center', gap: 8, fontFamily: T.font, fontSize: 14, fontWeight: 800, color: '#2A2723' }}><Icon name="coffee" size={18} color="#2A2723" /> Buy Me a Coffee</button>
        </div>
      </Section>
      <Section title="情報">
        <Row icon="help" label="ヘルプ・よくある質問" onClick={() => {}} />
        <Row icon="info" label="利用規約" onClick={() => {}} />
        <Row icon="info" label="プライバシーポリシー" onClick={() => {}} />
        <Row icon="info" label="このアプリについて" value="v1.0.0 (128)" onClick={() => {}} last />
      </Section>
      <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.7, padding: '4px 0' }}>つかいきり ・ 冷蔵庫の在庫を使い切るための献立提案アプリ<br />© 2026 つかいきり</div>
    </PaneWrap>
  );
}

window.SettingsTablet = { NAV, GeneralPane, AIPane, ListPane, AppliancePane, DataPane, SupportPane, PaneWrap, Radio, Chips, CW, CH };
