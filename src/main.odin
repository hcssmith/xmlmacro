package main

import "core:fmt"

import "lib/xml"
import "lib/xml/xpath"

main :: proc() {
  doc:=xml.parse_file("./index.xml")
  //fmt.printf(xml.print_xml_document(&doc))

  xpath.run_query(&doc, "//include@type", 0)

  //fmt.printf("{0}\n", doc.XMLDeclaration)
  //fmt.printf("{0}\n", doc.Stylesheet)
  
  //for i:=0; i<len(doc.Elements);i+=1 {
  //  fmt.printf("{0}\n", doc.Elements[i])
  //  for x:=0;x<len(doc.Elements[i].Attributes);x+=1 {
  //    fmt.printf("\t{0}\n", doc.Elements[i].Attributes[x])
  //  }
  //}
}


