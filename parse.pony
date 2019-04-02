use "json"
use pc = "collections/persistent"

primitive JParse
	fun from_string(str: String): J ? => JParse((JsonDoc .> parse(str)?).data)
	fun apply(json: JsonType): J =>
		match json
		| let v: (I64 | F64 | String | Bool | None) => v
		| let j: JsonObject ref => JObjParse(j)
		| let j: JsonArray ref => JArrParse(j)
		end

primitive JObjParse
	fun apply(json: JsonObject ref): JObj val =>
		var data = pc.Map[String, J]
		for (k, v) in json.data.pairs() do
			data = data(k) = JParse(v)
		end

		JObj(data)

primitive JArrParse
	fun apply(json: JsonArray ref): JArr val =>
		var data = pc.Vec[J]
		for v in json.data.values() do
			data = data.push(JParse(v))
		end
		JArr(data)
