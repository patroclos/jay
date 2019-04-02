<h1 align="center">jay</h1>

<div align="center">
  :steam_locomotive::train::train::train::train::train:
</div>
<div align="center">
  <strong>immutable json expressions, structural equality and lenses in pony</strong>
</div>
<br />

# Objects
```pony
let data = JObj
	+ ("key", I64(1))
	+ ("value", JObj
		+ ("name", "jay")
		+ ("version", "1.0.0")
		+ ("release", true)
		+ ("null", None)
		+ ("dependencies", JArr + "json") 
	  )
```
```json
{
	"key": 1,
	"value": {
		"name": "jay",
		"version": "1.0.0",
		"release": true,
		"null": null,
		"dependencies": ["json"]
	}
}
```

# Arrays
```pony
let array = JArr
	+ "string"
	+ I64(123)
	+ F64(22.7)
	+ true
	+ None
	+ (JObj + ("test", "value"))
```
```json
["string", 123, 22.7, true, null, {"test": "value"}]
```

# Lenses
```pony
let lens = JLens("value")("version") / JLens(USize(2))
assert_eq(lens.json(data), "1.0.0")
assert_eq(lens.json(array), F64(22.7))
```