Verify the key:
```
openssl rsa -check -noout -in RESTFORCE_PRIVATE_KEY
```

cat RESTFORCE_PRIVATE_KEY | base64 > RESTFORCE_PRIVATE_KEY_B64

Indent 8 spaces before base64'ing o that the YAML indents correctly!

https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-in-yaml-over-multiple-lines