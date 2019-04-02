trait val JTraversal
	fun apply(v: J): (J | NotSet)
	fun update(input: J, value: (J | NotSet)): (J | NotSet)
	fun val mul(t: JTraversal): JTraversal => TravCombine(this, t)
	fun val div(alt: JTraversal): JTraversal => TravChoice(this, alt)

class val TravCombine is JTraversal
	let _a: JTraversal
	let _b: JTraversal

	new val create(a: JTraversal, b: JTraversal) =>
		_a = a
		_b = b

	fun apply(v: J): (J | NotSet) =>
		match _a(v)
		| NotSet => NotSet
		| let a': J => _b(a')
		end
	
	fun update(input: J, value: (J | NotSet)): (J | NotSet) =>
		try
			_a.update(input, _b.update(_a(input) as J, value) as J)
		else NotSet
		end

class val TravObjKey is JTraversal
	let _key: String val

	new val create(key: String val) =>
		_key = key

	fun apply(v: J): (J | NotSet) =>
		match v
		| let v': JObj => v'(_key)
		else NotSet
		end

	fun update(input: J, value: (J | NotSet)): (J | NotSet) =>
		try (input as JObj)(_key) = value else NotSet end 
	
class val TravArrayIndex is JTraversal
	let _idx: USize

	new val create(idx: USize) =>
		_idx = idx
	
	fun apply(v: J): (J | NotSet) =>
		try (v as JArr)(_idx)? else NotSet end
	
	fun update(input: J, value: (J | NotSet)): (J | NotSet) =>
		try (input as JArr)(_idx)? = value else NotSet end
	
class val TravChoice is JTraversal
	let _a: JTraversal
	let _b: JTraversal

	new val create(a: JTraversal, b: JTraversal) => (_a, _b) = (a, b)

	fun apply(v: J): (J | NotSet) =>
		match _a(v)
		| let j: J => j
		| NotSet => _b(v)
		end
	
	fun update(input: J, value: (J | NotSet)): (J | NotSet) =>
		match _a.update(input, value)
		| let out: J => out
		| NotSet => _b.update(input, value)
		end

class val TravMap is JTraversal
	let _fn: {(J): (J | NotSet)} val

	new val create(fn: {(J): (J | NotSet)} val) =>
		_fn = fn

	fun apply(v: J): (J | NotSet) => _fn(v)

	// TODO: is this right?
	fun update(input: J, value: (J | NotSet)): (J | NotSet) =>
		match value | let v: J => _fn(v)
		else NotSet
		end

class val UpdateTrav is JTraversal
	let _trav: JTraversal
	let _key: (String | USize | None)
	let _value: (J | NotSet)

	new val create(trav: JTraversal, k: (String | USize | None), v: (J | NotSet)) =>
		(_key, _value) = (k, v)
		_trav =
			match k
			| let s: String => trav * TravObjKey(s)
			| let i: USize => trav * TravArrayIndex(i)
			else trav
			end

	
	fun apply(v: J): (J | NotSet) =>
		_trav(v) = _value
	
	fun update(input: J, value: (J | NotSet)): (J | NotSet) =>
		_trav(input) = value

class val NoTraversal is JTraversal
	fun apply(v: J): (J | NotSet) => v
	fun update(_: J, v: (J | NotSet)) : (J | NotSet) => v
