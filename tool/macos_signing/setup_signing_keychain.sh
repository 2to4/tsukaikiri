#!/bin/zsh
# つかいきり: Claude Code シェル用の専用署名キーチェーンを作成する（1回だけ実行）
# あなたの通常のターミナル（Aqua セッション）で実行してください。
set -e

KC="$HOME/Library/Keychains/tsukaikiri-ci.keychain-db"
KCPASS=$(openssl rand -hex 16)
P12PASS=$(openssl rand -hex 8)
P12=$(mktemp /tmp/tsukaikiri-XXXXXX).p12

echo "==> 1/6 login キーチェーンから署名用 identity を書き出し（ダイアログが出たら許可してください）"
security export -k "$HOME/Library/Keychains/login.keychain-db" \
  -t identities -f pkcs12 -P "$P12PASS" -o "$P12"

echo "==> 2/6 専用キーチェーン tsukaikiri-ci を作成"
security delete-keychain "$KC" 2>/dev/null || true
security create-keychain -p "$KCPASS" "$KC"
security set-keychain-settings "$KC"   # 自動ロックなし

echo "==> 3/6 identity を取り込み（codesign からのアクセスを許可）"
security import "$P12" -k "$KC" -P "$P12PASS" \
  -T /usr/bin/codesign -T /usr/bin/security

echo "==> 4/6 partition list を設定（非対話で codesign が鍵を使えるように）"
security set-key-partition-list -S 'apple-tool:,apple:,codesign:' \
  -s -k "$KCPASS" "$KC" >/dev/null

echo "==> 5/6 キーチェーン検索リストに追加"
EXISTING=$(security list-keychains -d user | tr -d '" ')
security list-keychains -d user -s "$KC" ${(f)EXISTING}

echo "==> 6/6 パスワードを ~/.config/tsukaikiri/ci-keychain-pass に保存（chmod 600）"
mkdir -p "$HOME/.config/tsukaikiri"
printf '%s' "$KCPASS" > "$HOME/.config/tsukaikiri/ci-keychain-pass"
chmod 600 "$HOME/.config/tsukaikiri/ci-keychain-pass"

rm -f "$P12"

echo ""
echo "完了: tsukaikiri-ci キーチェーンの準備ができました"
security find-identity -v -p codesigning "$KC"
