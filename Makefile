.PHONY: test
test: test-c test-js # test-cs

.PHONY: test-c
test-c:
	koka --target c -e _test/test.kk

.PHONY: test-js
test-js:
	koka --target js -e _test/test.kk

# TODO: Get C# working.
# .PHONY: test-cs
# test-cs:
# 	koka --target cs -e _test/test.kk
