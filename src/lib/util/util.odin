package util

import "core:unicode/utf8"
import "../xml/types"




d_runes_to_string :: proc(dynamic_runes: [dynamic]rune, index: int = 0, end: int = 0) -> string {
  end := end
  if end == 0 {
    end = len(dynamic_runes)  
  } else if end < 0 {
    end = len(dynamic_runes)  + end
  }
  fixed_runes := make([]rune, end-index)
  copy(fixed_runes, dynamic_runes[index:end])
  return utf8.runes_to_string(fixed_runes)
}

d_attribute_list_to_fixed :: proc(dynamic_attributes: [dynamic]types.Attribute) -> []types.Attribute {
  fixed_attrs := make([]types.Attribute, len(dynamic_attributes))
  copy(fixed_attrs, dynamic_attributes[:])
  return fixed_attrs
}

d_list_to_fixed :: proc{
  d_attribute_list_to_fixed,
}


d_clear_rune_buffer :: proc(buf: ^[dynamic]rune) { 
  buf^ = [dynamic]rune{}
}

d_clear_u64_buffer :: proc(buf: ^[dynamic]u64) { 
  buf^ = [dynamic]u64{}
}

d_clear_int_buffer :: proc(buf: ^[dynamic]int) { 
  buf^ = [dynamic]int{}
}

d_clear_buffer :: proc{
  d_clear_u64_buffer,
  d_clear_rune_buffer,
  d_clear_int_buffer, 
}
