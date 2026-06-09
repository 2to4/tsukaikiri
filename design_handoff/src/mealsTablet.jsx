// mealsTablet.jsx — 献立提案 タブレット二ペイン
const { T, Icon } = window;
const { MEALS, MEALS_LOW, shortageCount, ApplianceBadge, UseUpBadge, Meta, CONDITIONS } = window.Meals;
const CW = 1194, CH = 834;
const NEAR_STOCK = ['鶏むね肉', '牛乳', 'ほうれん草', '生鮭', 'ミニトマト'];

function CondChips({ value, onPick }) {
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
      {CONDITIONS.map((c) => {
        const on = value === c;
        return <button key={c} onClick={() => onPick(c)} style={{ border: 'none', cursor: 'pointer', padding: '8px 14px', borderRadius: 999, fontFamily: T.font, fontSize: 13.5, fontWeight: on ? 700 : 600, background: on ? T.green : '#fff', color: on ? '#fff' : T.sub, boxShadow: on ? 'none' : `inset 0 0 0 1px ${T.line}` }}>{c}</button>;
      })}
    </div>
  );
}

// ── left: before prompt ──
function BeforePrompt({ cond, setCond, onGenerate }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '32px 26px 6px' }}>
        <div style={{ fontFamily: T.brand, fontSize: 27, fontWeight: 700, color: T.ink }}>献立の提案</div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.sub, marginTop: 5 }}>在庫から、使い切りメニューを考えます</div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '16px 24px 8px' }}>
        <div style={{ background: '#fff', borderRadius: 18, padding: 16, boxShadow: '0 1px 2px rgba(40,39,35,0.04)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 9, height: 9, borderRadius: 99, background: T.near }} />
            <span style={{ fontSize: 14, fontWeight: 800, color: T.ink }}>期限が近い <span style={{ color: T.near }}>5品</span> を使い切れます</span>
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7, marginTop: 12 }}>
            {NEAR_STOCK.map((n) => <span key={n} style={{ padding: '5px 11px', borderRadius: 999, background: T.nearSoft, color: T.near, fontSize: 12.5, fontWeight: 700 }}>{n}</span>)}
          </div>
        </div>
        <div style={{ fontSize: 13.5, fontWeight: 800, color: T.ink, margin: '22px 2px 12px' }}>どんな献立にする？</div>
        <CondChips value={cond} onPick={setCond} />
      </div>
      <div style={{ padding: '14px 24px 24px', borderTop: `1px solid ${T.line}` }}>
        <button onClick={onGenerate} style={{ width: '100%', height: 62, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          <Icon name="spark" size={23} color="#fff" /> 在庫から提案する
        </button>
      </div>
    </div>
  );
}

// ── left: results list ──
function MealRow({ m, selected, onSelect }) {
  const short = shortageCount(m);
  return (
    <div onClick={onSelect} style={{ display: 'flex', gap: 12, alignItems: 'center', padding: '12px 13px', borderRadius: 16, cursor: 'pointer',
      background: selected ? T.greenSoft : '#fff', boxShadow: selected ? `inset 0 0 0 2px ${T.green}` : '0 1px 2px rgba(40,39,35,0.04)' }}>
      <div style={{ width: 48, height: 48, borderRadius: 14, background: selected ? '#fff' : T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26, flexShrink: 0 }}>{m.emoji}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15.5, fontWeight: 800, color: T.ink, lineHeight: 1.25 }}>{m.name}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6, flexWrap: 'wrap' }}>
          <ApplianceBadge name={m.appliance} />
          <Meta icon="clock" text={`${m.time}分`} />
          {m.useUp && <span style={{ width: 7, height: 7, borderRadius: 99, background: T.near }} title="期限間近を使う" />}
          {short > 0 && <span style={{ fontSize: 11, fontWeight: 700, color: T.sub }}>買い物{short}</span>}
        </div>
      </div>
      <Icon name="chevron" size={17} color={T.faint} stroke={2.4} />
    </div>
  );
}
function ResultsList({ meals, low, cond, setCond, selId, setSel, onRegenerate }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '26px 22px 10px' }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 10 }}>
          <div>
            <div style={{ fontFamily: T.brand, fontSize: 23, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>献立の提案</div>
            <div style={{ fontSize: 12.5, fontWeight: 600, color: T.sub, marginTop: 3 }}>在庫から{meals.length}件 ・ 条件「{cond}」</div>
          </div>
          <button onClick={onRegenerate} title="再提案" style={{ width: 42, height: 42, borderRadius: 14, background: '#fff', border: `1.5px solid ${T.line}`, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="refresh" size={19} color={T.ink} /></button>
        </div>
        <div style={{ marginTop: 12 }}>
          {low ? (
            <div style={{ background: T.nearSoft, borderRadius: 12, padding: '10px 13px', display: 'flex', gap: 9 }}><Icon name="bag" size={17} color={T.near} /><div style={{ fontSize: 12, fontWeight: 700, color: T.ink, lineHeight: 1.6 }}>在庫が少なめ。買い足し前提の献立も提案しています。</div></div>
          ) : (
            <div style={{ background: T.greenSoft, borderRadius: 12, padding: '10px 13px', display: 'flex', gap: 9 }}><Icon name="spark" size={17} color={T.green} /><div style={{ fontSize: 12, fontWeight: 700, color: T.ink, lineHeight: 1.6 }}>期限が近い <b style={{ color: T.greenInk }}>牛乳・ほうれん草</b> を優先しました。</div></div>
          )}
        </div>
        <div style={{ marginTop: 12 }}><CondChips value={cond} onPick={setCond} /></div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '4px 16px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {meals.map((m) => <MealRow key={m.id} m={m} selected={selId === m.id} onSelect={() => setSel(m.id)} />)}
      </div>
    </div>
  );
}

// ── right: detail (materials + steps) ──
function IngRow({ ing }) {
  let kind, label, color;
  if (!ing.have) { kind = 'bag'; label = '買う'; color = T.sub; }
  else if (ing.near) { kind = 'near'; label = '期限間近'; color = T.near; }
  else { kind = 'check'; label = '在庫'; color = T.green; }
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '11px 0', borderBottom: `1px solid ${T.line}` }}>
      <span style={{ width: 24, height: 24, borderRadius: 99, background: kind === 'bag' ? '#F1EEE7' : (kind === 'near' ? T.nearSoft : T.greenSoft), display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        {kind === 'bag' ? <Icon name="bag" size={13} color={color} /> : kind === 'near' ? <span style={{ width: 7, height: 7, borderRadius: 99, background: T.near }} /> : <Icon name="check" size={13} color={T.green} stroke={3} />}
      </span>
      <span style={{ flex: 1, fontSize: 14.5, fontWeight: 700, color: ing.have ? T.ink : T.sub }}>{ing.n}</span>
      <span style={{ fontSize: 13, fontWeight: 700, color: T.sub, marginRight: 6 }}>{ing.a}</span>
      <span style={{ fontSize: 11, fontWeight: 700, color, minWidth: 50, textAlign: 'right' }}>{label}</span>
    </div>
  );
}
function DetailPane({ m, onPick, onAddShopping }) {
  if (!m) {
    return (
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, color: T.faint, textAlign: 'center', padding: 40 }}>
        <div style={{ width: 90, height: 90, borderRadius: 28, background: '#fff', border: `1.5px solid ${T.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="book" size={38} color={T.faint} /></div>
        <div style={{ fontFamily: T.brand, fontSize: 18, fontWeight: 700, color: T.sub }}>献立を選んでください</div>
        <div style={{ fontSize: 13.5, fontWeight: 500, lineHeight: 1.7, maxWidth: 260 }}>左の候補をタップすると、材料と作り方がここに表示されます。</div>
      </div>
    );
  }
  const short = shortageCount(m);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '34px 40px 20px' }}>
        {/* hero */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 22 }}>
          <div style={{ width: 104, height: 104, borderRadius: 30, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 54, flexShrink: 0 }}>{m.emoji}</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: T.brand, fontSize: 28, fontWeight: 700, color: T.ink, lineHeight: 1.2 }}>{m.name}</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 9, marginTop: 12, alignItems: 'center' }}>
              <ApplianceBadge name={m.appliance} big />
              <Meta icon="clock" text={`${m.time}分`} />
              <Meta icon="people" text={`${m.servings}人分`} />
              {m.useUp && <UseUpBadge big />}
            </div>
          </div>
        </div>
        {/* two columns */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 26, marginTop: 26 }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
              <span style={{ fontSize: 16, fontWeight: 800, color: T.ink }}>材料（{m.servings}人分）</span>
              {short > 0 && <span style={{ fontSize: 12.5, fontWeight: 700, color: T.near }}>買い足し {short}品</span>}
            </div>
            {m.ingredients.map((ing, i) => <IngRow key={i} ing={ing} />)}
            {short > 0 && (
              <button onClick={onAddShopping} style={{ width: '100%', height: 48, marginTop: 14, borderRadius: 14, cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.green}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, fontFamily: T.font, fontSize: 14, fontWeight: 800, color: T.greenInk }}>
                <Icon name="bag" size={17} color={T.green} /> 不足 {short}品を買い物リストに追加
              </button>
            )}
          </div>
          <div>
            <div style={{ fontSize: 16, fontWeight: 800, color: T.ink, marginBottom: 14 }}>作り方</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
              {m.steps.map((s, i) => (
                <div key={i} style={{ display: 'flex', gap: 12 }}>
                  <span style={{ width: 26, height: 26, borderRadius: 99, background: T.greenSoft, color: T.greenInk, fontSize: 13.5, fontWeight: 800, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{i + 1}</span>
                  <span style={{ flex: 1, fontSize: 14.5, fontWeight: 500, color: T.ink, lineHeight: 1.7, paddingTop: 2 }}>{s}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '16px 40px 24px', borderTop: `1px solid ${T.line}` }}>
        <button onClick={onPick} style={{ width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, fontFamily: T.font, fontSize: 17, fontWeight: 800, color: '#fff' }}>
          <Icon name="check" size={22} color="#fff" /> この献立にする
        </button>
      </div>
    </div>
  );
}

// ── full-frame: generating / error ──
function GeneratingFull({ cond, onCancel }) {
  const steps = ['在庫を確認中', '期限の近い食材を優先', 'レシピを選定中'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, background: T.bg, padding: 40, textAlign: 'center', position: 'relative' }}>
      <div className="cam-pulse" style={{ width: 104, height: 104, borderRadius: 32, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 6 }}><Icon name="spark" size={48} color={T.green} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 26, fontWeight: 700, color: T.ink }}>献立を考えています</div>
      <div style={{ fontSize: 15, fontWeight: 600, color: T.sub }}>条件「{cond}」・在庫の食材から選んでいます</div>
      <div style={{ width: 260, height: 7, borderRadius: 99, background: '#E6E2D9', overflow: 'hidden', marginTop: 16 }}><div className="cam-bar" style={{ height: '100%', borderRadius: 99, background: T.green }} /></div>
      <div style={{ display: 'flex', gap: 26, marginTop: 22 }}>
        {steps.map((s, i) => (
          <div key={s} className="cam-step" style={{ animationDelay: `${i * 0.7}s`, display: 'flex', alignItems: 'center', gap: 8, fontSize: 13.5, fontWeight: 600, color: T.sub }}>
            <span style={{ width: 18, height: 18, borderRadius: 99, background: T.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="check" size={12} color={T.green} stroke={3} /></span>{s}
          </div>
        ))}
      </div>
      <button onClick={onCancel} style={{ position: 'absolute', bottom: 34, background: 'none', border: 'none', cursor: 'pointer', fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.sub }}>キャンセル</button>
    </div>
  );
}
function ErrorFull({ onRetry, onBack }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, background: T.bg, padding: 40, textAlign: 'center' }}>
      <div style={{ width: 104, height: 104, borderRadius: 32, background: T.nearSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}><Icon name="wifi" size={48} color={T.near} /></div>
      <div style={{ fontFamily: T.brand, fontSize: 25, fontWeight: 700, color: T.ink }}>提案を取得できませんでした</div>
      <div style={{ fontSize: 15.5, fontWeight: 500, color: T.sub, lineHeight: 1.75, maxWidth: 360 }}>電波が弱いようです。電波の良い場所か Wi-Fi に接続して、もう一度お試しください。</div>
      <div style={{ display: 'flex', gap: 12, marginTop: 26 }}>
        <button onClick={onBack} style={{ height: 58, borderRadius: 18, padding: '0 26px', cursor: 'pointer', background: '#fff', border: `1.5px solid ${T.line}`, fontFamily: T.font, fontSize: 15.5, fontWeight: 700, color: T.ink }}>在庫にもどる</button>
        <button onClick={onRetry} style={{ height: 58, borderRadius: 18, padding: '0 30px', cursor: 'pointer', border: 'none', background: T.green, boxShadow: '0 12px 26px rgba(31,122,85,0.28)', display: 'flex', alignItems: 'center', gap: 9, fontFamily: T.font, fontSize: 16, fontWeight: 800, color: '#fff' }}><Icon name="refresh" size={21} color="#fff" /> もう一度試す</button>
      </div>
    </div>
  );
}

window.MealsTablet = { BeforePrompt, ResultsList, DetailPane, GeneratingFull, ErrorFull, CW, CH };
