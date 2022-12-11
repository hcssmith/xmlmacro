package writer

import "../types"
import "../reader"

import "core:strings"
import "core:fmt"

XMLDeclaration :: types.XMLDeclaration
ContentType :: types.ContentType
StyleSheet :: types.StyleSheet
XMLDocument :: types.XMLDocument
Element :: types.Element
ElementID :: types.ElementID
Doctype :: types.Doctype
Attribute :: types.Attribute

get_element_copy_by_id :: reader.get_element_copy_by_id
get_elements_copy_by_parent_id :: reader.get_elements_copy_by_parent_id

print_xml_document :: proc(doc: ^XMLDocument) -> string {
  sb: strings.Builder
  strings.builder_init(&sb)
  fmt.sbprintf(&sb, "<?xml version=\"{0}\" encoding=\"{1}\" standalone=\"{2}\" ?>\n", 
    doc.XMLDeclaration.Version, 
    doc.XMLDeclaration.Encoding,
    doc.XMLDeclaration.Standalone)
  type: string
  switch doc.Stylesheet.Type {
    case .empty:
      type = ""
      break
    case .css:
      type = "text/css"
      break
    case .xsl:
      type = "text/xsl"
      break
  }
  fmt.sbprintf(&sb, "<?xml-stylesheet type=\"{0}\" href=\"{1}\" ?>\n", 
    type,
    doc.Stylesheet.Href)
  for x:=0;x<len(doc.Elements);x+=1 {
    if doc.Elements[x].Parent == 0 {
      if doc.Elements[x].TagName != "?xml" && doc.Elements[x].TagName != "?xml-stylesheet" {
        print_element(&sb, doc.Elements[x], doc)
      }
    }
  }
  return strings.to_string(sb) 
}

print_element :: proc(sb: ^strings.Builder, e: Element, doc: ^XMLDocument) {
  if e.TagName == "--TEXTONLY--" && e.TextOnlyElement {
    fmt.sbprintf(sb, e.Text)
    return
  }
  fmt.sbprintf(sb, "<")
  fmt.sbprintf(sb, "{0} ", e.TagName)
  for x:=0; x<len(e.Attributes);x+=1 {
    attr := reader.get_attr_copy_by_id(doc^, e.Attributes[x])
    fmt.sbprintf(sb, "{0}=\"{1}\" ", attr.Key, attr.Value)
  }
  if e.SelfClosing {
    fmt.sbprintf(sb, " />\n")
    return
  }
  fmt.sbprintf(sb, ">\n")
  children := get_elements_copy_by_parent_id(doc, e.ID)
  for y:=0;y<len(children);y+=1 {
    print_element(sb, children[y], doc)
  }
  fmt.sbprintf(sb, "</{0}>\n", e.TagName)
}
