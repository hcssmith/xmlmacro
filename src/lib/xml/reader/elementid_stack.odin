package reader

ElementID_stack :: struct {
  arr: [dynamic]ElementID,
  ptr: int,
}


init_ElementID_stack :: proc(stack: ^ElementID_stack) {
  stack^ = {[dynamic]ElementID{}, 0}
}

ElementID_push :: proc(stack: ^ElementID_stack, item: ElementID) {
  l := len(stack.arr)
  if l == 0 {
    append(&stack.arr, item)
    stack.ptr = 0
  } else if l - 1 != stack.ptr {
    stack.arr[stack.ptr + 1] = item
    stack.ptr = stack.ptr + 1
  } else {
    append(&stack.arr, item)
    stack.ptr = stack.ptr + 1
  }
}

ElementID_pop :: proc(stack: ^ElementID_stack) -> ElementID {
  if len(stack.arr) == 0 {
    return 0
  } else {
    p := stack.ptr
    stack.ptr = stack.ptr - 1
    return stack.arr[p]
  }
}

ElementID_skim :: proc(stack: ^ElementID_stack) -> ElementID {
  if len(stack.arr) == 0 {
    return 0
  }
  if len(stack.arr) > 0 {
    return stack.arr[stack.ptr]
  }
  return 0
}
