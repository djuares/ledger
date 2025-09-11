# Compilación del Ejecutable

```bash
# Genera el ejecutable
$ mix escript.build
```

# Ejecución del Programa

```bash
# Ejecutar normalmente con ruta relativa
$ ./ledger transaction -t= <archivo.csv> -c1=345 -o= <archivo.csv>
```
```bash
# Ruta absoluta 
$ ./ledger transaction -t="/ruta/al/archivo/transac.csv" -c1=345 -o=result.csv
```
```bash
# Ejecutar con ayuda
$ ./ledger --help
```

```bash
$ ./ledger balance -c= <account> 
```
