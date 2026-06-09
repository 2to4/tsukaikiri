// androidSettings.jsx — Android-specific settings (Google ToDo / Google Drive)
const { T, Icon } = window;
const { Section, Row, Toggle, VisionTag, AI_PROVIDERS, AI_ORDER, DetailHeader, ApplPicker, ApplCard } = window.Settings;
const { PaneWrap, Radio } = window.SettingsTablet || {};

function SettingsMainAndroid({ state, lang, ai, list, sync, lastSync, onOpen, onToggleSync }) {
  const aiP = AI_PROVIDERS[ai];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ padding: `${T.statusPad}px 18px 10px`, flexShrink: 0 }}>
        <div style={{ fontFamily: T.brand, fontSize: 28, fontWeight: 700, color: T.ink }}>設定</div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '6px 16px 30px' }}>
        <Section title="一般">
          <Row icon="globe" label="言語" value={lang} onClick={() => onOpen('lang')} last />
        </Section>
        <Section title="AI（食材認識・献立提案）" note="APIキーはこの端末内に安全に保存され、各社のAIへ直接送信されます。">
          <Row icon="spark" label="AIプロバイダ" value={aiP.name} onClick={() => onOpen('ai')} />
          <Row icon="key" label="APIキー" right={<span style={{ display:'inline-flex', alignItems:'center', gap:7 }}><span style={{ fontSize:13.5, fontWeight:700, color: state==='nokey'?T.near:T.green }}>{state==='nokey'?'未登録':'登録済み'}</span></span>} onClick={() => onOpen('ai')} />
          <Row icon="camera" iconBg={aiP.vision?T.greenSoft:'#F0EEE7'} label="画像認識（Vision）" right={<VisionTag ok={aiP.vision} />} last />
        </Section>
        <Section title="連携">
          <Row icon="list" label="買い物リスト" value={`Google ToDo・${list}`} onClick={() => onOpen('list')} />
          <Row icon="pot" label="調理家電" value="ホットクック ほか" onClick={() => onOpen('appliance')} last />
        </Section>
        <Section title="データ" note={sync ? `最終同期：${lastSync}` : '同期はオフです。この端末のみにデータが保存されます。'}>
          <Row icon="cloud" label="Google Drive 同期" right={<Toggle on={sync} onClick={onToggleSync} />} last />
        </Section>
        <Section title="サポート">
          <Row icon="coffee" iconBg="#F6ECD6" label="作者をサポート" value="Buy Me a Coffee" right={<span style={{ display:'flex', marginLeft:2 }}><Icon name="open" size={16} color={T.faint}/></span>} onClick={() => onOpen('coffee')} />
          <Row icon="help" label="ヘルプ" onClick={() => onOpen('help')} />
          <Row icon="info" label="このアプリについて" value="v1.0.0" onClick={() => onOpen('about')} last />
        </Section>
        <div style={{ textAlign:'center', fontSize:11.5, fontWeight:600, color:T.faint, padding:'6px 0 2px' }}>つかいきり ・ v1.0.0 (128)</div>
      </div>
    </div>
  );
}

function ListDetailAndroid({ list, setList, onBack }) {
  const lists = ['買い物', '食料品', '週末まとめ買い'];
  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column', background:T.bg, fontFamily:T.font }}>
      <DetailHeader title="買い物リスト" onBack={onBack} />
      <div style={{ flex:1, overflow:'auto', padding:'12px 16px' }}>
        <Section title="連携先アプリ">
          <Row icon="list" label="Google ToDo" value="連携済み" valueColor={T.greenInk} last />
        </Section>
        <Section title="追加先リスト">
          {lists.map((l, i) => {
            const on = list === l;
            return <Row key={l} label={l} last={i===lists.length-1} onClick={() => setList(l)} right={<span style={{ width:22, height:22, borderRadius:99, border: on?'none':`2px solid ${T.line}`, background: on?T.green:'#fff', display:'flex', alignItems:'center', justifyContent:'center' }}>{on && <Icon name="check" size={13} color="#fff" stroke={3}/>}</span>} />;
          })}
        </Section>
      </div>
    </div>
  );
}

// ── Tablet Android panes ──
function ListPaneAndroid({ list, setList }) {
  const lists = ['買い物', '食料品', '週末まとめ買い'];
  return (
    <PaneWrap title="買い物リスト連携">
      <Section title="連携先アプリ"><Row icon="list" label="Google ToDo" value="連携済み" valueColor={T.greenInk} last /></Section>
      <Section title="追加先リスト">
        {lists.map((l, i) => <Row key={l} label={l} last={i===lists.length-1} onClick={() => setList(l)} right={<Radio on={list===l} />} />)}
      </Section>
    </PaneWrap>
  );
}
function DataPaneAndroid({ sync, setSync, lastSync }) {
  return (
    <PaneWrap title="データ">
      <Section note={sync ? `最終同期：${lastSync}` : '同期はオフです。この端末のみにデータが保存されます。'}>
        <Row icon="cloud" label="Google Drive 同期" right={<Toggle on={sync} onClick={() => setSync((v) => !v)} />} last />
      </Section>
    </PaneWrap>
  );
}

window.SettingsAndroid = { SettingsMainAndroid, ListDetailAndroid, ListPaneAndroid, DataPaneAndroid };
