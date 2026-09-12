import configobj, json, sys
c = configobj.ConfigObj(sys.argv[1])
print(json.dumps(c.dict()))