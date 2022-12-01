package main

import "core:fmt"
import "core:text/scanner"
import "core:os"
import "core:strings"
import "lib/util"

XMLDocument :: struct {
  Doctype: Doctype,
  Stylesheet: StyleSheet,
  Version: string,
  Encoding: string,
  Attributes: [dynamic]Attribute,
  Elements: [dynamic]Element,
}

Attribute :: struct {
  Key: string,
  Value: string,
}

Element :: struct {
  TagName: string,
  Parent: ^Element,
  Attributes: [dynamic]Attribute,
  Elements: [dynamic]Element,
}

Doctype :: struct {
  Public: string,
  Private: string,
}

StyleSheet :: struct {
  Type: ContentType,
  Href: string,
}

ContentType :: enum {
  xsl,
}

main :: proc() {
  s: scanner.Scanner
  data, data_ok := os.read_entire_file("./index.xml")
  contents:= strings.clone_from_bytes(data)
  scanner.init(&s, contents)
  doc: XMLDocument

  open_tag_count:= 0
  buffer: [dynamic]rune
  elem: Element
  attr: Attribute
  hasAttrs:= false
  in_tag := false
  in_tag_name := false
  in_attr_key:= false
  in_attr:= false
  in_attr_value := false
  ptr_current_elem: ^Element
  nesting_level := 0
  in_closing_tag := false

  for x:=0;x<len(contents);x+=1 {
    ch := scanner.next(&s)
    append(&buffer, ch)
    switch ch{
      case '<':
        in_tag = true
        util.d_clear_rune_buffer(&buffer)
        in_tag_name = true
        nesting_level += 1
        break
      case '>':
        if in_tag_name {
          elem.TagName = util.d_runes_to_string(buffer) 
        }
        if in_tag_name && in_closing_tag {
          if nesting_level == 0 {
            // do something
          }
        }
        in_tag = false
        hasAttrs = false
        in_tag_name = false
        in_attr_key = false
        in_attr = false
        in_attr_value = false
        in_closing_tag = false
        util.d_clear_rune_buffer(&buffer)
        fmt.printf("{0}\n", elem)
        elem = {}
        attr = {}
        break
      case ' ':
        if in_tag_name {
          elem.TagName = util.d_runes_to_string(buffer) 
          util.d_clear_rune_buffer(&buffer)
          hasAttrs = true
          in_attr_key = true
          in_attr = true
          in_tag_name = false
        }
        if in_attr_key {
          util.d_clear_rune_buffer(&buffer) // Strictly this should error
        }
        break
      case '=':
        if in_attr_key {
          attr.Key = util.d_runes_to_string(buffer)
          util.d_clear_rune_buffer(&buffer)
          in_attr_key = false
        } 
        break
      case '"', '\'':
        if in_attr && !in_attr_value {
          in_attr_value = true
        } else if in_attr && in_attr_value {
          attr.Value = util.d_runes_to_string(buffer, 1) 
          util.d_clear_rune_buffer(&buffer)
          in_attr = true
          in_attr_key = true
          in_attr_value = false
          append(&elem.Attributes, attr)
        }
        break
      case '\\':
        in_closing_tag = true
        break
      
    }
  }
}


