import sys
import requests
import time
import redis

from sepolgen.defaults import headers

podinfo_url='http://podinfo.default:9898'
redis_url='podinfo-redis.default'

data = int(time.time())
# get token
response = requests.post(podinfo_url + '/token', data=data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
if response.status_code != '200':
    print('Fail to get token')
    sys.exit(1)
token = response.json()['token']

# validate token
response = requests.get(podinfo_url + '/token/validate', headers={
    'Authorization': 'Bearer ' + token,
})
if response.status_code != '200':
    print('Can\'t validate token')
    sys.exit(1)

# validate with redis
if not redis_url:
    print('Running without Redis url')
    sys.exit(0)

r = redis.Redis(host=redis_url, port=6379, decode_responses=True)
if not r:
    print('Failed to validate token against Redis')
    sys.exit(1)
