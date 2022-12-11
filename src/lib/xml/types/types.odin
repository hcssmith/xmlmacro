package types

XMLDocument :: struct {
  Doctype: Doctype,
  CurrentElementID: ElementID,
  CurrentAttributeID: AttributeID,
  Stylesheet: StyleSheet,
  XMLDeclaration: XMLDeclaration,
  Elements: [dynamic]Element,
  Attributes: [dynamic]Attribute,
}

Attribute :: struct {
  ID: AttributeID,
  Key: string,
  Value: string,
}

Element :: struct {
  TagName: string,
  Parent: ElementID,
  ID: ElementID,
  SelfClosing: bool,
  Closer: bool,
  Attributes: [dynamic]AttributeID,
  Children: [dynamic]ElementID,
  TextOnlyElement: bool,
  Text: string,
}

ElementID     :: distinct u64
AttributeID   :: distinct u64

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
