import urllib.request
req = urllib.request.Request('http://127.0.0.1:8000/api/v1/auth/register', method='OPTIONS', headers={'Origin': 'http://localhost:3000', 'Access-Control-Request-Method': 'POST'})
print(urllib.request.urlopen(req).headers)
