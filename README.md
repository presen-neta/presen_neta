# presen_neta

## プロジェクト概要

プレゼンのスライドを読み込んで、100人中何人が寝るほどつまらないか判定するネタスマホアプリ

---

## 技術スタック

- **フロントエンド**: Flutter（Dart）
- **状態管理**: hooks_riverpod
- **ルーティング**: go_router
- **CI/CD**: GitHub Actions
- **テスト**: Flutter Test, Mockito
- **ログ管理**: logger
- **ドキュメント管理**: Notion
- **デザイン**: Figma

---

## ページ構成

### StartPage

- プレゼンをしている人のイラスト
- 「100人中何人が寝るかな？」という大きなタイトル
- 振り返りを促すブロック（例：「目的ははっきりしている？」「文字ばかりじゃない？」「自分よがりじゃない？」）
- 「スライドをアップロード」ボタン
    - ファイル選択
    - AI解析中はリワード広告を表示

### ResultPage

- 結果画像（寝ている人のイラスト）
    - 簡潔な一言（例：「何が言いたいの？」「文字ばっかり！」「つまんない！」）
    - 何人が寝たか（例：「80%が寝た！」）
- シェアボタン
- ブラーがかかった「近日中に詳細評価を実装予定」のブロック
- 「別のスライドをアップロード」ボタン

---

## ディレクトリ構成（クリーンアーキテクチャ）

```
lib/
  app/        # アプリ全体の設定・ルーティング・DI・共通Widget等
  features/   # 各機能ごとのモジュール（UI/モデル/リポジトリ/サービス/プロバイダ等）
  shared/     # 共通リソース（モデル/リポジトリ/サービス/Widget/定数/例外等）
  main.dart   # エントリーポイント
test/         # テストコード
assets/       # 画像等のアセット
```

- **依存関係**: App → Feature → Shared のみ許可。Feature間の依存は禁止。Sharedはどこにも依存しない。

---

## 開発・運用ルール

- 各Featureは責務ごとにサブディレクトリを分ける
- 共通処理は `shared/` にまとめる
- 新規機能追加時は `features/` 配下にディレクトリを作成
- Providerは関連するRepositoryやServiceの実装ファイル内に定義
- 命名規則を統一

---

## 参考

- [Flutter App Architecture – a modular approach](https://deep5.io/en/flutter-app-architecture-a-modular-approach/)
- [Effective Dart: Directory Structure](https://dart.dev/guides/libraries/create-library-packages#directory-structure)
