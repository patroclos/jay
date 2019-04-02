primitive JEq
	"""
	Implements structural JSON equality
	"""
	fun apply(a: (J | NotSet), b: (J | NotSet)): Bool =>
		match (a, b)
		| (let a': JObj, let b': JObj) =>
			if a'.data.size() != b'.data.size() then return false end
			for (k, v) in a'.data.pairs() do
				try
					if JEq(b'.data(k)?, v) == false then return false end
				else return false
				end
			end
			true
		| (let a': JArr, let b': JArr) =>
			if a'.data.size() != b'.data.size() then return false end
			var i: USize = 0
			while i < a'.data.size() do
				try 
					if JEq(a'.data(i)?, b'.data(i)?) == false then
						return false
					end
				else return false end
				i = i + 1
			end
			true
		| (let a': I64, let b': I64) => a' == b'
		| (let a': F64, let b': F64) => a' == b'
		| (let a': String, let b': String) => a' == b'
		| (let a': Bool, let b': Bool) => a' == b'
		| (None, None) => true
		| (NotSet, NotSet) => true
		else false
		end
