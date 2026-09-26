extends RSUserMng

var fail_saves := false
var saves := 0

func save_user(user: RSUser) -> bool:
	if fail_saves:
		return false
	var saved := super.save_user(user)
	if saved:
		saves += 1
	return saved
