package main

import "core:fmt"

import "lib/xml"
import "lib/xml/xpath"

main :: proc() {
  doc:=xml.parse_file("./index.xml")

  xpath.execute_query(&doc, "/a/b/c[@class='test']")
}
