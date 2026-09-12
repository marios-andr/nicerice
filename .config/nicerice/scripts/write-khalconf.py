import configobj, json, sys
data = json.loads(sys.stdin.read())
c = configobj.ConfigObj(sys.argv[1])
def merge(section, d):
    for k, v in d.items():
        if isinstance(v, dict):
            if k not in section or not isinstance(section[k], dict):
                section[k] = {}
            merge(section[k], v)
        else:
            section[k] = v
merge(c, data)
c.write()