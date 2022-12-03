package util

import "core:unicode/utf8"
import "../xml/types"

import "core:fmt"

u64_stack :: struct {
  arr: [dynamic]u64,
  ptr: int,
}

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

init_u64_stack :: proc(stack: ^u64_stack) {
  stack^ = {
    [dynamic]u64{},
    0,
  }
}

u64_push :: proc(stack: ^u64_stack, item: u64) {
  fmt.printf("push: {0}\n", item)
  l := len(stack.arr)
  if l == 0 {
    append(&stack.arr, item)
    stack.ptr = 0
  } else if l-1 != stack.ptr{
    fmt.printf("{0}\n{1}\n{2}", l, stack, item)
    stack.arr[stack.ptr+1] = item
    stack.ptr = stack.ptr + 1
  } else {
    fmt.printf("c")
    append(&stack.arr, item)
    stack.ptr = stack.ptr + 1
  }
}

u64_pop :: proc(stack: ^u64_stack) -> u64 {
  fmt.printf("pop: ")
  if len(stack.arr) == 0 {
    fmt.printf("0\n")
    return 0
  } 
  else {
    p := stack.ptr
    stack.ptr = stack.ptr - 1
    fmt.printf("{0}\n", stack.arr[p])
    return stack.arr[p]
  }
}

u64_skim :: proc(stack: ^u64_stack) -> u64 {
  fmt.printf("skim:")
  if len(stack.arr) == 0 {
    fmt.printf("0\n")
    return 0
  } 
  if len(stack.arr) > 0 {
    fmt.printf("{0}\n", stack.arr[stack.ptr])
    return stack.arr[stack.ptr]
  }
  return 0
}
