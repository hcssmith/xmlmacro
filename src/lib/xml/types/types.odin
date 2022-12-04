package types

XMLDocument :: struct {
  Doctype: Doctype,
  CurrentElementID: ElementID,
  Stylesheet: StyleSheet,
  XMLDeclaration: XMLDeclaration,
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

XMLDeclaration :: struct {
  Version: string,
  Encoding: string,
  Standalone: string,
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
  css,
  empty,
}
