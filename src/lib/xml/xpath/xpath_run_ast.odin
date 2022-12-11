package xpath

import "core:fmt"

EResult :: [dynamic]ElementID
AResult :: [dynamic]AttributeID


Result :: union {
    EResult,
    AResult,
}

execute_expression :: proc(doc:^XMLDocument, exp: Expression) -> Result {
    return {}
}

execute_query :: proc(doc: ^XMLDocument, xpath_query: string) -> Result {
    ast := parse_to_ast(xpath_query)

    if ast.IsBrancher {
        
    } else {
        for x:=0;x<len(ast.Exp);x+=1 {
            fmt.printf("{0}\n", ast.Exp[x])
        }
    }
    return {}
}
