package xpath

import "../types"
import "../../util"
import "../reader"

import "core:text/scanner"
import "core:fmt"

XMLDeclaration  :: types.XMLDeclaration
ContentType     :: types.ContentType
StyleSheet      :: types.StyleSheet
XMLDocument     :: types.XMLDocument
Element         :: types.Element
ElementID       :: types.ElementID
Doctype         :: types.Doctype
Attribute       :: types.Attribute

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
  AnyE,
  And,
  AnyA,
  Node,
  Start,
  Last,
  Plus,
  Minus,
  Position,
  Eq,
  MoreThan,
  LessThan,
  End,
}

QueryToken :: union {
  QueryEnum,
  string,
}

TokensiedQuery :: [dynamic]QueryToken

buf_to_token :: proc(tq: ^TokensiedQuery, buf: ^[dynamic]rune) {
  s:=util.d_runes_to_string(buf^)
  //fmt.printf("buf_to_token()=>{0}\n", s)
  util.d_clear_buffer(buf)
  switch s {
    case "":
      break
    case "last()":
      append(tq, QueryEnum.Last)
      break
    case "position()":
      append(tq, QueryEnum.Position)
    case "node()":
      append(tq, QueryEnum.Node)
    case:
      append(tq, s)
  }
}



//  Path Expression 	                  Result
//  /bookstore/book[1] 	                Selects the first book element that is the child of the bookstore element.
//                                      Note: In IE 5,6,7,8,9 first node is[0], but according to W3C, it is [1]. To solve this problem in IE, set the SelectionLanguage to XPath:
//                                      In JavaScript: xml.setProperty("SelectionLanguage","XPath");
//  /bookstore/book[last()] 	          Selects the last book element that is the child of the bookstore element
//  /bookstore/book[last()-1]           Selects the last but one book element that is the child of the bookstore element
//  /bookstore/book[position()<3] 	    Selects the first two book elements that are children of the bookstore element
//  //title[@lang] 	                    Selects all the title elements that have an attribute named lang
//  //title[@lang='en'] 	              Selects all the title elements that have a "lang" attribute with a value of "en"
//  /bookstore/book[price>35.00] 	      Selects all the book elements of the bookstore element that have a price element with a value greater than 35.00
//  /bookstore/book[price>35.00]/title 	Selects all the title elements of the book elements of the bookstore element that have a price element with a value greater than 35.00
parse_predicate :: proc(sc: ^scanner.Scanner, tq: ^TokensiedQuery) {
  append(tq, QueryEnum.Start)
  buffer: [dynamic]rune
  parse_loop: for {
    ch := scanner.next(sc)
    switch ch {
      case scanner.EOF:
        buf_to_token(tq, &buffer)
        break parse_loop
      case ']':
        buf_to_token(tq, &buffer)
        break parse_loop
      case '+':
        buf_to_token(tq, &buffer)
        append(tq, QueryEnum.Plus)
        continue parse_loop
      case '-':
        buf_to_token(tq, &buffer)
        append(tq, QueryEnum.Minus)
        continue parse_loop
      case '>':
        buf_to_token(tq, &buffer)
        append(tq, QueryEnum.MoreThan)
        continue parse_loop
      case '<':
        buf_to_token(tq, &buffer)
        append(tq, QueryEnum.LessThan)
        continue parse_loop
      case '=':
        buf_to_token(tq, &buffer)
        append(tq, QueryEnum.Eq)
        continue parse_loop
      case '@':
        buf_to_token(tq, &buffer)
        if scanner.peek(sc) == '*' {
          append(tq, QueryEnum.AnyA)
          break
        }
        append(tq, QueryEnum.Attr)
        continue parse_loop
      case '*':
        buf_to_token(tq, &buffer)
        append(tq, QueryEnum.AnyE)
        continue parse_loop
    }
    append(&buffer, ch)
  }
  append(tq, QueryEnum.End)
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
      case '[':
        buf_to_token(&tokensiedQuery, &buffer)
        parse_predicate(&sc, &tokensiedQuery)
        break
      case '|':
        buf_to_token(&tokensiedQuery, &buffer)
        append(&tokensiedQuery, QueryEnum.And)
        break
      case:
        append(&buffer, ch)
    }
  }
  return tokensiedQuery
}

run_query :: proc(doc: ^XMLDocument, xpath: string, current_node: CurrentNode) -> Result
{
  tokensiedQuery:=parse_query(xpath)

  list_of_elements: [dynamic]ElementID

  for x:=0; x<len(tokensiedQuery); x+=1 {
    switch v in tokensiedQuery[x] {
      case string:
        list_of_elements = get_elem_by_name_from_elem_list(doc^, list_of_elements, tokensiedQuery[x].(string))
        break
      case QueryEnum:
        switch tokensiedQuery[x].(QueryEnum) {
          case .Root:
            if x == 0 {
              list_of_elements = get_elem_id_list_by_parent_id(doc^, 0)
            }
            break
          case .All:
          case .Current:
          case .Parent:
          case .Attr:
          case .AnyE:
          case .And:
          case .AnyA:
          case .Node:
          case .Start:
          case .Last:
          case .Plus:
          case .Minus:
          case .Position:
          case .Eq:
          case .MoreThan:
          case .LessThan:
          case .End:
          case:
            break
        }
        break
    }
  }
  return get_ptr_list_from_elemnt_ids(doc, list_of_elements)
}