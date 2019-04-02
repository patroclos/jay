use "ponytest"

actor Main is TestList
    new create(env: Env) =>PonyTest(env, this)

    fun tag tests(test: PonyTest) =>
        test(TestLensAssign)
        test(TestLensChoice)
        test(TestLensArray)
        test(TestObjectMerge)
        test(TestJsonEquality)

class TestJsonEquality is UnitTest
    fun name(): String => "JsonEquality"
    fun ref apply(h: TestHelper) =>
        h.assert_true(JEq(I64(5), I64(5)))
        h.assert_true(JEq(F64(5.3), F64(5.3)))
        h.assert_true(JEq(None, None))
        h.assert_true(JEq(NotSet, NotSet))
        h.assert_true(JEq("hello", "hello"))
        h.assert_true(JEq(true, true))
        h.assert_true(JEq(JObj, JObj))
        h.assert_true(JEq(JArr, JArr))
        h.assert_true(JEq(JObj + ("a", I64(5)), JObj + ("a", I64(5))))
        h.assert_true(JEq(JArr + I64(5), JArr + I64(5)))

        h.assert_false(JEq(I64(1), I64(2)))
        h.assert_false(JEq(F64(1), F64(2)))
        h.assert_false(JEq(None, false))
        h.assert_false(JEq(NotSet, false))
        h.assert_false(JEq("hello", "bye"))
        h.assert_false(JEq(JObj, JObj + ("foo", "bar")))
        h.assert_false(JEq(JObj + ("foo", "bar"), JObj))
        h.assert_false(JEq(JObj, JArr))
        h.assert_false(JEq(JArr + None, JArr))
        h.assert_false(JEq(JObj + ("foo", "baz"), JObj + ("foo", "bar")))

        h.assert_false(JEq(
            JObj
                + ("foo", JObj
                    + ("bar", false)
                  )
          , JObj
                + ("foo", JObj
                    + ("bar", true)
                )))

        h.assert_false(JEq(
            JObj
                + ("foo", JObj
                    + ("bar", false)
                  )
          , JObj
                + ("foo", JObj
                    + ("bar", false)
                    + ("baz", None)
                )))

        h.assert_true(JEq(
            JObj
                + ("foo", JObj
                    + ("bar", false)
                  )
          , JObj
                + ("foo", JObj
                    + ("bar", false)
                )))
        
        let a = "dummy"
        let b = JObj + ("value", "dummy")
        let abLens = JLens("value") / JLens // try obtaining the "value" field of an object, if that doesnt work return the whole thing
        h.assert_true(abLens.equals(a, b), "Expected (" + a.string() + ") `((JLens * 'value') / JLens).equals` (" + b.string() + ")")


class TestLensAssign is UnitTest
    fun name(): String => "LensAssign"
    fun ref apply(h: TestHelper) =>
        let x = JObj
            + ("foo", "bar")
            + ("deep", JObj + ("space", I64(9)))
        
        let foo' = JLens("foo")

        let foobazz = (JLens("foo") = "bazz").json(x)

        try
            h.assert_eq[String](foo'.json(foobazz as J) as String, "bazz")
        else h.fail(foobazz.string())
        end
    
class TestLensChoice is UnitTest
    fun name(): String => "LensChoice"
    fun ref apply(h: TestHelper) =>
        let x = JObj + ("value", "bar")
        let y = "foo"

        let valueLens = JLens("value") / JLens

        try
            h.assert_eq[String](valueLens.json(x) as String, "bar")
            h.assert_eq[String](valueLens.json(y) as String, "foo")
        else h.fail("failed")
        end
    
primitive AssertJson
	fun eq(h: TestHelper, a: (J | NotSet), b: (J | NotSet)) =>
		h.assert_true(JEq(a, b), "Expected (" + a.string() + ") == (" + b.string() + ")")
	
	fun ne(h: TestHelper, a: (J | NotSet), b: (J | NotSet)) =>
		h.assert_false(JEq(a, b), "Expected (" + a.string() + ") != (" + b.string() + ")")

class TestLensArray is UnitTest
    fun name(): String => "LensArray"
    fun ref apply(h: TestHelper) =>
        let x = JArr + "markdown" + (JObj + ("language", "en") + ("value", "plain"))

        let set1true = JLens(1) = true

				AssertJson.eq(h, set1true.json(x), JArr + "markdown" + true)

				let obj = JObj + ("one", JObj + ("two", "three"))
				let set_three_3 = JLens("one")("two") = I64(3)
				let remove_two = JLens("one")("two") = NotSet
				let expect = JObj
					+ ("one", JObj
						+ ("two", I64(3))
					  )
				AssertJson.eq(h, set_three_3.json(obj), expect)
				AssertJson.eq(h, remove_two.json(obj), JObj + ("one", JObj))

class TestObjectMerge is UnitTest
    fun name(): String => "ObjectMerge"

    fun ref apply(h: TestHelper) =>
        let a = JObj + ("rootPath", ".")
        let b = JObj + ("rootUri", "file:///") + ("rootPath", None)

				let expected = JObj + ("rootPath", None) + ("rootUri", "file:///")

				AssertJson.eq(h, a * b, expected)
