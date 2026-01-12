# Cubo OLAP de Ventas con SQL Server Analysis Services (SSAS)
---
## 📌 Descripción del Proyecto

Objetivo: Diseño, implementación y explotación de un Cubo de Datos (OLAP) utilizando tecnologías de Microsoft para el análisis multidimensional de información de ventas. 

Alcance: El proyecto permite analizar métricas clave (Dinero y Cantidad) cruzando información por dimensiones geográficas (País, Región) y de catálogo (Producto, Categoría). Esto facilita la toma de decisiones estratégicas mediante consultas MDX avanzadas. 

---

## 📚 Estructura del repositorio

```bash
├── sql/ 
│   └── sqlserver.sql 
├── schema/ 
│   └── CuboVentas_Final.slnx
├── docs/ 
│   └── DATA_CUBE_SQLSRV.pdf 
└── README.md 
```

---

## 🧠 Arquitectura General

La solución sigue una arquitectura On-Premise basada en el stack tecnológico de Microsoft:

* Base de Datos Relacional: SQL Server 2019 Developer Edition
* Modelo de Datos: Data Warehouse (Esquema de Estrella)
* Motor OLAP: SQL Server Analysis Services (SSAS)
* Modo de SSAS: Multidimensional
* Diseño del Cubo: Visual Studio 2019 Community
* Interfaz de Consulta: SQL Server Management Studio (SSMS)
* Lenguaje de Consulta: MDX (Multidimensional Expressions)

---

## 🗂️ Modelo de Datos (Data Warehouse)

El Data Warehouse está diseñado bajo un Esquema de Estrella (Star Schema), el estándar en Business Intelligence por su alto rendimiento en consultas analíticas y su simplicidad estructural.

## 📌 Ventajas del Esquema de Estrella

* Menor número de JOINs
* Consultas más rápidas
* Modelo intuitivo para análisis OLAP

---

## 🧾 Tabla de Hechos: fact_ventas

Representa el centro del análisis y almacena los eventos transaccionales del negocio.

### Granularidad

Cada fila representa una venta individual ocurrida en un momento específico. Esta granularidad fina permite la máxima flexibilidad en el análisis.

### Claves Foráneas

* producto_id → Conecta con Dimensión Producto
* pais_id → Conecta con Dimensión Geográfica

### Métricas (Measures)

Son los valores numéricos que serán objeto de operaciones matemáticas (suma, promedio, min, max).

* cantidad (INT): Métrica aditiva que representa el volumen físico de productos movidos.
* total_dinero (DECIMAL): Métrica aditiva que representa el ingreso económico. Al ser totalmente aditiva, se puede sumar coherentemente a través de todas las dimensiones (por país, por categoría, por fecha, etc.).

Ambas métricas son aditivas, lo que permite agregarlas coherentemente en cualquier dimensión.

---

## 🧩 Tablas de Dimensión

Las dimensiones proporcionan el "contexto" a los hechos numéricos (el Qué y el Dónde). A diferencia de las bases de datos transaccionales, aquí las tablas están desnormalizadas intencionalmente para mejorar el rendimiento de lectura. 

**🔹 dim_producto**

Describe qué se vendió.

* Jerarquía: Categoría → Nombre
* Permite comparar el rendimiento entre líneas de negocio

*Ejemplo de análisis:*

¿Qué categoría genera más ingresos?

<br>


**🔹 dim_pais**

Describe dónde ocurrió la venta.

* Jerarquía: Región → País
* Permite operaciones de Roll-Up y Drill-Down

*Ejemplo de análisis:*

Comparar ventas por región o por país

---

## ⚙️ Instalación y Configuración

**1️⃣ Instalación del Motor de Base de Datos**

Instalar SQL Server 2019 Developer Edition.

*⚠️ Nota importante:
Se utiliza la versión 2019 estable y no versiones Preview (como 2025) para evitar problemas de compatibilidad con Visual Studio.*

Durante la instalación, seleccionar obligatoriamente:

* Database Engine Services
* Analysis Services

<br>

**2️⃣ Configuración de Analysis Services**

En la configuración de Analysis Services:

* Seleccionar Multidimensional and Data Mining Mode

*⚠️ Si se deja el modo Tabular, no será posible crear cubos multidimensionales tradicionales.*

<br>

**3️⃣ Preparación del Entorno de Diseño**

Instalar Visual Studio 2019 Community.

1. Seleccionar la carga de trabajo Procesamiento de datos
2. Instalar la extensión: **Microsoft Analysis Services Projects**

---

## 🗄️ Implementación de la Base de Datos

Utilizar SQL Server Management Studio (SSMS) para preparar el Data Warehouse. 

**1️⃣ Conexión Inicial**

Abrir SSMS y conectarse al servidor localhost (o .) utilizando autenticación de Windows.

**2️⃣ Ejecución del Script DDL**

Que se encuentra en el repositorio. Abrir una nueva consulta y ejecutar el código para crear la estructura.

**3️⃣ Carga de Datos (ETL Simulado)**

Para tener datos suficientes para el análisis, ejecutar el siguiente bloque de código que simula 1,000 transacciones:

~~~
DECLARE @i INT = 0;
WHILE @i < 1000
BEGIN
    INSERT INTO fact_ventas (producto_id, pais_id, cantidad, total_dinero)
    VALUES (
        FLOOR(RAND()*4+1),
        FLOOR(RAND()*3+1),
        FLOOR(RAND()*10+1),
        CAST((RAND()*500+10) AS DECIMAL(10,2))
    );
    SET @i = @i + 1;
END
~~~









---

## 🧩 Creación del Cubo en Visual Studio

**1️⃣ Crear la Solución**

Abrir Visual Studio y crear un nuevo proyecto de tipo "Analysis Services Multidimensional".

**2️⃣ Definir el Origen de Datos**

1. Clic derecho en "Orígenes de datos" -> Nuevo origen de datos. 
2. Conectar al servidor localhost y seleccionar la base OLAP_Ventas_DB. 
3. Configuración de Driver: Asegurarse de seleccionar Microsoft OLE DB Driver for SQL Server en la lista de proveedores para garantizar estabilidad. 

**3️⃣ Vista del Origen de Datos (DSV)**

Crear una nueva vista seleccionando las tres tablas clave: *fact_ventas, dim_producto y dim_pais.* Esto permite visualizar el esquema de estrella gráficamente.

**4️⃣ Diseño del Cubo**

1. Clic derecho en "Cubos" -> Nuevo Cubo. 
2. Usar la opción "Usar tablas existentes". 
3. Seleccionar fact_ventas como la tabla de Grupo de Medidas. 
4. Permitir que el asistente detecte las dimensiones automáticamente. 

**5️⃣ Ajustes Manuales**

Por defecto, el asistente solo activa los IDs. Para ver nombres reales:

1. Abrir la dimensión Dim Producto. 
2. Arrastrar la columna Nombre desde la vista de origen a la lista de atributos. 
3. Repetir el proceso para Dim Pais con las columnas País y Región. 

---

## 🔐 Configuración Crítica de Seguridad y Permisos

Debido a los protocolos estrictos de SQL Server 2019, es necesario realizar ajustes manuales para permitir que el cubo procese los datos. 

**1️⃣ La "Invitación VIP" (Permisos del Servicio OLAP)**

El servicio de Analysis Services (MSSQLServerOLAPService) actúa como un usuario independiente. Para que pueda leer la base de datos relacional, se debe ejecutar la siguiente consulta en SSMS para otorgarle permisos de administrador (sysadmin), este mismo se encuentra en el repositorio para su uso:

~~~
USE [master];
GO
CREATE LOGIN [NT SERVICE\MSSQLServerOLAPService] FROM WINDOWS;
GO
ALTER SERVER ROLE [sysadmin]
ADD MEMBER [NT SERVICE\MSSQLServerOLAPService];
GO
~~~

*⚠️ Esta acción es fundamental; sin ella, el cubo reportará errores de "Acceso denegado" al intentar procesar.*

<br></br>
**2️⃣ Certificados**

En la cadena de conexión del Data Source en Visual Studio (Botón "Editar" -> "Avanzadas"), cambiar la propiedad:

~~~
TrustServerCertificate = True
~~~

<br></br>
**3️⃣ Configuración de Suplantación**

En la pestaña "Información de suplantación" del Origen de Datos, seleccionar "Utilizar la cuenta de servicio". Esto instruye al cubo a usar las credenciales que autorizamos en el Paso 1.






---

## 📊 Consultas MDX Implementadas

Se realizaron pruebas de explotación del cubo mediante consultas MDX (Multidimensional Expressions).

**🔹 Drill-Down (Desglose)**

Tomamos la medida general y bajamos un nivel de detalle para ver su distribución geográfica. 

~~~
SELECT
    {[Measures].[Total Dinero]} ON COLUMNS,
    {[Dim Pais].[Pais].CHILDREN} ON ROWS
FROM [OLAP_Ventas_DB]
~~~

<br></br>
**🔹 Pivot (Rotación)**

Cruzamos dos dimensiones (País en columnas y Producto en filas) creando una matriz de análisis. 

~~~
SELECT
    {[Dim Pais].[Pais].MEMBERS} ON COLUMNS,
    {[Dim Producto].[Nombre].MEMBERS} ON ROWS
FROM [OLAP_Ventas_DB]
WHERE ([Measures].[Total Dinero])
~~~

<br></br>
**🔹 Dice (Trocear/Dado)**

Recortamos un sub-cubo específico aplicando filtros simultáneos en múltiples dimensiones. 

~~~
SELECT
    {[Measures].[Cantidad], [Measures].[Total Dinero]} ON COLUMNS,
    {[Dim Producto].[Nombre].MEMBERS} ON ROWS
FROM [OLAP_Ventas_DB]
WHERE (
    [Dim Pais].[Pais].&[Mexico],
    [Dim Producto].[Categoria].&[Electronica]
)
~~~

---

## 🎓 Conclusiones

* Trabajar con versiones estables es clave para evitar errores de compatibilidad.
* La configuración de seguridad es el paso más crítico en SSAS.
* Visual Studio acelera el desarrollo gracias a la detección automática del esquema estrella.
* El modelo multidimensional permite análisis profundos y flexibles.

---

## 👥 Autores

Proyecto desarrollado por:

* Cruz Guzmán Carlos Alberto
* De La Rosa Hernández Tania
* Delgadillo Díaz Damián
* González González Erick Emiliano
* González Hernández Judith
* Magaña Fierro Elka Natalia
* Sánchez Ixmatlahua Kathia Jazmín
* Soto Nieves Uriel

---

📘 Materia: Bases de Datos
