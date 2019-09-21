# Monkey
## Summary
- 「Goで作るインタプリタ」を`Swift`で実装する

## reference
- [Goで作るインタプリタ](https://www.amazon.co.jp/Go%E8%A8%80%E8%AA%9E%E3%81%A7%E3%81%A4%E3%81%8F%E3%82%8B%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%97%E3%83%AA%E3%82%BF-Thorsten-Ball/dp/4873118220)

## history
- xcodeで補完がされない現象を解消(2019/8/9)
- tokenを実装(2019/?/?)
- WIP: lexer実装(paren, brace, =+等のoperator, 変数を取得可能, whitespeceをスキップ)　(2019/9/14)
- lexer実装, 数値リテラルからトークンを取得 (2019/9/19)
- lexer実装, `==`, `!=`をトークンとして取得 (2019/9/19)
- repl実装 (2019/9/20)

## swiftPM
- `$ mkdir {projectName}`: プロジェクトディレクトリ作成
- `$ swift package init --type executable`: swiftPMで初期化, executable指定でmainが作成される
- `$ swift generate-xcodeproj`: xcodeproj作成
