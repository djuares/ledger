# Compilación del Ejecutable

```bash
# Genera el ejecutable
$ mix escript.build
```

# Ejecución del Programa

```bash
# Ejecutar con ayuda
$ ./ledger --help
```

## Transaction
```bash
$ ./ledger transaction [opciones]
```
```bash
# Ejecutar normalmente con ruta relativa
$ ./ledger transaction -t=<archivo.csv> -c1=<account> -o=<archivo.csv>
```
```bash
# Ruta absoluta 
$ ./ledger transaction -t="/ruta/al/archivo/transac.csv" -c1=<account> -o="/ruta/al/archivo/transac.csv"
```

## Balance
```bash
$ ./ledger balance -c=<account> [opcion]
```
```bash
$ ./ledger balance -c=<account> -m=<money_type>
```
# Ejecutar tests

```bash
$ mix test
```
