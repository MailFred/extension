Add a file named `updateRdfKeyFile.pem` here for signing the `update.rdf` and a `updateRdfKeyFile.pub` for the `updateKey` section of `install.rdf`.

You can generate those by
```console
openssl genrsa -out updateRdfKeyFile.pem 2048
```
and
 ```console
 openssl rsa -in updateRdfKeyFile.pem -pubout -out updateRdfKeyFile.pub
 ```
