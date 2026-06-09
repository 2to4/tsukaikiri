// meals.jsx — 献立提案データ + 共通バッジ
const { T, Icon } = window;

const APPLIANCES = {
  '通常':       { label: '通常',       icon: 'flame', bg: '#EEEBE3', fg: '#6E685C' },
  'ホットクック': { label: 'ホットクック', icon: 'pot',   bg: T.greenSoft, fg: T.greenInk },
  'ヘルシオ':   { label: 'ヘルシオ',   icon: 'oven',  bg: '#E7EEF0', fg: '#42606B' },
};
const CONDITIONS = ['おまかせ', '主菜だけ', 'あと1品', '時短', '使い切り優先'];

// have: 在庫あり / near: 期限が近い在庫 / false: 買い足し必要
const MEALS = [
  {
    id: 'm1', name: '鶏むね肉とほうれん草のうま塩炒め', emoji: '🍳', appliance: '通常', time: 15, servings: 2, useUp: true, kind: 'main',
    main: ['鶏むね肉', 'ほうれん草', 'にんじん'],
    ingredients: [
      { n: '鶏むね肉', a: '2枚', have: true, near: true }, { n: 'ほうれん草', a: '1袋', have: true, near: true },
      { n: 'にんじん', a: '1/3本', have: true }, { n: 'にんにく', a: '1片', have: true },
      { n: 'ごま油', a: '大さじ1', have: true }, { n: '塩・こしょう', a: '少々', have: true },
    ],
    steps: ['鶏むね肉はそぎ切りにし、塩を軽くふる。', '野菜は食べやすい大きさに切る。', 'フライパンでにんにくを熱し、鶏肉を焼く。', 'ほうれん草・にんじんを加えて炒め合わせる。', '塩こしょうとごま油で味を整えて完成。'],
  },
  {
    id: 'm2', name: 'ほうれん草と牛乳のクリーム煮', emoji: '🥛', appliance: 'ヘルシオ', time: 20, servings: 2, useUp: true, kind: 'main',
    main: ['牛乳', 'ほうれん草', 'バター'],
    ingredients: [
      { n: '牛乳', a: '200ml', have: true, near: true }, { n: 'ほうれん草', a: '1/2袋', have: true, near: true },
      { n: 'バター', a: '10g', have: true }, { n: '小麦粉', a: '大さじ1', have: true },
      { n: 'コンソメ', a: '小さじ1', have: true }, { n: '塩', a: '少々', have: true },
    ],
    steps: ['ほうれん草をゆでて水気を絞り、ざく切りにする。', 'バターを溶かし小麦粉を炒める。', '牛乳を少しずつ加えてのばす。', 'コンソメとほうれん草を加えて煮る。', '塩で味を整える。'],
  },
  {
    id: 'm3', name: '鮭のちゃんちゃん焼き', emoji: '🐟', appliance: 'ホットクック', time: 25, servings: 2, useUp: true, kind: 'main',
    main: ['生鮭', 'にんじん', '味噌'],
    ingredients: [
      { n: '生鮭', a: '2切れ', have: true, near: true }, { n: 'にんじん', a: '1/3本', have: true },
      { n: '味噌', a: '大さじ1.5', have: true }, { n: 'みりん', a: '大さじ1', have: true },
      { n: 'バター', a: '10g', have: true }, { n: 'キャベツ', a: '2枚', have: false },
    ],
    steps: ['鮭と野菜を食べやすく切る。', '味噌・みりんを合わせてタレを作る。', '内鍋に野菜→鮭→タレ→バターの順に入れる。', '加熱を開始する（自動調理）。', '全体を混ぜて完成。'],
  },
  {
    id: 'm4', name: 'ミニトマトとふわふわ卵の炒め', emoji: '🍅', appliance: '通常', time: 10, servings: 2, useUp: true, kind: 'sub',
    main: ['ミニトマト', '卵'],
    ingredients: [
      { n: 'ミニトマト', a: '8個', have: true, near: true }, { n: '卵', a: '3個', have: true },
      { n: 'ごま油', a: '小さじ1', have: true }, { n: '塩', a: '少々', have: true }, { n: '小ねぎ', a: '少々', have: false },
    ],
    steps: ['卵を溶き、塩少々を混ぜる。', '熱したフライパンで卵を半熟に炒め、取り出す。', 'ミニトマトをさっと炒める。', '卵を戻して大きく混ぜる。', '塩で味を整える。'],
  },
];

const MEALS_LOW = [
  {
    id: 'l1', name: '基本のチキンカレー', emoji: '🍛', appliance: 'ホットクック', time: 40, servings: 4, useUp: false, kind: 'main',
    main: ['鶏もも肉', '玉ねぎ', 'にんじん'],
    ingredients: [
      { n: 'にんじん', a: '1本', have: true }, { n: '鶏もも肉', a: '300g', have: false }, { n: '玉ねぎ', a: '2個', have: false },
      { n: 'じゃがいも', a: '2個', have: false }, { n: 'カレールー', a: '1/2箱', have: false }, { n: '米', a: '2合', have: true },
    ],
    steps: ['野菜と肉を一口大に切る。', '内鍋にすべて入れる。', 'カレー（自動）で加熱する。', 'ルーを溶かしてさらに加熱。', 'ご飯とともに盛り付ける。'],
  },
  {
    id: 'l2', name: 'ふんわり親子丼', emoji: '🍚', appliance: '通常', time: 20, servings: 2, useUp: true, kind: 'main',
    main: ['卵', '鶏もも肉', '玉ねぎ'],
    ingredients: [
      { n: '卵', a: '3個', have: true, near: false }, { n: '鶏もも肉', a: '200g', have: false }, { n: '玉ねぎ', a: '1個', have: false },
      { n: 'ご飯', a: '2杯', have: false }, { n: '麺つゆ', a: '大さじ3', have: true },
    ],
    steps: ['鶏肉と玉ねぎを切る。', '麺つゆと水で煮る。', '溶き卵を回し入れる。', '半熟で火を止める。', 'ご飯にのせる。'],
  },
  {
    id: 'l3', name: '野菜たっぷり豚汁', emoji: '🍲', appliance: 'ホットクック', time: 30, servings: 4, useUp: true, kind: 'sub',
    main: ['にんじん', '豚肉', '大根'],
    ingredients: [
      { n: 'にんじん', a: '1/2本', have: true }, { n: '味噌', a: '大さじ3', have: true }, { n: '豚肉', a: '150g', have: false },
      { n: '大根', a: '1/4本', have: false }, { n: 'ごぼう', a: '1/2本', have: false }, { n: '長ねぎ', a: '1本', have: false },
    ],
    steps: ['野菜と豚肉を切る。', '内鍋に具材と水を入れる。', 'スープ（自動）で加熱する。', '味噌を溶き入れる。', 'ねぎを散らす。'],
  },
];

const shortageCount = (m) => m.ingredients.filter((i) => !i.have).length;

// ── badges ──
function ApplianceBadge({ name, big }) {
  const a = APPLIANCES[name];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: big ? '6px 12px' : '4px 9px', borderRadius: 999, background: a.bg, flexShrink: 0 }}>
      <Icon name={a.icon} size={big ? 17 : 14} color={a.fg} stroke={1.9} />
      <span style={{ fontSize: big ? 13 : 11.5, fontWeight: 700, color: a.fg }}>{a.label}</span>
    </span>
  );
}
function UseUpBadge({ big }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: big ? '6px 12px' : '4px 9px', borderRadius: 999, background: T.nearSoft, flexShrink: 0 }}>
      <span style={{ width: big ? 7 : 6, height: big ? 7 : 6, borderRadius: 99, background: T.near }} />
      <span style={{ fontSize: big ? 13 : 11.5, fontWeight: 700, color: T.near }}>期限間近を使う</span>
    </span>
  );
}
function Meta({ icon, text }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: 12.5, fontWeight: 700, color: T.sub }}>
      <Icon name={icon} size={15} color={T.faint} stroke={2} />{text}
    </span>
  );
}

window.Meals = { APPLIANCES, CONDITIONS, MEALS, MEALS_LOW, shortageCount, ApplianceBadge, UseUpBadge, Meta };
