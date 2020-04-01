{
module Tokens where
}

%wrapper "posn"
$digit = 0-9
$alpha = [a-zA-Z]

tokens :-
  "--".* [\n] ;
  $white+ ;
  true           { tok (\p s -> TokenTrue p) }
  false          { tok (\p s -> TokenFalse p) }
  main           { tok (\p s -> TokenMain p) }
  if             { tok (\p s -> TokenIf p) }
  else           { tok (\p s -> TokenElse p) }
  whileInput     { tok (\p s -> TokenWhileInput p) }
  input          { tok (\p s -> TokenInput p) }
  output         { tok (\p s -> TokenOutput p) }
  "=="           { tok (\p s -> TokenCompEq p) }
  "<="           { tok (\p s -> TokenCompLTE p) }
  ">="           { tok (\p s -> TokenCompGTE p) }
  \<             { tok (\p s -> TokenCompLT p) }
  \>             { tok (\p s -> TokenCompGT p) }
  "!="           { tok (\p s -> TokenCompNE p) }
  \=             { tok (\p s -> TokenEq p) }
  \+             { tok (\p s -> TokenAdd p) }
  \-             { tok (\p s -> TokenMinus p) }
  \*             { tok (\p s -> TokenMultiply p) }
  \/             { tok (\p s -> TokenDivide p) }
  \%             { tok (\p s -> TokenMod p) }
  \{             { tok (\p s -> TokenLCurly p) }
  \}             { tok (\p s -> TokenRCurly p) }
  \(             { tok (\p s -> TokenLParen p) }
  \)             { tok (\p s -> TokenRParen p) }
  \[             { tok (\p s -> TokenLSquare p) }
  \]             { tok (\p s -> TokenRSquare p) }
  \,             { tok (\p s -> TokenComma p) }
  \;             { tok (\p s -> TokenEOS p) }
  $digit+        { tok (\p s -> TokenInt p (read s)) }
  $alpha [$alpha $digit \_ \']* { tok (\p s -> TokenIdentifier p s)}

{
tok :: (AlexPosn -> String -> Token) -> AlexPosn -> String -> Token
tok f p s = f p s

data Token =
  TokenTrue AlexPosn               |
  TokenFalse AlexPosn              |
  TokenMain AlexPosn               |
  TokenIf AlexPosn                 |
  TokenElse AlexPosn               |
  TokenWhileInput AlexPosn         |
  TokenInput AlexPosn              |
  TokenOutput AlexPosn             |
  TokenCompEq AlexPosn             |
  TokenCompLTE AlexPosn            |
  TokenCompGTE AlexPosn            |
  TokenCompLT AlexPosn             |
  TokenCompGT AlexPosn             |
  TokenCompNE AlexPosn             |
  TokenEq AlexPosn                 |
  TokenAdd AlexPosn                |
  TokenMinus AlexPosn              |
  TokenMultiply AlexPosn           |
  TokenDivide AlexPosn             |
  TokenMod AlexPosn                |
  TokenLCurly AlexPosn             |
  TokenRCurly AlexPosn             |
  TokenLParen AlexPosn             |
  TokenRParen AlexPosn             |
  TokenLSquare AlexPosn            |
  TokenRSquare AlexPosn            |
  TokenComma AlexPosn              |
  TokenEOS AlexPosn                |
  TokenInt AlexPosn Int            |
  TokenIdentifier AlexPosn String
  deriving (Show, Eq)

token_posn :: Token -> AlexPosn
token_posn (TokenTrue p)         = p
token_posn (TokenFalse p)        = p
token_posn (TokenMain p)         = p
token_posn (TokenIf p)           = p
token_posn (TokenElse p)         = p
token_posn (TokenWhileInput p)   = p
token_posn (TokenInput p)        = p
token_posn (TokenOutput p)       = p
token_posn (TokenCompEq p)       = p
token_posn (TokenCompLTE p)      = p
token_posn (TokenCompGTE p)      = p
token_posn (TokenCompLT p)       = p
token_posn (TokenCompGT p)       = p
token_posn (TokenCompNE p)       = p
token_posn (TokenEq p)           = p
token_posn (TokenAdd p)          = p
token_posn (TokenMinus p)        = p
token_posn (TokenMultiply p)     = p
token_posn (TokenDivide p)       = p
token_posn (TokenMod p)          = p
token_posn (TokenLCurly p)       = p
token_posn (TokenRCurly p)       = p
token_posn (TokenLParen p)       = p
token_posn (TokenRParen p)       = p
token_posn (TokenLSquare p)      = p
token_posn (TokenRSquare p)      = p
token_posn (TokenComma p)        = p
token_posn (TokenEOS p)          = p
token_posn (TokenInt p _)        = p
token_posn (TokenIdentifier p _) = p
}
