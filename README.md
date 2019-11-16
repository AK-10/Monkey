# Monkey
## Summary
- 「Goで作るインタプリタ」を`Swift`で実装する
- テストは実装していない（なんかうまく動かなかった）
## reference
- [Goで作るインタプリタ](https://www.amazon.co.jp/Go%E8%A8%80%E8%AA%9E%E3%81%A7%E3%81%A4%E3%81%8F%E3%82%8B%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%97%E3%83%AA%E3%82%BF-Thorsten-Ball/dp/4873118220)

## history
- xcodeで補完がされない現象を解消(2019/8/9)
- tokenを実装(2019/?/?)
- WIP: lexer実装(paren, brace, =+等のoperator, 変数を取得可能, whitespeceをスキップ)　(2019/9/14)
- lexer実装, 数値リテラルからトークンを取得 (2019/9/19)
- lexer実装, `==`, `!=`をトークンとして取得 (2019/9/19)
- repl実装 (2019/9/20)
- parser実装取り掛かり(2019/10/14)
  - Node, Statement, Expressionプロトコルを記述
  - Program構造体を実装
    - Programはparserが生成するASTのルートノードになる
    - `let x = 10; let y = 20;`が与えられた場合，以下のようになると思っていい
```
      program -+- let --+-- identifier(x)
               |        |
               |        |-- value(int: 10)
               |
               |- let --+-- identifier(y)
                        |
                        |-- value(int: 20)
```

- LetStatementのパース(2019/10/17)
  - let文のBNF(?)

```bnf
<letStatement> ::= let <identifier> = <expression>

```
  - tokenをparseし，うえのBNFを満たす場合LetStatementを返す.

- ReturnStetementのパース(2019/10/18)
  - return文のBNF(?)

```bnf
<returnStatement> ::= return <expression>
```
  - tokenをparseし，うえのBNFを満たす場合LetStatementを返す.

- 式のパース(2019/10/26)
    - pratt構文解析
        - tokentypeごとにparse関数(semantic code)を呼ぶ
        - 適切な式を構文解析し，その式をg表現するASTを返す．
        - parse関数は最大二つ(prefix operator, infix operator)
    - infix

```bnf
<expression> <in operator> <expression>
```

- prefix

```bnf
<pre opertor> <expression>
```

- 前置オペレータのparse (2019/11/4)
  - parsePrefixOperatorメソッドをparseExpressionに食わせるだけ

- 関数のトレース (2019/11/12)
  - (10 + 4 * 3) に対するparseStatementのトレース
```
Monkey >> 10 + 4 * 3;
invoke: parseStatement
invoke: parseExpression(rootToken = <int: 10>)
invoke: parseIntegerLiteral(left = 10)

-- parseExpression
peekToken: Monkey.Token(type: Monkey.TokenType.plus, literal: "+")
precedence: lowest, peekPrecedence: sum
precedence < peekPrecedence: true <- 右結合
--

invoke: parseInfixExpression
invoke: parseExpression
invoke: parseIntegerLiteral(left = 4)

-- parseExpression
peekToken: Monkey.Token(type: Monkey.TokenType.asterisk, literal: "*")
precedence: sum, peekPrecedence: product
precedence < peekPrecedence: true <- 右結合
--

invoke: parseInfixExpression(infix: *, left = 4) curToken: * -> 3
invoke: parseExpression() curToken: 3
invoke: parseIntegerLiteral(3)
invoke: parseExpressionStatement
invoke: parseStatement
infix operator: (Int: 10 + infix operator: (Int: 4 * Int: 4))


Monkey >> 1 + 2 + 3;
invoke: parseStatement
invoke: parseExpression(rootToken = <int: 1>)
invoke: parseIntegerLiteral

-- parseExpression
peekToken: Monkey.Token(type: Monkey.TokenType.plus, literal: "+")
precedence: lowest, peekPrecedence: sum
precedence < peekPrecedence: true <- 右結合
--

invoke: parseInfixExpression
invoke: parseExpression
invoke: parseIntegerLiteral

-- parseExpression
peekToken: Monkey.Token(type: Monkey.TokenType.plus, literal: "+")
precedence: sum, peekPrecedence: sum
precedence < peekPrecedence: false <- 左結合
--

invoke: parseInfixExpression
invoke: parseExpression
invoke: parseIntegerLiteral
invoke: parseExpressionStatement
invoke: parseStatement
infix operator: (infix operator: (Int: 1 + Int: 2) + Int: 3)
```
  - `precedence < peekPrecedence()` が成り立つ場合右結合
    - 右結合の場合，現在評価している値が右側の演算子の演算対象として評価される
      - `... n + 2 * m ...;`の現在のトークンが`2`の時を考えると, 右結合の場合 2 * mとして扱われる(右側の演算子に吸い込まれる).

- booleanリテラル(true, false)のパース(2019/11/13)
- `()`のパース(2019/11/13)
  - `(<expression>)` なので `(`が現在のトークンになったタイミングでトークンを次に進めて`parseExpression`呼び出し
  - 最後が`)`じゃなかったらエラー( 今は参考書に倣って`nil`を返している)

- if式のパース (2019/11/15)
  - bnfは以下のようになる
  
```bnf
if (condition) <consequence> else <alternative>
```
  - if式の例
  
```
if (x > y) {
  return x;
} else {
  return y;
}

# elseは省略できる
if (x > y) {
  return x;
}

```
  - if式は最後に評価された値を返す.
    - return はなくても良い

- 関数リテラルのパース(2019/11/17)
  - 関数リテラルのbnf
    
```
fn <parameters> <block statement>    
<parameters> := (<parameter one>, <parameter two>, ...)
```
  -関数リテラルの例
```
fn() {
  return foobar + barfoo;
}
```


## swiftPM
- `$ mkdir {projectName}`: プロジェクトディレクトリ作成
- `$ swift package init --type executable`: swiftPMで初期化, executable指定でmainが作成される
- `$ swift generate-xcodeproj`: xcodeproj作成


## Swiftで書き直すに当たって
- ASTはenum(代数的データ型)で書き換えれそう
- なんとなくのメモ(あとでちゃんと書く)

statement
```swift
enum Statement {
  case _return(value: Expression)
  case _let()
  case expression()
```

expression
```swift
enum Expression {
  case
```
