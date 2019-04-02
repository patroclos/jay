class val JLens
	let _traversal: JTraversal

	fun trav(): JTraversal val => _traversal

	new val create() => _traversal = NoTraversal

	new val _trav(trav': JTraversal = NoTraversal) =>
		_traversal = trav'
	
	fun json(input: J): (J | NotSet) =>
		_traversal(input)
	
	fun apply(key: (String | USize)): JLens =>
		match key
		| let i: USize => JLens._trav(_traversal * TravArrayIndex(i))
		| let k: String => JLens._trav(_traversal * TravObjKey(k))
		end
	
	fun update(key: (String | USize | None) = None, value: (J | NotSet)): JLens =>
		JLens._trav(UpdateTrav(_traversal, key, value))

	fun mul(other: JLens): JLens =>
		JLens._trav(_traversal * other.trav())
	
	fun div(alt: JLens): JLens =>
		JLens._trav(_traversal.div(alt._traversal))
	
	fun map[A: J = J](fn: {(A): (J | NotSet)} val): JLens =>
		let fn': {(J): (J | NotSet)} val = {(v: J): (J | NotSet) => match v | let v': A => fn(v') else NotSet end}
		JLens._trav(_traversal * TravMap(fn'))
	
	fun equals(a: J, b: J, include_unset: Bool = true): Bool =>
		let a' = json(a)
		let b' = json(b)
		match (a', b')
		| (NotSet, NotSet) => include_unset
		else JEq(a', b')
		end
