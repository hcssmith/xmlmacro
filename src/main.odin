package main

import "core:fmt"

import "lib/xml"
import "lib/xml/xpath"

main :: proc() {
  doc:=xml.parse_file("./index.xml")
  //a := xpath.run_query(&doc, "/page/includes/include", 0)

  ast := xpath.parse_to_ast("count(//a)")

  fmt.printf("{0}", ast)
}


