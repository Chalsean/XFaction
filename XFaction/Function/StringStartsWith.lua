-- http://lua-users.org/wiki/StringRecipes
function string.StartsWith(source, compare)
	return string.sub(source, 1, string.len(compare)) == compare
end