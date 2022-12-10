package xml

import "reader"
import "types"
import "writer"
import "xpath"

// Export Types
XMLDeclaration      :: types.XMLDeclaration
ContentType         :: types.ContentType
StyleSheet          :: types.StyleSheet
XMLDocument         :: types.XMLDocument
Element             :: types.Element
ElementID           :: types.ElementID
Doctype             :: types.Doctype
Attribute           :: types.Attribute

// Export Parse File
parse_file          :: reader.parse_file

// export print_file
print_xml_document  :: writer.print_xml_document

// export expath
run_query           :: xpath.run_query