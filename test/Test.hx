package;

using MagicArrayTools;

var failedAsserts = 0;

function assert(b: Bool, ?pos: haxe.PosInfos) {
	if(!b) {
		haxe.Log.trace("assert failed.", pos);
		failedAsserts++;
	}
}

function assertEquals<T>(a1: Array<T>, a2: Array<T>, ?pos: haxe.PosInfos) {
	var result = a1.length == a2.length;
	if(result) {
		for(i in 0...a1.length) {
			if(a1[i] != a2[i]) {
				result = false;
				break;
			}
		}
	}
	if(!result) {
		haxe.Log.trace("assert failed. " + a1 + " != " + a2 + "\n", pos);
		failedAsserts++;
	}
}

function main() {
	haxe.Log.trace("\033[32mTesting [Magic Array Tools]\n\033[0;37m", null);

	//**********************************************
	// * map
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assertEquals(arr.map(_), arr);
		assertEquals(arr.map(i -> i), arr);
		assertEquals(arr.map(function(i) { return i; }), arr);

		final arrStr = ["1", "2", "3", "4", "5"];

		assertEquals(arr.map("" + _), arrStr);
		assertEquals(arr.map((i:Int) -> "" + i), arrStr);
		assertEquals(arr.map(function(i:Int) { return "" + i; }), arrStr);
	}

	//**********************************************
	// * filter
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assertEquals(arr.filter((true)), arr);
		assertEquals(arr.filter(i -> true), arr);

		assertEquals(arr.filter((false)), []);
		assertEquals(arr.filter(i -> false), []);

		final arr2 = [3, 4, 5];

		assertEquals(arr.filter(_ >= 3), arr2);
		assertEquals(arr.filter(i -> i >= 3), arr2);

		final arr3 = ["1"];

		assertEquals(arr.filter(_ == 1).map("" + _), arr3);
		assertEquals(arr.filter(i -> i == 1).map((i:Int) -> "" + i), arr3);
		assertEquals(arr.map("" + _).filter(_ == "1"), arr3);
		assertEquals(arr.map((i:Int) -> "" + i).filter(i -> i == "1"), arr3);
	}

	//**********************************************
	// * size
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.size() == arr.length);
		assert(arr.filter(_ < 3).size() == 2);
		assert(arr.map("" + _).size() == 5);
		assert(arr.filter(i -> false).size() == 0);
		assert(arr.filter(i -> true).size() == arr.length);
		assert(arr.concat([1, 2, 3]).size() == arr.length + 3);
	}

	//**********************************************
	// * count
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.count(i -> false) == 0);
		assert(arr.count(i -> true) == arr.length);
		assert((1...10).count(_ < 3) == 2);
		assert(arr.map(_ * 2).count(_ < 3) == 1);
		assert((1...10).map(_ * 2).count(_ < 3) == 1);
		assert(arr.concat([1, 2, 3]).count(i -> false) == 0);
		assert(arr.concat([1, 2, 3]).count(i -> true) == arr.length + 3);
	}

	//**********************************************
	// * isEmpty
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(!arr.isEmpty());
		assert([].isEmpty());
		assert(!(0...10).isEmpty());
		assert(arr.filter(i -> false).isEmpty());
		assert(!arr.filter(i -> true).isEmpty());
		assert(!arr.concat([]).isEmpty());
		assert(![].concat([1, 2, 3]).isEmpty());
	}

	//**********************************************
	// * find
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.find(_ == 1) == 1);
		assert(arr.find(i -> i == 3) == 3);
		assert(arr.map("" + _).find(_ == "5") == "5");
		assert(arr.map(12 * _).filter(_ < 30).find(_ == 24) == 24);
		assert(arr.concat([1]).find(_ == 1) == 1);
	}

	//**********************************************
	// * findIndex
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.findIndex(_ == 1) == 0);
		assert(arr.findIndex(i -> i == 3) == 2);
		assert(arr.map("" + _).findIndex(_ == "5") == 4);
		assert(arr.map(12 * _).filter(_ < 30).findIndex(_ == 24) == 1);
		assert(arr.concat([1]).findIndex(_ == 1) == 0);
	}

	//**********************************************
	// * indexOf
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.indexOf(3) == 2);
		assert(arr.indexOf(1) == 0);
		assert(arr.map("" + _).indexOf("5") == 4);
		assert(arr.map(12 * _).filter(_ < 30).indexOf(24) == 1);

		assert(arr.indexOf(2, 0) == 1);
		assert(arr.indexOf(5, 0, false) == 4);
		assert(arr.map("" + _).indexOf("1", 0) == 0);
		assert(arr.map(12 * _).filter(_ < 30).indexOf(24, 0, false) == 1);

		assert(arr.indexOf(4, 0, true) == 3);
		assert(arr.indexOf(1, 0, true) == 0);
		assert(arr.map("" + _).indexOf("3", 0, true) == 2);
		assert(arr.map(12 * _).filter(_ > 30).indexOf(36, 0, true) == 0);

		assert(arr.concat([1, 2, 3]).indexOf(3) == 2);
		assert(arr.concat([10, 11, 12]).indexOf(11) == 6);

		final arr2 = [1, 2, 3, 1, 2, 3];

		assert(arr2.indexOf(3, 4) == 5);
		assert(arr2.indexOf(1, 1) == 3);
	}

	//**********************************************
	// * every
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.every(_ > 0));
		assert(!arr.every(_ > 10));
		assert(arr.every(_ != -1));
		assert(!arr.concat([-1]).every(_ == -1));
	}

	//**********************************************
	// * some
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.some(_ == 1));
		assert(!arr.some(_ == -1));
		assert(arr.concat([-1]).some(_ == -1));
	}

	//**********************************************
	// * reduce
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.reduce((a, b) -> a + b) == 15);
		assert(arr.reduce((a, b) -> a * b) == 120);
		assert(arr.concat(6...10).reduce((a, b) -> a * b) == 362880);
		assert(arr.reduce((a, b) -> Std.int(Math.max(a, b))) == 5);
		assert(arr.reduce(function(a, b) { return a + b; }) == 15);
		assert(arr.reduce((a, b) -> a) == 1);
	}

	//**********************************************
	// * asArray
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assertEquals((1...6).asArray(), arr);
		assert((0...4).asArray().toString() == "0,1,2,3");
	}

	//**********************************************
	// * asList
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assert(arr.asList().toString() == "{1, 2, 3, 4, 5}");
	}

	//**********************************************
	// * asVector
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assertEquals(arr.asVector().toArray(), arr);
		assertEquals(arr.map(12 * _).filter(_ < 30).asVector().toArray(), [12, 24]);
	}

	//**********************************************
	// * concat
	//**********************************************
	{
		final arr = [1, 2, 3];
		final arr2 = [4, 5, 6];

		assertEquals(arr.concat(arr2), [1, 2, 3, 4, 5, 6]);
		assertEquals(arr.filter(_ == 3).concat(arr2), [3, 4, 5, 6]);
		assertEquals(arr.concat(arr2).filter(_ == 3), [3]);
		assertEquals(arr.concat(arr2.filter(_ == 6)), [1, 2, 3, 6]);
		assertEquals(arr.filter(_ == 3).concat(arr2.filter(_ == 6)), [3, 6]);
		assertEquals(arr.concat(arr2.filter(_ == 6)).filter(_ == 3), [3]);
		assertEquals((0...10).concat((10...20).concat((20...30).concat(30...40))), (0...40).asArray());
	}

	//**********************************************
	// * fill
	//**********************************************
	{
		final arr = [1, 2, 3, 4, 5];

		assertEquals(arr.fill(123), [123, 123, 123, 123, 123]);
		assertEquals(arr.fill(123, 2), [1, 2, 123, 123, 123]);
		assertEquals(arr.fill(123, 1 + 1 + 1), [1, 2, 3, 123, 123]);
		assertEquals(arr.fill(123, 5 * 5 - 23, 1 + 2), [1, 2, 123, 4, 5]);
		assertEquals(arr.concat(5...6).fill(123, 1 + 3, 5 * 1), [1, 2, 3, 4, 123, 5]);

		final onetwothree = 123;
		assertEquals(arr.fill(onetwothree, 2 * 2), [1, 2, 3, 4, 123]);
	}

	//**********************************************
	// * @disableAutoForLoop
	//**********************************************
	{
		final t1 = new TestConflict1();
		assert(t1.map() == 4321);
		@disableAutoForLoop assert(t1.map() == 4321);
	}

	@disableAutoForLoop {
		final t2 = new TestConflict2();
		assert(t2.map() == 1234);
		assertEquals(t2.map(_).buildForLoop(), [0, 1, 2, 3, 4]);
		assert(t2.map(_).size().buildForLoop() == 5);

		final arr = [1, 2, 3, 4, 5];
		assertEquals(arr.map(i -> i), arr);
		assertEquals(arr.map(i -> i).buildForLoop(), arr);
		assertEquals(arr.map(_).buildForLoop(), arr);
	}

	// ---

	if(failedAsserts == 0) {
		haxe.Log.trace("\033[32m[Magic Array Tools] Test Successful!\033[0;37m", null);
	} else {
		haxe.Log.trace("\033[31m[Magic Array Tools] Test Failed " + failedAsserts + " Asserts!\033[0;37m", null);
	}
}

class TestConflict1 {
	public function new() {}
	public function map() return 4321;
}

class TestConflict2 {
	public function new() {}
	public function map() return 1234;
	public function iterator(): Iterator<Int> { return 0...5; }
}
