{
module Grammar where
import Tokens
}

%name parseSPL
%tokentype { Token }
%error { parseSPLError }

-- Tokens
%token
    true          { TokenTrue _ }
    false         { TokenFalse _ }
    if            { TokenIf _ }
    else          { TokenElse _ }
    whileinput    { TokenWhileInput _ }
    input         { TokenInput _ }
    output        { TokenOutput _ }
    '=='          { TokenCompEq _ }
    '<='          { TokenCompLTE _ }
    '>='          { TokenCompGTE _ }
    '<'           { TokenCompLT _ }
    '>'           { TokenCompGT _ }
    '!='          { TokenCompNE _ }
    '='           { TokenEq _ }
    '+'           { TokenAdd _ }
    '-'           { TokenMinus _ }
    '*'           { TokenMultiply _ }
    '/'           { TokenDivide _ }
    '%'           { TokenMod _ }
    ','           { TokenComma _ }
    '{'           { TokenLCurly _ }
    '}'           { TokenRCurly _ }
    '('           { TokenLParen _ }
    ')'           { TokenRParen _ }
    '['           { TokenLSquare _ }
    ']'           { TokenRSquare _ }
    ';'           { TokenEOS _ }
    int           { TokenInt _ $$ }
    identifier    { TokenIdentifier _ $$ }

-- Precedence
%right '='
%left '==' '!='
%left '<' '<=' '>' '>='
%left '+' '-'
%left '*' '/' '%'
%left NEG
%%
-- BNF
ExpList : Exp                                                      { ExpSingle $1 }
        | ExpList Exp                                              { ExpMulti $1 (ExpSingle $2) }

Exp : if '(' ExpNoEOS ')' '{' ExpList '}' else '{' ExpList '}'     { If $3 $6 $10 }
    | whileinput '{' ExpList '}'                                   { WhileInput $3 }
    | input '[' ExpNoEOS ']' ';'                                   { Input $3 }
    | output '(' OutputList ')' ';'                                { Output $3 }
    | Exp '==' Exp                                                 { Eq $1 $3 }
    | Exp '<=' Exp                                                 { LessThanEqual $1 $3 }
    | Exp '>=' Exp                                                 { GreaterThanEqual $1 $3 }
    | Exp '<' Exp                                                  { LessThan $1 $3 }
    | Exp '>' Exp                                                  { GreaterThan $1 $3 }
    | Exp '!=' Exp                                                 { NotEqual $1 $3 }
    | ExpNoEOS '+' ExpNoEOS ';'                                    { Add $1 $3 }
    | ExpNoEOS '-' ExpNoEOS ';'                                    { Minus $1 $3 }
    | ExpNoEOS '*' ExpNoEOS ';'                                    { Multiply $1 $3 }
    | ExpNoEOS '/' ExpNoEOS ';'                                    { Divide $1 $3 }
    | ExpNoEOS '%' ExpNoEOS ';'                                    { Modulo $1 $3 }
    | identifier '=' ExpNoEOS ';'                                  { Decl $1 $3 }
    | '(' Exp ')' ';'                                              { $2 }

ExpNoEOS : input '[' ExpNoEOS ']'                                  { Input $3 }
         | output '(' OutputList ')'                               { Output $3 }
         | ExpNoEOS '==' ExpNoEOS                                  { Eq $1 $3 }
         | ExpNoEOS '<=' ExpNoEOS                                  { LessThanEqual $1 $3 }
         | ExpNoEOS '>=' ExpNoEOS                                  { GreaterThanEqual $1 $3 }
         | ExpNoEOS '<' ExpNoEOS                                   { LessThan $1 $3 }
         | ExpNoEOS '>' ExpNoEOS                                   { GreaterThan $1 $3 }
         | ExpNoEOS '!=' ExpNoEOS                                  { NotEqual $1 $3 }
         | ExpNoEOS '+' ExpNoEOS                                   { Add $1 $3 }
         | ExpNoEOS '-' ExpNoEOS                                   { Minus $1 $3 }
         | ExpNoEOS '*' ExpNoEOS                                   { Multiply $1 $3 }
         | ExpNoEOS '/' ExpNoEOS                                   { Divide $1 $3 }
         | ExpNoEOS '%' ExpNoEOS                                   { Modulo $1 $3 }
         | '-' ExpNoEOS %prec NEG                                  { Negate $2 }
         | '(' ExpNoEOS ')'                                        { $2 }
         | true                                                    { BoolTrue }
         | false                                                   { BoolFalse }
         | int                                                     { Integer $1 }
         | identifier                                              { Var $1 }

OutputList : ExpNoEOS                                              { OutputSingle $1 }
	       | ExpNoEOS OutputListPrime                              { OutputMulti (OutputSingle $1) $2 }

OutputListPrime : ',' ExpNoEOS                                     { OutputSingle $2 }
                | ',' ExpNoEOS OutputListPrime                     { OutputMulti (OutputSingle $2) $3 }

{
-- Error Function
parseSPLError :: [Token] -> a
parseSPLError [] = error "Parse error at EOL"
parseSPLError (t:_) = error ("Parse error at " ++ (show $ token_posn t) ++ " for " ++ (show t))

-- AST Expressions
data ExpList = ExpSingle Exp
             | ExpMulti ExpList ExpList
             deriving (Show, Eq)

data Exp = If Exp ExpList ExpList
         | WhileInput ExpList
         | Input Exp
         | Output OutputList
         | OutputExp [Exp]
         | Eq Exp Exp
         | LessThanEqual Exp Exp
         | GreaterThanEqual Exp Exp
         | LessThan Exp Exp
         | GreaterThan Exp Exp
         | NotEqual Exp Exp
         | Add Exp Exp
         | Minus Exp Exp
         | Multiply Exp Exp
         | Divide Exp Exp
         | Modulo Exp Exp
         | Negate Exp
         | Decl String Exp
         | BoolTrue
         | BoolFalse
         | Integer Int
         | Var String
         deriving (Show, Eq)

data OutputList = OutputSingle Exp
                | OutputMulti OutputList OutputList
                deriving (Show, Eq)
}