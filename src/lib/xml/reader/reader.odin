package reader

import "../types"
import "../../util"

import "core:text/scanner"
import "core:os"
import "core:strings"

// Types shorthand
XMLDocument :: types.XMLDocument
Attribute :: types.Attribute
AttributeID :: types.AttributeID
Element :: types.Element
ElementID :: types.ElementID
Dpctype :: types.Doctype
StyleSheet :: types.StyleSheet
ContentType :: types.ContentType
XMLDeclaration :: types.XMLDeclaration

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

get_full_element_tag :: proc(s: ^scanner.Scanner, buffer: ^RuneBuffer, doc: ^XMLDocument) -> (elem: Element) {
  
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
  for x:=0;x<len(attrs);x+=1 {
    a:=attrs[x]
    a.ID = doc.CurrentAttributeID
    doc.CurrentAttributeID +=1
    append(&doc.Attributes, a)
    append(&elem.Attributes, a.ID)
  }
  elem.SelfClosing = selfclosing
  util.d_clear_buffer(buffer)
  return
}

get_attrs_list :: proc(buf: ^RuneBuffer, index: int) -> (attrs: [dynamic]Attribute, selfclosing: bool) {
  abuf : RuneBuffer
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
    attr.Key = strings.trim_space(util.d_runes_to_string(abuf))
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
    attr.Value = strings.trim_space(util.d_runes_to_string(abuf, 1))
    util.d_clear_buffer(&abuf)
    append(&attrs, attr)
  }
  return
}

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

get_attr_copy_by_id :: proc(doc: XMLDocument, ID: AttributeID) -> Attribute {
  for x:=0;x<len(doc.Attributes);x+=1 {
    if doc.Attributes[x].ID == ID {
      return doc.Attributes[x]
    }
  }
  return {}
}

get_elements_copy_by_parent_id :: proc(doc: ^XMLDocument, ID: ElementID) -> [dynamic]Element {
  elist: [dynamic]Element
  for x:=0;x<len(doc.Elements); x+=1 {
    if doc.Elements[x].Parent == ID {
      append(&elist, doc.Elements[x])
    }
  }
  return elist
}
parse_xml_stylesheet :: proc(xml: Element, doc: XMLDocument) ->  (stylesheet: StyleSheet) {
  stylesheet.Type = .empty
  stylesheet.Href = ""
  for i:=0;i<len(xml.Attributes); i+=1 {
    attr := get_attr_copy_by_id(doc, xml.Attributes[i])
    switch attr.Key {
      case "type":
        switch attr.Value {
          case "text/css":
            stylesheet.Type = .css
            break
          case "text/xsl":
            stylesheet.Type = .xsl
            break
          case "":
            stylesheet.Type = .empty
            break
          }
        break
      case "href":
        stylesheet.Href = attr.Value
        break
    }
  }
  return
}

parse_xml_declaration :: proc(xml: Element, doc: XMLDocument) ->  (dec: XMLDeclaration) {
  dec.Version = "1.0"
  dec.Encoding = "UTF-8"
  dec.Standalone = "no"
  for i:=0;i<len(xml.Attributes); i+=1 {
    attr := get_attr_copy_by_id(doc, xml.Attributes[i])
    switch attr.Key {
      case "version":
        dec.Version = attr.Value
        break
      case "encoding":
        dec.Encoding = attr.Value
        break
      case "standalone":
        dec.Standalone = attr.Value
        break
    }
  }
  return
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
  elemStack: ElementID_stack
  init_ElementID_stack(&elemStack)
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
          t.Parent = ElementID_skim(&elemStack)
          append(&document.Elements, t)
        }
        util.d_clear_buffer(&textBuf)
        util.d_clear_buffer(&buf)
        e: Element = get_full_element_tag(&s, &buf, &document)
        if !e.Closer {
          e.ID = document.CurrentElementID
          e.Parent = ElementID_skim(&elemStack)
          document.CurrentElementID += 1
        } else {
          i := ElementID_pop(&elemStack)
          e2 := get_element_copy_by_id(&document, i)
          if e2.TagName != e.TagName {
            break main_scan_loop
          }
        }
        if !e.SelfClosing {
          if !e.Closer {
            ElementID_push(&elemStack,e.ID)
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
  root_elements := get_elements_copy_by_parent_id(&document, 0)
  for a:=0;a<len(root_elements);a+=1 {
    switch root_elements[a].TagName {
      case "?xml":
        document.XMLDeclaration = parse_xml_declaration(root_elements[a], document)
        break
      case "?xml-stylesheet":
        document.Stylesheet = parse_xml_stylesheet(root_elements[a], document)
    }
  }
  return
}
