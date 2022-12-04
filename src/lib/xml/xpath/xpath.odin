package xpath

import "../types"
import "../../util"

import "core:text/scanner"
import "core:fmt"

XMLDeclaration :: types.XMLDeclaration
ContentType :: types.ContentType
StyleSheet :: types.StyleSheet
XMLDocument :: types.XMLDocument
Element :: types.Element
ElementID :: types.ElementID
Doctype :: types.Doctype
Attribute :: types.Attribute

CurrentNode :: ElementID

Result :: union {
  [dynamic]^Element,
  [dynamic]^Attribute,
}



QueryEnum :: enum {
  Root,
  All,
  Current,
  Parent,
  Attr,
}

QueryToken :: union {
  QueryEnum,
  string,
}

TokensiedQuery :: [dynamic]QueryToken

buf_to_token :: proc(tq: ^TokensiedQuery, buf: ^[dynamic]rune) {
  s:=util.d_runes_to_string(buf^)
  util.d_clear_buffer(buf)
  if s == "" {
    return
  }
  append(tq, s)
}


// Base Syntax from w3schools for refrence
//  Expression 	    Description
//  nodename 	      Selects all nodes with the name "nodename"
//  / 	            Selects from the root node
//  // 	            Selects nodes in the document from the current node that match the selection no matter where they are
//  . 	            Selects the current node
//  .. 	            Selects the parent of the current node
//  @ 	            Selects attributes
parse_query :: proc(query: string) -> TokensiedQuery {
  sc: scanner.Scanner
  scanner.init(&sc, query)
  buffer: [dynamic]rune

  tokensiedQuery: TokensiedQuery

  for {
    ch := scanner.next(&sc)
    if ch == scanner.EOF {
      buf_to_token(&tokensiedQuery, &buffer)
      break
    }
    switch ch {
      case '/':
        buf_to_token(&tokensiedQuery, &buffer)
        if scanner.peek(&sc) == '/' {
          append(&tokensiedQuery, QueryEnum.All)
          scanner.next(&sc)
        } else {
          append(&tokensiedQuery, QueryEnum.Root)
        }
        break 
      case '.':
        buf_to_token(&tokensiedQuery, &buffer)
        if scanner.peek(&sc) == '.' {
          append(&tokensiedQuery, QueryEnum.Parent)
          scanner.next(&sc)
        } else {
          append(&tokensiedQuery, QueryEnum.Current)
        }
        break
      case '@':
        buf_to_token(&tokensiedQuery, &buffer)
        append(&tokensiedQuery, QueryEnum.Attr)
        break
      case:
        append(&buffer, ch)
    }
  }
  return tokensiedQuery
}
// "/node/test"
run_query :: proc(doc: ^XMLDocument, xpath: string, current_node: CurrentNode) -> Result
{
  tokensiedQuery:=parse_query(xpath)
  for x:=0; x<len(tokensiedQuery); x+=1 {
    switch v in tokensiedQuery[x] {
      case string:
        s:string =  tokensiedQuery[x].(string)
        fmt.printf("{0}\n", s)
        break
      case QueryEnum:
        fmt.printf("token\n")
        break
    }
  }
  fmt.printf("{0}\n", tokensiedQuery)
  r: Result
  return r
}
