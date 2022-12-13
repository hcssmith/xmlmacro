package xpath


Expression :: [dynamic]QueryToken

// AST
// Append to EXP
// if AND/OR
// Add EXP to BRANCH, Add COMPOPERATOR
// BEGIN APPENDING to EXP.
// Add EXP to BRANCH once finished

AST :: struct {
  Exp: Expression,
  Branch: [dynamic]Branch,
  IsBrancher: bool,
}

Branch :: union {
  Expression,
  OperatorToken,
}

QueryToken :: union {
  SyntaxToken,
  FunctionToken,
  OperatorToken,
  PredicateToken,
  Expression,
  string,
}


SyntaxToken :: enum {
  Child,      // /
  Descendant, // //
  Relative,   // ./
  Attr,       // @
  Node,       // node()
  Union,      // |
}



FunctionToken :: enum {
  Boolean,
  Ceiling,
  Choose,
  Concat,
  Contains,
  Count,
  Elementavailable,
  False,
  Floor,
  Functionavailable,
  Id,
  Lang,
  Last,
  Localname,
  Name,
  Namespaceuri,
  Normalizespace,
  Not,
  Number,
  Position,
  Round,
  Startswith,
  String,
  Stringlength,
  Substring,
  Substringafter,
  Substringbefore,
  Sum,
  Translate,
  True,
  Unparsedentityurl,
}

OperatorToken :: enum {
  Eq,
  Mt,
  Lt,
  NEq,
  And,
  Or,
}

PredicateToken :: enum {
  Start,  // [
  End,    // ]
}
