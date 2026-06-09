// androidOnboarding.jsx — Android-specific onboarding steps (Google Sign-in)
const { T, Icon } = window;
const { Shell, StepBar } = window.Onboarding;
const { Content } = window.OnboardingTablet || {};

// ── Phone: Step 3 — Google Sign-in (replaces iOS LinkStep) ──
function LinkStepAndroid({ step, total, onBack, onNext, onSkip }) {
  const [connected, setConnected] = React.useState(false);
  return (
    <Shell step={step} total={total} onBack={onBack} onSkip={onSkip} skipLabel="あとで"
      primary="次へ" onPrimary={onNext}>
      <div style={{ textAlign:'center', paddingTop:6 }}>
        <div style={{ width:88, height:88, borderRadius:28, background: connected ? T.greenSoft : '#fff', border: connected ? 'none' : `1.5px solid ${T.line}`, display:'inline-flex', alignItems:'center', justifyContent:'center', marginBottom:18 }}>
          <span style={{ fontSize:40 }}>🟢</span>
        </div>
        <div style={{ fontFamily:T.brand, fontSize:23, fontWeight:700, color:T.ink, lineHeight:1.35 }}>Google ToDo と連携</div>
        <div style={{ fontSize:14.5, fontWeight:500, color:T.sub, lineHeight:1.8, marginTop:10, maxWidth:300, marginInline:'auto' }}>
          足りない食材を、お使いの <b style={{ color:T.ink }}>Google ToDo</b> に自動で追加します。Googleアカウントでサインインして連携します。
        </div>
      </div>
      <div style={{ background:'#fff', borderRadius:18, padding:'16px', marginTop:24, boxShadow:`0 1px 2px rgba(40,39,35,0.04)` }}>
        {[['アプリ','Google ToDo（Android）'],['できること','買い物リストへの項目追加'],['プライバシー','在庫の写真は端末内で処理']].map(([k,v], i) => (
          <div key={k} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'12px 0', borderBottom: i<2 ? `1px solid ${T.line}` : 'none' }}>
            <span style={{ fontSize:13.5, fontWeight:600, color:T.sub }}>{k}</span>
            <span style={{ fontSize:14, fontWeight:700, color:T.ink }}>{v}</span>
          </div>
        ))}
      </div>
      {!connected ? (
        <button onClick={() => setConnected(true)} style={{ width:'100%', height:56, borderRadius:16, marginTop:16, cursor:'pointer', background:'#fff', border:`1.5px solid ${T.green}`, display:'flex', alignItems:'center', justifyContent:'center', gap:9, fontFamily:T.font, fontSize:15.5, fontWeight:800, color:T.greenInk }}>
          <span style={{ fontSize:20 }}>🟢</span> Googleでサインイン
        </button>
      ) : (
        <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:8, marginTop:18, color:T.greenInk, fontSize:14.5, fontWeight:800 }}>
          <Icon name="check" size={19} color={T.green} stroke={3}/> Googleアカウントと連携しました
        </div>
      )}
    </Shell>
  );
}

// ── Phone: Step 6 — Finish (Android: Google ToDo instead of リマインダー) ──
function FinishAndroid({ onStart }) {
  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column', background:T.bg, fontFamily:T.font }}>
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center', padding:'0 30px' }}>
        <div className="sl-pop" style={{ width:116, height:116, borderRadius:36, background:T.green, display:'flex', alignItems:'center', justifyContent:'center', marginBottom:24, boxShadow:'0 18px 40px rgba(31,122,85,0.32)' }}><Icon name="check" size={58} color="#fff" stroke={3}/></div>
        <div style={{ fontFamily:T.brand, fontSize:27, fontWeight:700, color:T.ink }}>準備ができました</div>
        <div style={{ fontSize:15, fontWeight:600, color:T.sub, marginTop:12, lineHeight:1.8, maxWidth:290 }}>さっそく冷蔵庫の食材を登録して、使い切り献立をはじめましょう。</div>
        <div style={{ display:'flex', flexDirection:'column', gap:10, marginTop:26, width:'100%', maxWidth:300 }}>
          {[['AI','Claude'],['Google ToDo連携','「買い物」リスト'],['調理家電','ホットクック KN-HW型']].map(([k,v]) => (
            <div key={k} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', background:'#fff', borderRadius:14, padding:'13px 16px', boxShadow:`0 1px 2px rgba(40,39,35,0.04)` }}>
              <span style={{ display:'flex', alignItems:'center', gap:8, fontSize:13.5, fontWeight:700, color:T.sub }}><Icon name="check" size={16} color={T.green} stroke={3}/>{k}</span>
              <span style={{ fontSize:13.5, fontWeight:800, color:T.ink }}>{v}</span>
            </div>
          ))}
        </div>
      </div>
      <div style={{ flexShrink:0, padding:'8px 20px 28px' }}>
        <button onClick={onStart} style={{ width:'100%', height:62, borderRadius:18, border:'none', cursor:'pointer', background:T.green, boxShadow:'0 12px 26px rgba(31,122,85,0.3)', display:'flex', alignItems:'center', justifyContent:'center', gap:9, fontFamily:T.font, fontSize:17, fontWeight:800, color:'#fff' }}>
          <Icon name="camera" size={22} color="#fff"/> 食材を登録してはじめる
        </button>
      </div>
    </div>
  );
}

// ── Tablet: Step 3 — Google Sign-in ──
function LinkTAndroid({ onNext, onBack, onSkip }) {
  const [connected, setConnected] = React.useState(false);
  return (
    <Content title="Google ToDo と連携" sub="足りない食材を、お使いのGoogle ToDoに自動で追加します。Googleアカウントでサインインして連携します。あとで変更できます。" skip="あとで" onSkip={onSkip} primary="次へ" onPrimary={onNext} onBack={onBack} maxW={560}>
      <div style={{ background:'#fff', borderRadius:18, padding:'4px 16px', boxShadow:`0 1px 2px rgba(40,39,35,0.04)`, marginBottom:18 }}>
        {[['アプリ','Google ToDo（Android）'],['できること','買い物リストへの項目追加'],['プライバシー','在庫の写真は端末内で処理']].map(([k,v], i) => (
          <div key={k} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'14px 0', borderBottom: i<2 ? `1px solid ${T.line}` : 'none' }}>
            <span style={{ fontSize:14.5, fontWeight:700, color:T.sub }}>{k}</span>
            <span style={{ fontSize:15, fontWeight:700, color:T.ink }}>{v}</span>
          </div>
        ))}
      </div>
      {!connected ? (
        <button onClick={() => setConnected(true)} style={{ width:'100%', height:58, borderRadius:16, cursor:'pointer', background:'#fff', border:`1.5px solid ${T.green}`, display:'flex', alignItems:'center', justifyContent:'center', gap:10, fontFamily:T.font, fontSize:16, fontWeight:800, color:T.greenInk }}>
          <span style={{ fontSize:22 }}>🟢</span> Googleでサインイン
        </button>
      ) : (
        <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:10, padding:'16px 0', color:T.greenInk, fontSize:15.5, fontWeight:800 }}>
          <Icon name="check" size={22} color={T.green} stroke={3}/> Googleアカウントと連携しました
        </div>
      )}
    </Content>
  );
}

// ── Tablet: Step 6 — Finish ──
function FinishTAndroid({ onStart }) {
  const { T, Icon } = window;
  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center', padding:'0 60px' }}>
      <div className="sl-pop" style={{ width:116, height:116, borderRadius:36, background:T.green, display:'flex', alignItems:'center', justifyContent:'center', marginBottom:28, boxShadow:'0 18px 40px rgba(31,122,85,0.32)' }}><Icon name="check" size={58} color="#fff" stroke={3}/></div>
      <div style={{ fontFamily:T.brand, fontSize:30, fontWeight:700, color:T.ink }}>準備ができました</div>
      <div style={{ fontSize:16, fontWeight:600, color:T.sub, marginTop:14, lineHeight:1.8, maxWidth:380 }}>さっそく冷蔵庫の食材を登録して、使い切り献立をはじめましょう。</div>
      <div style={{ display:'flex', gap:14, marginTop:28, flexWrap:'wrap', justifyContent:'center', maxWidth:560 }}>
        {[['AI','Claude'],['Google ToDo連携','「買い物」リスト'],['調理家電','ホットクック KN-HW型']].map(([k,v]) => (
          <div key={k} style={{ display:'flex', alignItems:'center', gap:10, background:'#fff', borderRadius:16, padding:'14px 18px', boxShadow:`0 1px 2px rgba(40,39,35,0.04)` }}>
            <Icon name="check" size={18} color={T.green} stroke={3}/>
            <span style={{ fontSize:14, fontWeight:700, color:T.sub }}>{k}</span>
            <span style={{ fontSize:14, fontWeight:800, color:T.ink }}>{v}</span>
          </div>
        ))}
      </div>
      <button onClick={onStart} style={{ marginTop:36, height:64, borderRadius:20, border:'none', cursor:'pointer', background:T.green, boxShadow:'0 12px 26px rgba(31,122,85,0.3)', display:'flex', alignItems:'center', justifyContent:'center', gap:10, fontFamily:T.font, fontSize:18, fontWeight:800, color:'#fff', padding:'0 36px' }}>
        <Icon name="camera" size={24} color="#fff"/> 食材を登録してはじめる
      </button>
    </div>
  );
}

window.AndroidOnboarding = { LinkStepAndroid, FinishAndroid, LinkTAndroid, FinishTAndroid };
