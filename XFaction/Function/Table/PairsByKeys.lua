function PairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do a[#a+1] = n end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i], t[a[i]]
	  end
	end
	return iter
end