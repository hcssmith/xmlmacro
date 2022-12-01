package util

import "core:unicode/utf8"

d_runes_to_string :: proc(dynamic_runes: [dynamic]rune, index: int = 0, end: int = 0) -> string {
  end := end
  if end == 0 {
    end = len(dynamic_runes) - 1 
  } else if end < 0 {
    end = len(dynamic_runes) - 1 + end
  }
  fixed_runes := make([]rune, end-index)
  copy(fixed_runes, dynamic_runes[index:end])
  return utf8.runes_to_string(fixed_runes)
}

d_clear_rune_buffer :: proc(buf: ^[dynamic]rune) { 
  buf^ = [dynamic]rune{}
}
