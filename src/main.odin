package main

import "core:fmt"

import "lib/xml"

main :: proc() {
  doc:=xml.parse_file("./index.xml")

  fmt.printf("{0}\n", doc.XMLDeclaration)
  fmt.printf("{0}\n", doc.Stylesheet)
  
  //for i:=0; i<len(doc.Elements);i+=1 {
  //  fmt.printf("{0}\n", doc.Elements[i])
  //  for x:=0;x<len(doc.Elements[i].Attributes);x+=1 {
  //    fmt.printf("\t{0}\n", doc.Elements[i].Attributes[x])
  //  }
  //}
}


