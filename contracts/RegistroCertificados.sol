// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RegistroCertificados
 * @notice PoC para el Laboratorio de Blockchain: registra el hash SHA-256 de un
 *         certificado académico junto con legajo, DNI y carrera del alumno.
 *         El archivo nunca se sube a la cadena: solo su huella digital (hash),
 *         lo que permite verificar autenticidad sin exponer el documento.
 */
contract RegistroCertificados {
    struct Certificado {
        string legajo;
        string dni;
        string carrera;
        uint256 timestamp;
        address emisor;
        bool existe;
    }

    // hash SHA-256 del archivo (bytes32) => datos del certificado
    mapping(bytes32 => Certificado) private certificados;
    bytes32[] private listaHashes;

    event CertificadoRegistrado(
        bytes32 indexed hashArchivo,
        string legajo,
        string dni,
        string carrera,
        address indexed emisor,
        uint256 timestamp
    );

    /**
     * @notice Registra un certificado en la blockchain.
     * @param hashArchivo SHA-256 del archivo del certificado (calculado en el navegador).
     * @param legajo Número de legajo del alumno.
     * @param dni DNI del alumno.
     * @param carrera Carrera a la que corresponde el certificado.
     */
    function registrarCertificado(
        bytes32 hashArchivo,
        string calldata legajo,
        string calldata dni,
        string calldata carrera
    ) external {
        require(hashArchivo != bytes32(0), "Hash invalido");
        require(!certificados[hashArchivo].existe, "Certificado ya registrado");
        require(bytes(legajo).length > 0, "Legajo vacio");
        require(bytes(dni).length > 0, "DNI vacio");
        require(bytes(carrera).length > 0, "Carrera vacia");

        certificados[hashArchivo] = Certificado({
            legajo: legajo,
            dni: dni,
            carrera: carrera,
            timestamp: block.timestamp,
            emisor: msg.sender,
            existe: true
        });
        listaHashes.push(hashArchivo);

        emit CertificadoRegistrado(hashArchivo, legajo, dni, carrera, msg.sender, block.timestamp);
    }

    /**
     * @notice Verifica si un certificado (por su hash) fue registrado y devuelve sus datos.
     */
    function verificarCertificado(bytes32 hashArchivo)
        external
        view
        returns (
            bool existe,
            string memory legajo,
            string memory dni,
            string memory carrera,
            uint256 timestamp,
            address emisor
        )
    {
        Certificado storage c = certificados[hashArchivo];
        return (c.existe, c.legajo, c.dni, c.carrera, c.timestamp, c.emisor);
    }

    /// @notice Cantidad total de certificados registrados.
    function totalCertificados() external view returns (uint256) {
        return listaHashes.length;
    }

    /// @notice Devuelve el hash registrado en la posición `indice` (para recorrer el registro).
    function hashPorIndice(uint256 indice) external view returns (bytes32) {
        require(indice < listaHashes.length, "Indice fuera de rango");
        return listaHashes[indice];
    }
}
