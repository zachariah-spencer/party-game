extends Item

export (PackedScene)var item : PackedScene

func grab(by):
	by.set_item(item.instance())