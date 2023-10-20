Long lines in YAML:
- https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-in-yaml-over-multiple-lines

Verify a private key is valid:
```
openssl rsa -check -noout -in RESTFORCE_PRIVATE_KEY
```

Base64 a value:
```
cat RESTFORCE_PRIVATE_KEY | base64 > RESTFORCE_PRIVATE_KEY_B64
```

You can indent 8 spaces before base64'ing o that the YAML indents correctly!
