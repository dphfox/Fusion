--!strict

local tiniest = require("./lib/tiniest_for_roblox").configure({})

local test_root = (script :: any).Parent.fusion
print("Collecting tests...")
local tests = tiniest.collect_tests_from_hierarchy(test_root)
print("Running tests...")
tiniest.run_tests(tests, {})