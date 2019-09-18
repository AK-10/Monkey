import Foundation

print("Hello, world!")

let input = """
let five = 5;
let ten = 10;
let add = fn(x, y) {
  x + y;
};

let result = add(five, ten);
"""

//let input = "=+(){},;"
let lexer = Lexer(_input: input)

while let token = lexer.nextToken() {
   print(token)
}


