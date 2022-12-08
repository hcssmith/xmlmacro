package main

import "core:fmt"

import "lib/xml"
import "lib/xml/xpath"

main :: proc() {
  doc:=xml.parse_file("./index.xml")
  xpath.run_query(&doc, "//include/in[last()-1]/element[@lang='en']", 0)
}


