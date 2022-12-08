package xpath

get_elem_id_list_by_parent_id :: proc(doc: XMLDocument, id:ElementID) -> (elements: [dynamic]ElementID) {
    for x:=0;x<len(doc.Elements);x+=0 {
        if doc.Elements[x].Parent == id {
            append(&elements, doc.Elements[x].ID)
        }
    }
    return
}

get_elem_by_name_from_elem_list :: proc(doc:XMLDocument, elist:[dynamic]ElementID, name:string) -> (elements: [dynamic]ElementID) {
    for x:=0;x<len(elist);x+=1 {
        for y:=0;y<len(doc.Elements);y+=1 {
            if doc.Elements[y].ID == elist[x] && doc.Elements[y].TagName == name {
                append(&elements, doc.Elements[y].ID)
            }
        }
    }
    return
}