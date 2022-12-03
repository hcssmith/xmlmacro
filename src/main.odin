package main

import "core:fmt"

import "lib/xml/reader"

main :: proc() {
  doc:=reader.parse_file("./index.xml")
  
  for i:=0; i<len(doc.Elements);i+=1 {
    fmt.printf("{0}\n", doc.Elements[i])
  }
}


