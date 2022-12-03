package types

XMLDocument :: struct {
  Doctype: Doctype,
  CurrentElementID: ElementID,
  Stylesheet: StyleSheet,
  Version: string,
  Encoding: string,
  Elements: [dynamic]Element,
}

Attribute :: struct {
  Key: string,
  Value: string,
}

Element :: struct {
  TagName: string,
  Parent: ElementID,
  ID: ElementID,
  SelfClosing: bool,
  Closer: bool,
  Attributes: [dynamic]Attribute,
  Children: [dynamic]ElementID,
  TextOnlyElement: bool,
  Text: string,
}

ElementID :: u64

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
