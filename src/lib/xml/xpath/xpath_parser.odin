package xpath

import "core:text/scanner"
import "core:strings"
import "core:fmt"

import "../../util"

RuneBuffer :: [dynamic]rune

buffer_to_token :: proc(buf: ^RuneBuffer) -> (s: string) {
    s=util.d_runes_to_string(buf^)
    util.d_clear_buffer(buf)
    return
}

add_token :: proc{
    add_token_enum,
    add_token_string,
}


add_token_enum :: proc(ast: ^AST, token: QueryToken) {
    if type_of(token) == OperatorToken {
        append(&ast.Branch, ast.Exp)
        ast.IsBrancher = true
        append(&ast.Branch, token.(OperatorToken))
        return
    }
    append(&ast.Exp, token)
}



add_token_string :: proc(ast: ^AST, token: string) {
    if token ==  "" {
        return
    }
    append(&ast.Exp, token)
}

add_function :: proc(ast: ^AST, fname: string) {
    switch fname {
        case "boolean":
            append(&ast.Exp, FunctionToken.Boolean)
            break
        case "ceiling":
            append(&ast.Exp, FunctionToken.Ceiling)
            break
        case "choose":
            append(&ast.Exp, FunctionToken.Choose)
            break 
        case "concat":
            append(&ast.Exp, FunctionToken.Concat)
            break
        case "contains":
            append(&ast.Exp, FunctionToken.Contains)
            break 
        case "count":
            append(&ast.Exp, FunctionToken.Count)
            break 
        case "element-available":
            append(&ast.Exp, FunctionToken.Elementavailable)
            break 
        case "false":
            append(&ast.Exp, FunctionToken.False)
            break
        case "floor":
            append(&ast.Exp, FunctionToken.Floor)
            break 
        case "function-available":
            append(&ast.Exp, FunctionToken.Functionavailable)
            break 
        case "id":
            append(&ast.Exp, FunctionToken.Id)
            break 
        case "lang":
            append(&ast.Exp, FunctionToken.Lang)
            break
        case "last":
            append(&ast.Exp, FunctionToken.Last)
            break 
        case "localname":
            append(&ast.Exp, FunctionToken.Localname)
            break 
        case "name":
            append(&ast.Exp, FunctionToken.Name)
            break 
        case "namespace-uri":
            append(&ast.Exp, FunctionToken.Namespaceuri)
            break
        case "normalize-space":
            append(&ast.Exp, FunctionToken.Normalizespace)
            break 
        case "not":
            append(&ast.Exp, FunctionToken.Not)
            break
        case "number":
            append(&ast.Exp, FunctionToken.Number)
            break 
        case "position":
            append(&ast.Exp, FunctionToken.Position)
            break
        case "round":
            append(&ast.Exp, FunctionToken.Round)
            break
        case "starts-with":
            append(&ast.Exp, FunctionToken.Startswith)
            break
        case "string":
            append(&ast.Exp, FunctionToken.String)
            break 
        case "string-length":
            append(&ast.Exp, FunctionToken.Stringlength)
            break 
        case "substring":
            append(&ast.Exp, FunctionToken.Substring)
            break 
        case "substring-after":
            append(&ast.Exp, FunctionToken.Substringafter)
            break 
        case "substring-before":
            append(&ast.Exp, FunctionToken.Substringbefore)
            break 
        case "sum":
            append(&ast.Exp, FunctionToken.Sum)
            break 
        case "translate":
            append(&ast.Exp, FunctionToken.Translate)
            break 
        case "true":
            append(&ast.Exp, FunctionToken.True)
            break
        case "unparsed-entity-url":
            append(&ast.Exp, FunctionToken.Unparsedentityurl)
            break
    }
}

parse_to_ast :: proc(xapth_query: string) -> (root: AST) {
    sc : scanner.Scanner
    scanner.init(&sc, xapth_query)

    buf:RuneBuffer

    store:Expression

    scanner_loop: for {
        ch := scanner.next(&sc)

        switch ch {
        case scanner.EOF:
            add_token(&root, buffer_to_token(&buf))
            break scanner_loop
        //SYNTAX
        case '/':
            add_token(&root, buffer_to_token(&buf))
            next := scanner.peek(&sc)
            if next == '/' {
                add_token(&root, SyntaxToken.Descendant)
                scanner.next(&sc)
            } else {
                add_token(&root, SyntaxToken.Child)
            }
            continue scanner_loop
        case '.':
            add_token(&root, buffer_to_token(&buf))
            next := scanner.peek(&sc)
            if next == '/' {
                scanner.next(&sc)
                add_token(&root, SyntaxToken.Relative)
                
            } else {
                //current?
            }
            continue scanner_loop
        case '|':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, SyntaxToken.Union)
            continue scanner_loop
        case '@':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, SyntaxToken.Attr)
            continue scanner_loop
        // OPERATORS
        case '=':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, OperatorToken.Eq)
            continue scanner_loop
        case '<':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, OperatorToken.Lt)
            continue scanner_loop
        case '>':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, OperatorToken.Mt)
            continue scanner_loop
        case '!':
            next := scanner.peek(&sc)
            if next == '=' {
                add_token(&root, OperatorToken.NEq)
                scanner.next(&sc)
            } else {
                break
            }
            continue scanner_loop
        //TODO AND/OR (Decide how to handle spaces(might need handling elsewhere))
        //Predicate
        case '[':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, PredicateToken.Start)
            continue scanner_loop
        case ']':
            add_token(&root, buffer_to_token(&buf))
            add_token(&root, PredicateToken.End)
            continue scanner_loop
        case '(':
            fun := buffer_to_token(&buf)
            add_function(&root, fun)
            store = root.Exp
            root.Exp = Expression{}
            continue scanner_loop
        case ')':
            add_token(&root, buffer_to_token(&buf))
            fun_exp := root.Exp
            root.Exp = store
            add_token(&root, fun_exp)
            continue scanner_loop
        }
        append(&buf, ch)
    }
    if root.IsBrancher {
        append(&root.Branch, root.Exp)
        root.Exp = {}
    }
    return
}