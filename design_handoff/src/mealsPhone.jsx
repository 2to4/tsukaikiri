// mealsPhone.jsx — 献立提案フロー（スマホ）
const { T, Icon, ExpiryBadge } = window;
const { MEALS, MEALS_LOW, shortageCount, ApplianceBadge, UseUpBadge, Meta, CONDITIONS } = window.Meals;

const NEAR_STOCK = ['鶏むね肉', '牛乳', 'ほうれん草', '生鮭', 'ミニトマト'];

function ConditionChips({ value, onPick }) {
  return (
    <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '2px 16px', scrollbarWidth: 'none' }}>
      {CONDITIONS.map((c) => {
        const on = value === c;
        return <button key={c} onClick={() => onPick(c)} style={{ flexShrink: 0, border: 'none', cursor: 'pointer', padding: '8px 15px', borderRadius: 999,
          fontFamily: T.font, fontSize: 14, fontWeight: on ? 700 : 600, background: on ? T.green : '#fff', color: on ? '#fff' : T.sub, boxShadow: on ? 'none' : `inset 0 0 0 1px ${T.line}` }}>{c}</button>;
      })}
    </div>
  );
}

// ── 1. Before ──
function BeforeScreen({ cond, setCond, onGenerate }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ padding: `${T.statusPad}px 18px 6px` }}>
        <div style={{ fontFamily: T.brand, fontSize: 28, fontWeight: 700, color: T.ink }}>献立の提案</div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.sub, marginTop: 4 }}>いまの在庫から、使い切りメニューを考えます</div>
      </div>
      {/* use-up summary */}
      <div style={{ margin: '14px 16px 0', background: '#fff', borderRadius: 18, padding: '16px 16px', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ width: 9, height: 9, borderRadius: 99, background: T.near }} />
          <span style={{ fontSize: 14, fontWeight: 800, color: T.ink }}>期限が近い <span style={{ color: T.near }}>5品</span> を使い切れます</span>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7, marginTop: 12 }}>
          {NEAR_STOCK.map((n) => (
            <span key={n} style={{ padding: '5px 11px', borderRadius: 999, background: T.nearSoft, color: T.near, fontSize: 12.5, fontWeight: 700 }}>{n}</span>
          ))}
        </div>
      </div>
      {/* conditions */}
      <div style={{ padding: '22px 18px 8px' }}>
        <div style={{ fontSize: 13.5, fontWeight: 800, color: T.ink }}>どんな献立にする？</div>
      </div>
      <ConditionChips value={cond} onPick={setCond} />
      <div style={{ flex: 1 }} />
      {/* primary */}
      <div style={{ padding: '12px 16px 30px' }}>
        <button onClick={onGenerate} style={{ width: '100%', height: 64, borderRadius: 20, border: 'none', cursor: 'pointer', background: T.green,
          boxShadow: '0 14px 30px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 17.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="spark" size={24} color="#fff" /> 在庫から提案する
        </button>
      </div>
    </div>
  );
}

// ── 2. Generating ──
function GeneratingScreen({ cond, onCancel }) {
  const steps = ['在庫を確認中', '期限の近い食材を優先', 'レシピを選定中'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 28, textAlign: 'center' }}>
        <div className="cam-pulse" style={{ width: 92, height: 92, borderRadius: 30, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="spark" size={42} color={T.green} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>献立を考えています</div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.sub }}>条件「{cond}」・在庫の食材から選んでいます</div>
        <div style={{ width: 200, height: 6, borderRadius: 99, background: '#E6E2D9', overflow: 'hidden', marginTop: 14 }}><div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} /></div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 7, marginTop: 18 }}>
          {steps.map((s, i) => (
            <div key={s} className="cam-step" style={{ animationDelay: `${i * 0.7}s`, display: 'flex', alignItems: 'center', gap: 8, fontSize: 13, fontWeight: 600, color: T.sub }}>
              <span style={{ width: 16, height: 16, borderRadius: 99, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="check" size={11} color={T.green} stroke={3} /></span>{s}
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: '0 16px 32px', textAlign: 'center' }}>
        <button onClick={onCancel} style={{ background: 'none', border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 14.5, fontWeight: 700, color: T.sub }}>キャンセル</button>
      </div>
    </div>
  );
}

// ── meal card ──
function MealCard({ m, onTap }) {
  const short = shortageCount(m);
  return (
    <div onClick={onTap} style={{ background: '#fff', borderRadius: 20, padding: 15, cursor: 'pointer', boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
      <div style={{ display: 'flex', gap: 13, alignItems: 'flex-start' }}>
        <div style={{ width: 54, height: 54, borderRadius: 16, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 30, flexShrink: 0 }}>{m.emoji}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 16.5, fontWeight: 800, color: T.ink, lineHeight: 1.3 }}>{m.name}</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7, marginTop: 9, alignItems: 'center' }}>
            <ApplianceBadge name={m.appliance} />
            <Meta icon="clock" text={`${m.time}分`} />
            <Meta icon="people" text={`${m.servings}人分`} />
          </div>
        </div>
      </div>
      <div style={{ marginTop: 12, fontSize: 12.5, fontWeight: 600, color: T.sub, lineHeight: 1.6 }}>
        使う食材：{m.main.map((x, i) => (
          <span key={x} style={{ color: NEAR_STOCK.includes(x) ? T.near : T.ink, fontWeight: 700 }}>{x}{i < m.main.length - 1 ? '・' : ''}</span>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 8, marginTop: 11, alignItems: 'center', flexWrap: 'wrap' }}>
        {m.useUp && <UseUpBadge />}
        {short > 0 && (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '4px 9px', borderRadius: 999, background: '#F1EEE7', color: T.sub, fontSize: 11.5, fontWeight: 700 }}>
            <Icon name="bag" size={13} color={T.sub} /> 買い物 {short}品
          </span>
        )}
        <div style={{ flex: 1 }} />
        <Icon name="chevron" size={18} color={T.faint} stroke={2.4} />
      </div>
    </div>
  );
}

// ── 3 / 4. Results (normal + low inventory) ──
function ResultsScreen({ meals, low, cond, setCond, onTap, onBack, onRegenerate }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ padding: `${T.statusPad}px 16px 8px` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={onBack} style={navBtn}><span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span></button>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: T.brand, fontSize: 22, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>献立の提案</div>
            <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 2 }}>在庫から{meals.length}件・条件「{cond}」</div>
          </div>
          <button onClick={onRegenerate} style={navBtn}><Icon name="refresh" size={19} color={T.ink} /></button>
        </div>
      </div>
      {/* notice */}
      <div style={{ padding: '6px 16px 2px' }}>
        {low ? (
          <div style={{ background: T.nearSoft, borderRadius: 14, padding: '12px 14px', display: 'flex', gap: 10 }}>
            <Icon name="bag" size={19} color={T.near} />
            <div style={{ fontSize: 12.5, fontWeight: 700, color: T.ink, lineHeight: 1.6 }}>在庫が少なめです。買い足し前提の新しい献立も提案しています。</div>
          </div>
        ) : (
          <div style={{ background: T.greenSoft, borderRadius: 14, padding: '12px 14px', display: 'flex', gap: 10 }}>
            <Icon name="spark" size={19} color={T.green} />
            <div style={{ fontSize: 12.5, fontWeight: 700, color: T.ink, lineHeight: 1.6 }}>期限が近い <b style={{ color: T.greenInk }}>牛乳・ほうれん草</b> を優先して選びました。</div>
          </div>
        )}
      </div>
      <div style={{ padding: '12px 0 6px' }}><ConditionChips value={cond} onPick={setCond} /></div>
      <div style={{ flex: 1, overflow: 'auto', padding: '6px 16px 24px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {meals.map((m) => <MealCard key={m.id} m={m} onTap={() => onTap(m.id)} />)}
      </div>
    </div>
  );
}
const navBtn = { width: 42, height: 42, borderRadius: 14, background: '#fff', cursor: 'pointer', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 };

// ── Detail (材料・手順) ──
function IngRow({ ing }) {
  let dot, label, color;
  if (!ing.have) { dot = 'bag'; label = '買う'; color = T.sub; }
  else if (ing.near) { dot = 'near'; label = '期限間近'; color = T.near; }
  else { dot = 'check'; label = '在庫'; color = T.green; }
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 0', borderBottom: `1px solid ${T.line}` }}>
      <span style={{ width: 24, height: 24, borderRadius: 99, background: dot === 'bag' ? '#F1EEE7' : (dot === 'near' ? T.nearSoft : T.greenSoft), display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        {dot === 'bag' ? <Icon name="bag" size={13} color={color} /> : dot === 'near' ? <span style={{ width: 7, height: 7, borderRadius: 99, background: T.near }} /> : <Icon name="check" size={13} color={T.green} stroke={3} />}
      </span>
      <span style={{ flex: 1, fontSize: 15, fontWeight: 700, color: ing.have ? T.ink : T.sub }}>{ing.n}</span>
      <span style={{ fontSize: 13.5, fontWeight: 700, color: T.sub, marginRight: 8 }}>{ing.a}</span>
      <span style={{ fontSize: 11.5, fontWeight: 700, color, minWidth: 52, textAlign: 'right' }}>{label}</span>
    </div>
  );
}
function DetailScreen({ m, onBack, onPick, onAddShopping }) {
  const short = shortageCount(m);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, overflow: 'auto' }}>
        <div style={{ padding: `${T.statusPad}px 16px 4px` }}>
          <button onClick={onBack} style={navBtn}><span style={{ transform: 'scaleX(-1)', display: 'flex' }}><Icon name="chevron" size={20} color={T.ink} /></span></button>
        </div>
        {/* hero */}
        <div style={{ padding: '10px 20px 4px', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ width: 92, height: 92, borderRadius: 28, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 48 }}>{m.emoji}</div>
          <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink, marginTop: 14, lineHeight: 1.3 }}>{m.name}</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 12, justifyContent: 'center' }}>
            <ApplianceBadge name={m.appliance} big />
            <Meta icon="clock" text={`${m.time}分`} />
            <Meta icon="people" text={`${m.servings}人分`} />
          </div>
          {m.useUp && <div style={{ marginTop: 10 }}><UseUpBadge big /></div>}
        </div>
        {/* ingredients */}
        <div style={{ margin: '20px 16px 0', background: '#fff', borderRadius: 20, padding: '6px 16px 14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 0 4px' }}>
            <span style={{ fontSize: 15, fontWeight: 800, color: T.ink }}>材料（{m.servings}人分）</span>
            {short > 0 && <span style={{ fontSize: 12, fontWeight: 700, color: T.near }}>買い足し {short}品</span>}
          </div>
          {m.ingredients.map((ing, i) => <IngRow key={i} ing={ing} />)}
          {short > 0 && (
            <button onClick={onAddShopping} style={{ width: '100%', height: 48, marginTop: 14, borderRadius: 14, cursor: 'pointer',
              background: '#fff', border: `1.5px solid ${T.green}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              fontFamily: T.font, fontSize: 14.5, fontWeight: 800, color: T.greenInk }}>
              <Icon name="bag" size={18} color={T.green} /> 不足 {short}品を買い物リストに追加
            </button>
          )}
        </div>
        {/* steps */}
        <div style={{ margin: '16px 16px 0', background: '#fff', borderRadius: 20, padding: '14px 16px 16px' }}>
          <div style={{ fontSize: 15, fontWeight: 800, color: T.ink, marginBottom: 12 }}>作り方</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {m.steps.map((s, i) => (
              <div key={i} style={{ display: 'flex', gap: 12 }}>
                <span style={{ width: 26, height: 26, borderRadius: 99, background: T.greenSoft, color: T.greenInk, fontSize: 13.5, fontWeight: 800, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{i + 1}</span>
                <span style={{ flex: 1, fontSize: 14.5, fontWeight: 500, color: T.ink, lineHeight: 1.7, paddingTop: 2 }}>{s}</span>
              </div>
            ))}
          </div>
        </div>
        <div style={{ height: 16 }} />
      </div>
      <div style={{ padding: '12px 16px 26px', background: `linear-gradient(to top, ${T.bg} 70%, transparent)` }}>
        <button onClick={onPick} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green,
          boxShadow: '0 12px 26px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          <Icon name="check" size={22} color="#fff" /> この献立にする
        </button>
      </div>
    </div>
  );
}

// ── Error ──
function MealError({ onRetry, onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.bg, fontFamily: T.font }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 30, textAlign: 'center' }}>
        <div style={{ width: 96, height: 96, borderRadius: 30, background: T.nearSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="wifi" size={44} color={T.near} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 21, fontWeight: 700, color: T.ink }}>提案を取得できませんでした</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: T.sub, lineHeight: 1.75, maxWidth: 268 }}>電波が弱いようです。電波の良い場所か<br />Wi-Fi に接続して、もう一度お試しください。</div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, padding: '0 16px 32px' }}>
        <button onClick={onRetry} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontFamily: T.font, fontSize: 16.5, fontWeight: 800, color: '#fff' }}>
          <Icon name="refresh" size={21} color="#fff" /> もう一度試す
        </button>
        <button onClick={onBack} style={{ width: '100%', height: 54, borderRadius: 16, cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>在庫にもどる</button>
      </div>
    </div>
  );
}

window.MealsPhone = { BeforeScreen, GeneratingScreen, ResultsScreen, DetailScreen, MealError };
