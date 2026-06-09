// helpAbout.jsx — ヘルプ / このアプリについて（読み物レイアウト）
const { T, Icon } = window;

// shared header (back)
function HABack({ onBack, title }) {
  return (
    <div style={{ padding: `${T.statusPad}px 16px 8px`, flexShrink: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span></button>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>{title}</div>
      </div>
    </div>
  );
}

// reading-style section block
function Block({ eyebrow, title, children }) {
  return (
    <section style={{ marginTop: 30 }}>
      {eyebrow && <div style={{ fontSize: 11.5, fontWeight: 800, color: T.green, letterSpacing: 0.6, marginBottom: 8 }}>{eyebrow}</div>}
      {title && <h2 style={{ margin: 0, fontFamily: T.brand, fontSize: 19, fontWeight: 700, color: T.ink, lineHeight: 1.4 }}>{title}</h2>}
      <div style={{ marginTop: 12 }}>{children}</div>
    </section>
  );
}
function P({ children }) {
  return <p style={{ margin: '0 0 12px', fontSize: 14.5, fontWeight: 500, color: '#5C564C', lineHeight: 1.95, textWrap: 'pretty' }}>{children}</p>;
}

// usage guide step
function Step({ n, icon, title, body }) {
  return (
    <div style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
      <div style={{ position: 'relative', flexShrink: 0, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{ width: 44, height: 44, borderRadius: 14, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={icon} size={22} color={T.green} /></div>
      </div>
      <div style={{ flex: 1, paddingTop: 1 }}>
        <div style={{ fontSize: 11.5, fontWeight: 800, color: T.green, letterSpacing: 0.5 }}>STEP {n}</div>
        <div style={{ fontSize: 15.5, fontWeight: 800, color: T.ink, marginTop: 3 }}>{title}</div>
        <div style={{ fontSize: 13.5, fontWeight: 500, color: '#5C564C', lineHeight: 1.8, marginTop: 4 }}>{body}</div>
      </div>
    </div>
  );
}

// external source link card
function SourceLink({ title, host, desc }) {
  return (
    <button style={{ width: '100%', border: `1px solid ${T.line}`, background: '#fff', cursor: 'pointer', borderRadius: 16, padding: '14px 15px', display: 'flex', alignItems: 'center', gap: 13, textAlign: 'left' }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, background: '#EEF1F4', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="database" size={20} color="#4A6585" stroke={1.9} /></div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 800, color: T.ink }}>{title}</div>
        <div style={{ fontSize: 12, fontWeight: 600, color: T.sub, marginTop: 2 }}>{desc}</div>
        <div style={{ fontSize: 11.5, fontWeight: 600, color: T.faint, marginTop: 3, fontFamily: 'ui-monospace, monospace' }}>{host}</div>
      </div>
      <Icon name="open" size={17} color={T.sub} />
    </button>
  );
}

// callout (manual edit note)
function Callout({ icon, title, children }) {
  return (
    <div style={{ background: T.greenSoft, borderRadius: 18, padding: '16px 17px', display: 'flex', gap: 13 }}>
      <div style={{ width: 38, height: 38, borderRadius: 12, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={20} color={T.green} /></div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14.5, fontWeight: 800, color: T.greenInk }}>{title}</div>
        <div style={{ fontSize: 13, fontWeight: 500, color: '#3F6A53', lineHeight: 1.8, marginTop: 4 }}>{children}</div>
      </div>
    </div>
  );
}

// the scrolling body (shared by phone & tablet)
function HelpBody({ pad = '0 22px 36px', anchored = false }) {
  const A = (k) => anchored ? { 'data-help-sec': k } : {};
  return (
    <div style={{ padding: pad }}>
      {/* hero */}
      <div {...A('top')} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', paddingTop: 14 }}>
        <div style={{ width: 78, height: 78, borderRadius: 24, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 40, boxShadow: '0 12px 26px rgba(31,122,85,0.26)' }}>🥗</div>
        <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink, marginTop: 14 }}>つかいきり</div>
        <div style={{ fontSize: 13, fontWeight: 600, color: T.sub, marginTop: 4 }}>バージョン 1.0.0 (128)</div>
        <div style={{ fontSize: 14, fontWeight: 500, color: '#5C564C', lineHeight: 1.85, marginTop: 12, maxWidth: 320 }}>冷蔵庫の在庫から献立を提案し、食材を「使い切る」ための家庭向けアプリです。</div>
      </div>

      {/* usage guide */}
      <div {...A('guide')}>
      <Block eyebrow="GUIDE" title="かんたんな使い方">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          <Step n="1" icon="camera" title="食材を登録する" body="冷蔵庫の中をカメラで撮影すると、AIが食材を読み取って在庫に追加します。手入力でも登録できます。" />
          <Step n="2" icon="leaf" title="在庫と期限を確認する" body="賞味期限が近い順に並びます。期限が近い食材はオレンジ、超過は赤で示されます。" />
          <Step n="3" icon="spark" title="献立を提案してもらう" body="在庫から作れる使い切りメニューを提案します。調理家電に合わせたレシピも表示されます。" />
          <Step n="4" icon="bag" title="不足食材を買い物リストへ" body="献立に足りない食材は、お使いのリマインダーの買い物リストへまとめて追加できます。" />
        </div>
      </Block>
      </div>

      {/* expiry data source */}
      <div {...A('data')}>
      <div style={{ height: 1, background: T.line, margin: '30px 0 0' }} />
      <Block eyebrow="DATA" title="賞味期限データについて">
        <P>本アプリの賞味期限のめやすは、米国農務省（USDA）食品安全検査局（FSIS）が公開する <b style={{ color: T.ink }}>FoodKeeper</b> のデータをベースにしています。FoodKeeper は食品ごとの保存期間の指針をまとめた公的データセットです。</P>
        <P>和食材や日本で一般的な食品など、FoodKeeper に含まれないものは、独自に保存期間の目安を補完しています。</P>
        <div style={{ background: T.nearSoft, borderRadius: 16, padding: '14px 16px', display: 'flex', gap: 12, marginTop: 4 }}>
          <Icon name="alert" size={20} color={T.near} />
          <div style={{ fontSize: 13, fontWeight: 600, color: '#8A5524', lineHeight: 1.8 }}>表示される期限は<b>あくまで目安</b>です。保存状態・開封の有無・季節などにより、実際の日持ちは前後します。食品の状態は必ずご自身でご確認ください。</div>
        </div>
      </Block>
      </div>

      {/* source links */}
      <div {...A('source')}>
      <Block title="出典・参考データ">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <SourceLink title="FoodKeeper" host="foodsafety.gov/foodkeeper-app" desc="USDA / FSIS による食品保存期間の指針" />
          <SourceLink title="Data.gov（FoodKeeper Data）" host="catalog.data.gov" desc="米国政府の公開データカタログ" />
        </div>
      </Block>
      </div>

      {/* manual edit */}
      <div {...A('edit')}>
      <Block>
        <Callout icon="edit" title="賞味期限はいつでも手動で修正できます">
          各食材の詳細画面から、賞味期限の日付をいつでも編集できます。実際のパッケージの表示や保存状態に合わせて、ご自身の値に上書きしてお使いください。
        </Callout>
      </Block>
      </div>

      {/* legal */}
      <div {...A('legal')}>
      <Block title="規約・プライバシー">
        <div style={{ background: '#fff', borderRadius: 16, overflow: 'hidden', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          {[['doc', '利用規約'], ['shield', 'プライバシーポリシー'], ['help', 'よくある質問・お問い合わせ']].map(([ic, l], i) => (
            <button key={l} style={{ width: '100%', border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, padding: '14px 15px', borderBottom: i < 2 ? `1px solid ${T.line}` : 'none', textAlign: 'left' }}>
              <Icon name={ic} size={19} color={T.green} stroke={2} />
              <span style={{ flex: 1, fontSize: 15, fontWeight: 700, color: T.ink }}>{l}</span>
              <Icon name="chevron" size={17} color={T.faint} stroke={2.2} />
            </button>
          ))}
        </div>
      </Block>
      </div>

      <div style={{ textAlign: 'center', fontSize: 11.5, fontWeight: 600, color: T.faint, lineHeight: 1.8, marginTop: 28 }}>
        FoodKeeper data © USDA / FSIS（パブリックドメイン）<br />© 2026 つかいきり
      </div>
    </div>
  );
}

// phone screen (with its own header + scroll)
function HelpAbout({ onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <HABack onBack={onBack} title="ヘルプ / このアプリについて" />
      <div style={{ flex: 1, overflow: 'auto' }}><HelpBody /></div>
    </div>
  );
}

window.HelpAbout = { HelpAbout, HelpBody, HABack };
