package reader

import "../types"
import "../../util"

import "core:text/scanner"
import "core:os"
import "core:strings"

import "core:fmt"

// Types shorthand
XMLDocument :: types.XMLDocument
Attribute :: types.Attribute
Element :: types.Element
ElementID :: types.ElementID
Dpctype :: types.Doctype
StyleSheet :: types.StyleSheet
ContentType :: types.ContentType

// Buffer alias
RuneBuffer :: [dynamic]rune

get_file :: proc(file: string) -> (contents: string, status: bool) {
  data, data_ok := os.read_entire_file(file)
  status = data_ok
  if !data_ok {
    contents=""
    return
  }
  contents = strings.clone_from_bytes(data)
  return
}

get_full_element_tag :: proc(s: ^scanner.Scanner, buffer: ^RuneBuffer) -> (elem: Element) {
  
  element_loop: for {
    ch := scanner.next(s)
    append(buffer, ch)
    if ch == '>' {
      break element_loop
    }
  }
  e, i := get_element_name(buffer)
  if e[0] == '/' {
    elem.Closer = true
    elem.TagName = e[1:]
    util.d_clear_buffer(buffer)
    return
  }
  attrs, selfclosing := get_attrs_list(buffer, i)
  elem.TagName = e
  elem.Attributes = attrs
  elem.SelfClosing = selfclosing
  util.d_clear_buffer(buffer)
  return
}

get_attrs_list :: proc(buf: ^RuneBuffer, index: int) -> (attrs: [dynamic]Attribute, selfclosing: bool) {
  abuf : RuneBuffer
  d_attrs: [dynamic]Attribute
  i:=index
  for ;i<len(buf); i+=1 {
    if buf[i] == '/' || buf[i] == '?' {
      selfclosing = true
      return
    } else if buf[i] == '>' {
      selfclosing = false
      return
    }
    attr: Attribute
    attr_key: for {
      if  buf[i] == '/' || buf[i] == '?' {
        selfclosing = true
        return
      } else if buf[i] == '>' {
        selfclosing = false
        return
      }
      if buf[i] == '=' {
        break attr_key
      }
      append(&abuf, buf[i])
      i+=1
    }
    attr.Key = util.d_runes_to_string(abuf)
    util.d_clear_buffer(&abuf)
    attr_val: for {
      if buf[i] == '"' || buf[i] == '\'' {
        if len(abuf) > 1 {
          break attr_val
        }
        i += 1
        continue
      }
      append(&abuf, buf[i])
      i += 1
    }
    attr.Value = util.d_runes_to_string(abuf)
    util.d_clear_buffer(&abuf)
    append(&d_attrs, attr)
  }
  attrs = d_attrs
  return
}

//<elementname attr="value" attr2 = "cdscdcsd">
get_element_name :: proc(buf: ^RuneBuffer) -> (name: string, index: int) {
  ebuf : RuneBuffer
  inName := false
  i:=0
  for ;i<len(buf); i+=1 {
    if buf[i] == '<' || buf[i] == '\n' {
      continue
    }
    if buf[i] == '>' {
      break
    }
    if buf[i] == ' ' && inName == false{
      continue
    } else if buf[i] == ' ' && inName != false{
      break
    }
    inName = true
    append(&ebuf, buf[i])
  }
  name = util.d_runes_to_string(ebuf)
  index = i
  return
}

get_element_copy_by_id :: proc(doc: ^XMLDocument, ID: ElementID) -> Element {
  for x:=0;x<len(doc.Elements); x+=1 {
    if doc.Elements[x].ID == ID {
      return doc.Elements[x]
    }
  }
  return {}
}

parse_file :: proc(filename: string) -> (document: XMLDocument) {
  contents, success := get_file(filename)
  if !success {
    return
  }
  s: scanner.Scanner
  scanner.init(&s, contents)
  buf: RuneBuffer
  textBuf: RuneBuffer
  elemStack: util.u64_stack
  util.init_u64_stack(&elemStack)
  main_scan_loop: for {
    ch := scanner.next(&s)
    if ch != scanner.EOF {
      append(&buf, ch)
    } else {
      break
    }
    switch ch{
      case '<':
        t: Element
        t.TextOnlyElement = true
        t.TagName = "--TEXTONLY--"
        t.Text = strings.trim_space(util.d_runes_to_string(textBuf))
        if t.Text != "" {
          t.ID = document.CurrentElementID
          document.CurrentElementID += 1
          t.Parent = util.u64_skim(&elemStack)
          append(&document.Elements, t)
        }
        util.d_clear_buffer(&textBuf)
        util.d_clear_buffer(&buf)
        e: Element = get_full_element_tag(&s, &buf)
        if !e.Closer {
          e.ID = document.CurrentElementID
          e.Parent = util.u64_skim(&elemStack)
          document.CurrentElementID += 1
        } else {
          i := util.u64_pop(&elemStack)
          e2 := get_element_copy_by_id(&document, i)
          if e2.TagName != e.TagName {
            break main_scan_loop
          }
        }
        if !e.SelfClosing {
          if !e.Closer {
          util.u64_push(&elemStack,e.ID)
        }
        }
        if !e.Closer {
          append(&document.Elements, e)
        }
        break
      case:
        append(&textBuf, ch)
    }
  }
  return
}
