# PoC — Registro de Certificados en Blockchain

Prueba de Concepto para el Laboratorio de Blockchain: una página web sube un certificado (PDF), extrae **legajo, DNI y carrera**, calcula el **hash SHA-256** del archivo y lo registra en un contrato Solidity desplegado desde **Remix IDE** sobre un nodo local de **Foundry (Anvil)**.

No requiere MetaMask ni redes públicas: todo corre en tu máquina.

## Contenido

| Archivo | Descripción |
|---|---|
| `contracts/RegistroCertificados.sol` | Contrato Solidity para compilar/desplegar en Remix |
| `index.html` | Página web (subida, extracción de datos, hash y registro vía JSON-RPC contra Anvil) |

## Cómo funciona

1. La página calcula el SHA-256 del archivo en el navegador (el certificado **nunca** sale de tu máquina).
2. Si es PDF, extrae legajo, DNI y carrera del texto con expresiones regulares (campos editables por si falla).
3. Se conecta por JSON-RPC al nodo Anvil (`http://127.0.0.1:8545`) y firma con la **cuenta 0** del nodo (Anvil expone cuentas ya desbloqueadas, por eso no hace falta billetera).
4. Envía la transacción `registrarCertificado(hash, legajo, dni, carrera)`.
5. Cualquiera puede verificar después: se re-hashea el archivo y se consulta `verificarCertificado(hash)`. Si el documento fue alterado en un solo byte, el hash cambia y la verificación falla.

## Requisitos

- [Foundry](https://getfoundry.sh) instalado (trae el nodo local `anvil`).
- Python o Node para servir la página (cualquiera de los dos).

## Paso a paso

### 1. Levantar el nodo local

En una terminal (dejala abierta):

```powershell
anvil
```

Arranca un nodo en `http://127.0.0.1:8545` (chainId 31337) con 10 cuentas precargadas con 10.000 ETH de prueba.

### 2. Desplegar el contrato en Remix

1. Abrí [https://remix.ethereum.org](https://remix.ethereum.org).
2. Creá un archivo `RegistroCertificados.sol` y pegá el contenido de `contracts/RegistroCertificados.sol`.
3. En **Solidity Compiler**, elegí la versión `0.8.20` (o superior) y compilá.
4. En **Deploy & Run Transactions**, en *Environment* elegí **Dev - Foundry Provider** y aceptá la URL por defecto (`http://127.0.0.1:8545`). Vas a ver las cuentas de Anvil cargadas en el selector *Account*.
5. Hacé clic en **Deploy** (la transacción se confirma al instante, sin firmar nada).
6. Copiá la dirección del contrato desde *Deployed Contracts* (botón de copiar al lado del nombre).

### 3. Levantar la página web

Desde esta carpeta:

```powershell
# Opción A (Python)
python -m http.server 8000

# Opción B (Node)
npx serve .
```

Abrir [http://localhost:8000](http://localhost:8000).

### 4. Registrar un certificado

1. **Paso 1**: dejá la URL del nodo como está, pegá la dirección del contrato y hacé clic en *Conectar al nodo*. La página firma con la cuenta 0 de Anvil (la misma que usa Remix por defecto).
2. **Paso 2**: arrastrá el certificado PDF. La página muestra el hash SHA-256 y completa legajo/DNI/carrera si los detecta en el texto.
3. **Paso 3**: *Registrar certificado* — la transacción se confirma al instante en el nodo local.
4. Para verificar: volvé a subir el mismo archivo y usá *Verificar si ya está registrado*.

También podés verificar directo desde Remix: en *Deployed Contracts*, llamá a `verificarCertificado` pegando el hash que muestra la página.

> ⚠️ Anvil no persiste estado: si cerrás la terminal donde corre `anvil`, se pierden el contrato y los registros. Al reiniciarlo hay que volver a desplegar desde Remix (podés arrancarlo con `anvil --state estado.json` para guardar/restaurar el estado entre sesiones).
