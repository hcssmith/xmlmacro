package main

import "core:fmt"

import "lib/xml"

main :: proc() {
  doc:=xml.parse_file("./index.xml")
  
  for i:=0; i<len(doc.Elements);i+=1 {
    fmt.printf("{0}\n", doc.Elements[i])
  }
}


