use "json"
use pc = "collections/persistent"

trait val JExpr
	fun json(): JsonType
	fun string(): String val

// this can't be (JExpr | ...) instead of (JObj | JArr | ...), until [this](https://github.com/ponylang/ponyc/issues/3096) is fixed
type J is (JObj | JArr | String | I64 | F64 | Bool | None)

primitive NotSet is Stringable
	fun string(): String iso ^ => "NotSet".string()

class val JObj is JExpr
	let data: pc.Map[String, J]

	new val create(data': pc.Map[String, J] = pc.Map[String, J]) =>
		data = data'

	new box from_iter(it: Iterator[(String val, J)]) =>
		data = pc.Map[String, J].concat(it)

	fun apply(key: String val): (J | NotSet) =>
		if data.contains(key) then try data(key)? else NotSet end else NotSet end
	
	fun update(k: String val, value: (J | NotSet)): JObj =>
		match value | let j: J =>
			JObj(data(k) = j)
		else JObj(try data.remove(k)? else data end)
		end
	
	fun keys(): Iterator[String] => data.keys()
	fun values(): Iterator[J] => data.values()
	fun pairs(): Iterator[(String, J)] => data.pairs()
	
	fun json(): JsonType => json_object()
	
	fun json_object(): JsonObject =>
		let obj = JsonObject(data.size())
		for (k, v) in data.pairs() do
			obj.data(k) = match v
					   | let j: JsonType => j
					   | let j: JExpr => j.json()
					   end
		end
		obj
	
	fun string(): String val =>
		ifdef debug then
			json_object().string("  ", true)
		else
			json_object().string()
		end

	fun add(k: String, v: (J | NotSet)): JObj => this(k) = v

	fun mul(other: JObj): JObj =>
		JObj(data.concat(other.pairs()))

class val JArr is JExpr
	let data: pc.Vec[J]

	new val create(data': pc.Vec[J] = pc.Vec[J]) =>
		data = data'

	fun from_iter(it: Iterator[J]) =>
		JArr(pc.Vec[J].concat(it))
	
	fun apply(i: USize): J ? => data(i)?

	fun update(i: USize, value: (J | NotSet)): JArr ? =>
		match value | let j: J =>
			JArr(data(i)? = j)
		else
			JArr(data.delete(i)?)
		end
	
	fun push(j: J): JArr =>
		JArr(data.push(j))
	
	fun pop(): (JArr, J) ? =>
		let i = data.size() - 1
		let v = data(i)?
		(JArr(data.delete(i)?), v)
	
	fun unshift(value: J): JArr =>
		try JArr(data.insert(0, value)?)
		else push(value)
		end
	
	fun shift(): (J, JArr) ? =>
		let v = data(0)?
		(v, JArr(data.delete(0)?))
	
	fun concat(iter: Iterator[J] ref): JArr =>
		JArr(data.concat(iter))
	
	fun find(value: J, offset: USize = 0, nth: USize = 0, predicate: {(J, J): Bool} val = JEq): USize ? =>
		data.find(value, offset, nth, predicate)?
	
	fun contains(value: J, predicate: {(J, J): Bool} val = JEq): Bool =>
		data.contains(value, predicate)
	
	fun slice(from: USize = 0, to: USize = -1, step: USize = 1): JArr =>
		JArr(data.slice(from, to, step))
	
	fun reverse(): JArr => JArr(data.reverse())

	fun values(): Iterator[J] => data.values()
	
	fun add(v: J): JArr => push(v)

	fun mul(other: JArr): JArr => concat(other.values())
	
	fun json(): JsonType => json_array()

	fun json_array(): JsonArray =>
		let arr = JsonArray(data.size())
		for v in data.values() do
			let v' = match v
				| let j: JsonType => j
				| let j: JExpr => j.json()
				end
			arr.data.push(v')
		end
		arr

	fun string(): String val =>
		ifdef debug then
			json_array().string("  ", true)
		else
			json_array().string()
		end
