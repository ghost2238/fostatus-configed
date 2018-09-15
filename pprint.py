import json, sys
with open(sys.argv[1], 'r') as f:
	parsed = json.load(f)
with open(sys.argv[1], 'w') as f:
	json.dump(parsed, f, indent=4, sort_keys=True)