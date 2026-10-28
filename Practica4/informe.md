<p align="center">

  <img src="../figures/EPN-color.png" alt="Escudo de la Escuela Politécnica Nacional" width="150">

</p>

<h1 align="center">Escuela Politécnica Nacional</h1>

<h2 align="center">Business Intelligence</h2>

<h3 align="center">Práctica 4: Implementación física de una dimensión para un modelo estrella en PostgreSQL</h3>

**Curso:** GR2SW

**Integrantes:**

- Arroyo Juan

- Echeverría Gabriela

- Sarmiento Néstor

- Villavicencio Michelle

**Fecha:** 27/10/2026

---

## Índice de contenidos

- [1. Introducción](#1-introducción)
- [2. Objetivos](#2-objetivos)
  - [2.1. Objetivo general](#21-objetivo-general)
  - [2.2. Objetivos específicos](#22-objetivos-específicos)
- [3. Fuentes de datos utilizadas](#3-fuentes-de-datos-utilizadas)
  - [3.1. Fuente 1: products.csv](#31-fuente-1-productscsv)
  - [3.2. Fuente 2: Tabla_Desnormalizada_Ventas.xlsx](#32-fuente-2-tabla_desnormalizada_ventasxlsx)
- [4. Diseño dimensional](#4-diseño-dimensional)
  - [4.1. Análisis del dataset de productos](#41-análisis-del-dataset-de-productos)
  - [4.2. Estructura de la dimensión dim_product](#42-estructura-de-la-dimensión-dim_product)
  - [4.3. Categoría y subcategoría dentro de dim_product](#43-categoría-y-subcategoría-dentro-de-dim_product)
  - [4.4. Modelo estrella de ventas](#44-modelo-estrella-de-ventas)
- [5. Problemas identificados en los datos](#5-problemas-identificados-en-los-datos)
  - [5.1. Problemas en products.csv](#51-problemas-en-productscsv)
  - [5.2. Problemas en la tabla desnormalizada de ventas](#52-problemas-en-la-tabla-desnormalizada-de-ventas)
- [6. Proceso ETL de products.csv](#6-proceso-etl-de-productscsv)
  - [6.1. Vista general del flujo](#61-vista-general-del-flujo)
  - [6.2. Creación de la tabla de staging](#62-creación-de-la-tabla-de-staging)
  - [6.3. Importación de products.csv](#63-importación-de-productscsv)
  - [6.4. Validación del dataset importado](#64-validación-del-dataset-importado)
  - [6.5. Limpieza de los datos](#65-limpieza-de-los-datos)
  - [6.6. Creación y carga de dim_product](#66-creación-y-carga-de-dim_product)
  - [6.7. Consultas de análisis sobre dim_product](#67-consultas-de-análisis-sobre-dim_product)
    - [6.7.1. Productos por categoría](#671-productos-por-categoría)
    - [6.7.2. Productos por subcategoría](#672-productos-por-subcategoría)
    - [6.7.3. Productos de la categoría Beauty and Hygiene](#673-productos-de-la-categoría-beauty-and-hygiene)
    - [6.7.4. Productos de la subcategoría Biscuits and Cookies](#674-productos-de-la-subcategoría-biscuits-and-cookies)
    - [6.7.5. Número de subcategorías por categoría](#675-número-de-subcategorías-por-categoría)
- [7. Proceso ETL de la tabla de ventas](#7-proceso-etl-de-la-tabla-de-ventas)
  - [7.1. Vista general del flujo](#71-vista-general-del-flujo)
  - [7.2. Creación de la tabla de staging stg_ventas](#72-creación-de-la-tabla-de-staging-stg_ventas)
  - [7.3. Importación de los datos de ventas](#73-importación-de-los-datos-de-ventas)
  - [7.4. Validación de stg_ventas](#74-validación-de-stg_ventas)
  - [7.5. Limpieza de los datos de ventas](#75-limpieza-de-los-datos-de-ventas)
  - [7.6. Creación del esquema estrella dw_ventas](#76-creación-del-esquema-estrella-dw_ventas)
  - [7.7. Carga del modelo estrella](#77-carga-del-modelo-estrella)
  - [7.8. Consultas de negocio sobre el modelo estrella](#78-consultas-de-negocio-sobre-el-modelo-estrella)
    - [7.8.1. Ventas por categoría de producto y mes](#781-ventas-por-categoría-de-producto-y-mes)
    - [7.8.2. Ingreso total por cliente y género](#782-ingreso-total-por-cliente-y-género)
    - [7.8.3. Cantidad total vendida por producto](#783-cantidad-total-vendida-por-producto)
    - [7.8.4. Cantidad enviada por mes de envío](#784-cantidad-enviada-por-mes-de-envío)
    - [7.8.5. Ventas por tamaño de producto y estado civil del cliente](#785-ventas-por-tamaño-de-producto-y-estado-civil-del-cliente)
- [8. Scripts SQL entregables](#8-scripts-sql-entregables)
- [9. Relación con una arquitectura Data Warehouse](#9-relación-con-una-arquitectura-data-warehouse)
- [10. Conclusiones](#10-conclusiones)
- [11. Referencias bibliográficas](#11-referencias-bibliográficas)
- [12. Declaración de uso de Inteligencia Artificial](#12-declaración-de-uso-de-inteligencia-artificial)

---

## Índice de figuras

- [Figura 1. Diagrama del modelo estrella de ventas en Power Pivot](#figura-1)
- [Figura 2. Creación de la tabla de staging stg_products](#figura-2)
- [Figura 3. Verificación de la estructura de stg_products](#figura-3)
- [Figura 4. Importación de products.csv mediante \copy](#figura-4)
- [Figura 5. Validación del número de registros](#figura-5)
- [Figura 6. Validación de identificadores de producto únicos](#figura-6)
- [Figura 7. Validación del número de categorías y subcategorías](#figura-7)
- [Figura 8. Limpieza de texto en stg_products](#figura-8)
- [Figura 9. Verificación de identificadores duplicados](#figura-9)
- [Figura 10. Verificación de identificadores nulos o vacíos](#figura-10)
- [Figura 11. Creación de la dimensión dim_product](#figura-11)
- [Figura 12. Carga de dim_product desde staging](#figura-12)
- [Figura 13. Conteo de registros cargados en dim_product](#figura-13)
- [Figura 14. Primeros 20 registros de dim_product](#figura-14)
- [Figura 15. Productos por categoría](#figura-15)
- [Figura 16. Productos por subcategoría](#figura-16)
- [Figura 17. Productos de la categoría Beauty & Hygiene](#figura-17)
- [Figura 18. Productos de la subcategoría Biscuits & Cookies](#figura-18)
- [Figura 19. Número de subcategorías por categoría](#figura-19)
- [Figura 20. Creación de la tabla de staging stg_ventas](#figura-20)
- [Figura 21. Importación de los datos de ventas mediante \copy](#figura-21)
- [Figura 22. Conteos generales en stg_ventas](#figura-22)
- [Figura 23. Verificación de ventas duplicadas](#figura-23)
- [Figura 24. Verificación de campos obligatorios nulos](#figura-24)
- [Figura 25. Verificación de las claves de fecha](#figura-25)
- [Figura 26. Limpieza de texto en stg_ventas](#figura-26)
- [Figura 27. Creación del esquema dw_ventas](#figura-27)
- [Figura 28. Creación de dw_ventas.dim_product](#figura-28)
- [Figura 29. Creación de dw_ventas.dim_customer](#figura-29)
- [Figura 30. Creación de dw_ventas.dim_date](#figura-30)
- [Figura 31. Creación de dw_ventas.fact_sales](#figura-31)
- [Figura 32. Tablas creadas en el esquema dw_ventas](#figura-32)
- [Figura 33. Carga de dw_ventas.dim_product](#figura-33)
- [Figura 34. Carga de dw_ventas.dim_customer](#figura-34)
- [Figura 35. Carga de dw_ventas.dim_date](#figura-35)
- [Figura 36. Carga de dw_ventas.fact_sales](#figura-36)
- [Figura 37. Conteo de registros por tabla en dw_ventas](#figura-37)
- [Figura 38. Totales de cantidad y ventas en fact_sales](#figura-38)
- [Figura 39. Ventas por categoría de producto y mes](#figura-39)
- [Figura 40. Ingreso total por cliente y género](#figura-40)
- [Figura 41. Cantidad total vendida por producto](#figura-41)
- [Figura 42. Cantidad enviada por mes de envío](#figura-42)
- [Figura 43. Ventas por tamaño de producto y estado civil del cliente](#figura-43)

---

## Índice de tablas

- [Tabla 1. Estructura del archivo products.csv](#tabla-1)
- [Tabla 2. Hojas del archivo Tabla_Desnormalizada_Ventas.xlsx](#tabla-2)
- [Tabla 3. Análisis dimensional de products.csv](#tabla-3)
- [Tabla 4. Estructura física de dim_product](#tabla-4)
- [Tabla 5. Componentes del modelo estrella de ventas](#tabla-5)
- [Tabla 6. Problemas identificados en products.csv](#tabla-6)
- [Tabla 7. Problemas identificados en la tabla desnormalizada de ventas](#tabla-7)
- [Tabla 8. Transformaciones aplicadas sobre stg_products](#tabla-8)
- [Tabla 9. Configuración de la importación de products.csv](#tabla-9)
- [Tabla 10. Resultados de validación de stg_products](#tabla-10)
- [Tabla 11. Transformaciones aplicadas en el proceso de ventas](#tabla-11)
- [Tabla 12. Configuración de la importación de Tabla_Desnormalizada_Ventas.csv](#tabla-12)
- [Tabla 13. Resultados de validación de stg_ventas](#tabla-13)
- [Tabla 14. Estructura de las tablas del esquema dw_ventas](#tabla-14)
- [Tabla 15. Registros cargados en el esquema dw_ventas](#tabla-15)

---

## 1. Introducción

<p align="justify">
En esta práctica se cargaron datos en PostgreSQL pasando primero por un área de staging, donde se validaron y limpiaron, y luego hacia un modelo dimensional. Se trabajó con dos fuentes. Con products.csv se construyó la dimensión de producto que pide la guía. Como ese archivo no tiene ventas, para responder las cinco preguntas del trabajo en grupo se aplicó el mismo proceso a Tabla_Desnormalizada_Ventas.xlsx y se armó con ella un esquema estrella completo.
</p>

---

## 2. Objetivos

### 2.1. Objetivo general

<p align="justify">
Implementar en PostgreSQL un flujo de staging, limpieza y carga hacia un modelo dimensional, primero para la dimensión de producto y luego para un esquema estrella de ventas.
</p>

### 2.2. Objetivos específicos

- Crear tablas de staging e importar los archivos fuente.
- Validar y limpiar los datos antes de cargarlos al modelo.
- Implementar dim_product con una clave sustituta.
- Justificar por qué categoría y subcategoría se mantienen en la dimensión.
- Modelar las ventas como esquema estrella y responder las cinco preguntas de negocio con SQL.

---

## 3. Fuentes de datos utilizadas

### 3.1. Fuente 1: products.csv

<p align="justify">
El archivo <a href="source_data/products.csv">products.csv</a> tiene 699 productos, 10 categorías y 53 subcategorías. Solo contiene atributos descriptivos, sin ventas ni medidas. Sus columnas se muestran en la Tabla 1.
</p>

<a id="tabla-1"></a>

**Tabla 1. Estructura del archivo products.csv.**

| Columna en el CSV | Columna en staging | Ejemplo |
| --- | --- | --- |
| product_id | product_id | P0001 |
| product (brand) | product_name | hand wash - moisture Shield (Savlon) |
| category | category | Beauty & Hygiene |
| sub_category | subcategory | Hair Care |

*Descripción: columnas del archivo y su nombre en staging.*

### 3.2. Fuente 2: Tabla_Desnormalizada_Ventas.xlsx

<p align="justify">
El archivo <a href="source_data/Tabla_Desnormalizada_Ventas.xlsx">Tabla_Desnormalizada_Ventas.xlsx</a> registra 100 ventas entre enero de 2022 y diciembre de 2025, con datos de producto, cliente, fechas y montos en una sola hoja de 26 columnas. Sus productos (P104 a P143) no tienen relación con los de products.csv. Las hojas del libro se describen en la Tabla 2.
</p>

<a id="tabla-2"></a>

**Tabla 2. Hojas del archivo Tabla_Desnormalizada_Ventas.xlsx.**

| Hoja | Filas | Uso |
| --- | --- | --- |
| VentasDesnormalizada | 100 | Fuente cargada en staging |
| fact_sales | 100 | Tabla de hechos en Power Pivot |
| dim_product | 9 | Dimensión de producto en Power Pivot |
| dim_costumer | 10 | Dimensión de cliente en Power Pivot |
| dim_date | 61 | Dimensión de fecha en Power Pivot |

*Descripción: hojas del libro de Excel y su uso en el modelo.*

---

## 4. Diseño dimensional

### 4.1. Análisis del dataset de productos

<p align="justify">
Como se resume en la Tabla 3, products.csv no tiene eventos ni medidas, por lo que su rol en el modelo es el de una dimensión.
</p>

<a id="tabla-3"></a>

**Tabla 3. Análisis dimensional de products.csv.**

| Pregunta | Respuesta |
| --- | --- |
| ¿Qué entidad describe? | Producto |
| ¿Contiene un evento de negocio? | No |
| ¿Contiene medidas? | No |
| Rol en un modelo estrella | Dimensión de producto (dim_product) |

*Descripción: análisis previo al diseño físico.*

### 4.2. Estructura de la dimensión dim_product

<p align="justify">
La Tabla 4 muestra la estructura de la dimensión. La clave primaria es product_key, una clave sustituta generada por PostgreSQL; el código original se guarda en product_id para mantener la relación con la fuente.
</p>

<a id="tabla-4"></a>

**Tabla 4. Estructura física de dim_product.**

| Columna | Tipo | Restricción |
| --- | --- | --- |
| product_key | BIGSERIAL | PRIMARY KEY |
| product_id | VARCHAR(5) | NOT NULL, UNIQUE |
| product_name | VARCHAR(150) | NOT NULL |
| category | VARCHAR(80) | NOT NULL |
| subcategory | VARCHAR(80) | NOT NULL |

*Descripción: columnas, tipos y restricciones de dim_product.*

### 4.3. Categoría y subcategoría dentro de dim_product

<p align="justify">
Categoría y subcategoría se mantienen en la misma dimensión aunque sus valores se repitan. Así se puede agrupar y filtrar sin uniones adicionales. Separarlas en otras tablas sería normalizar el modelo y convertirlo en un copo de nieve.
</p>

### 4.4. Modelo estrella de ventas

<p align="justify">
En este informe hay dos dimensiones de producto distintas. <b>public.dim_product</b> viene de products.csv y tiene 699 productos (sección 6). <b>dw_ventas.dim_product</b> viene de la tabla de ventas y tiene 9 productos (sección 7). Al ser fuentes diferentes, no comparten registros; por eso el modelo de ventas se creó en el esquema aparte dw_ventas.
</p>

<p align="justify">
La tabla de ventas se separó en una tabla de hechos y tres dimensiones (Tabla 5). Cada fila de fact_sales es una línea de pedido. La dimensión de fecha se relaciona dos veces con los hechos: por la fecha de pedido y por la de envío.
</p>

<a id="tabla-5"></a>

**Tabla 5. Componentes del modelo estrella de ventas.**

| Tabla | Tipo | Atributos o medidas |
| --- | --- | --- |
| fact_sales | Hechos | Quantity, UnitPrice, ProductCost, SalesAmount |
| dim_product | Dimensión | Product Code, Product Name, List Price, Color, Size, Category, Subcategory |
| dim_customer | Dimensión | Birth Date, Marital Status, Gender, Income, Children, Home Owner, Cars |
| dim_date | Dimensión | Fecha, año, trimestre, mes y día |

*Descripción: tablas del modelo de ventas.*

<p align="justify">
El diagrama del modelo en Power Pivot se muestra en la Figura 1. Power Pivot solo admite una relación activa entre dos tablas, por eso la segunda relación con dim_date aparece punteada.
</p>

<a id="figura-1"></a>

**Figura 1. Diagrama del modelo estrella de ventas en Power Pivot.**

<p align="center">

  <img src="img/esquema_estrella.png" alt="Diagrama del modelo estrella de ventas en Power Pivot" width="800">

</p>

*Descripción: fact_sales relacionada con dim_product, dim_costumer y dim_date (pedido y envío).*

---

## 5. Problemas identificados en los datos

### 5.1. Problemas en products.csv

<p align="justify">
Los problemas encontrados en el archivo de productos se listan en la Tabla 6.
</p>

<a id="tabla-6"></a>

**Tabla 6. Problemas identificados en products.csv.**

| Problema | Ejemplo | Registros | Tratamiento |
| --- | --- | --- | --- |
| Tabulaciones en el nombre | P0000: serum (Livon) | 5 | regexp_replace |
| Espacios repetidos en el nombre | good day butter Cookies | 6 | regexp_replace |
| Espacios al inicio o al final | P0000 | 4 | btrim |
| Encabezados distintos al modelo | product (brand), sub_category | — | Carga por posición |
| Producto sin nombre | P0748: "()" | 1 | Se conserva y se documenta |
| Categorías incoherentes | Banana - Raw en Biscuits & Cookies | Varios | Se conservan |
| Códigos no consecutivos | No existe P0003 | 50 | No afecta a la clave sustituta |

*Descripción: problemas de products.csv y su tratamiento.*

### 5.2. Problemas en la tabla desnormalizada de ventas

<p align="justify">
Los datos de ventas no tenían nulos ni filas repetidas; sus problemas eran de estructura (Tabla 7).
</p>

<a id="tabla-7"></a>

**Tabla 7. Problemas identificados en la tabla desnormalizada de ventas.**

| Problema | Tratamiento |
| --- | --- |
| Producto, cliente, fechas y medidas en una sola tabla | Separación en hechos y dimensiones |
| Productos y clientes repetidos en las 100 filas | Cada uno se guarda una vez en su dimensión |
| Dos fechas por venta (pedido y envío) | Una sola dim_date con dos relaciones |
| La hoja dim_date no incluye todas las fechas de envío | dim_date se llenó con ambas fechas |
| El CSV exportado usa punto y coma como separador | Se indicó DELIMITER ';' al importar |
| Hoja con nombre dim_costumer | En PostgreSQL se llamó dim_customer |

*Descripción: problemas de la tabla de ventas y su tratamiento.*

---

## 6. Proceso ETL de products.csv

### 6.1. Vista general del flujo

<p align="justify">
Se siguió el orden de la guía: staging, importación, validación, limpieza, carga de la dimensión y consultas. Las transformaciones aplicadas se resumen en la Tabla 8.
</p>

<a id="tabla-8"></a>

**Tabla 8. Transformaciones aplicadas sobre stg_products.**

| Columna | Transformación |
| --- | --- |
| product_name | Recorte de extremos y un solo espacio en lugar de espacios o tabulaciones repetidos |
| category | Recorte de extremos |
| subcategory | Recorte de extremos |
| product_key | Clave sustituta generada con BIGSERIAL |

*Descripción: transformaciones aplicadas en staging y en la carga.*

### 6.2. Creación de la tabla de staging

<p align="justify">
Se ejecutó el script de creación de stg_products con las cuatro columnas del archivo (Figura 2) y luego se consultó la tabla para confirmar su estructura (Figura 3).
</p>

<a id="figura-2"></a>

**Figura 2. Creación de la tabla de staging stg_products.**

<p align="center">

  <img src="img/crear_stg_products.png" alt="Creación de la tabla stg_products en pgAdmin" width="600">

</p>

*Descripción: tabla creada sin errores.*

<a id="figura-3"></a>

**Figura 3. Verificación de la estructura de stg_products.**

<p align="center">

  <img src="img/verificar_tabla_stg_prudcts.png" alt="Verificación de la tabla stg_products vacía" width="750">

</p>

*Descripción: tabla vacía con sus cuatro columnas.*

### 6.3. Importación de products.csv

<p align="justify">
La práctica se realizó en macOS, donde la opción Import/Export Data de pgAdmin no permitió importar el archivo de forma visual. Por eso se usó el comando \copy de psql con la misma configuración (Tabla 9).
</p>

<a id="tabla-9"></a>

**Tabla 9. Configuración de la importación de products.csv.**

| Parámetro | Valor |
| --- | --- |
| Herramienta | psql (\copy) en macOS |
| Tabla destino | public.stg_products |
| Formato | CSV |
| Encabezado | Sí |
| Delimitador | , |
| Codificación | UTF-8 |

*Descripción: parámetros de la importación.*

<p align="justify">
El comando cargó los 699 registros, como se observa en la Figura 4.
</p>

<a id="figura-4"></a>

**Figura 4. Importación de products.csv mediante \copy.**

<p align="center">

  <img src="img/importar_data.png" alt="Importación de products.csv con el comando copy de psql" width="850">

</p>

*Descripción: resultado COPY 699.*

### 6.4. Validación del dataset importado

<p align="justify">
Se ejecutaron las consultas de validación y los resultados coincidieron con los valores esperados (Tabla 10): 699 registros (Figura 5), 699 códigos únicos (Figura 6) y 10 categorías con 53 subcategorías (Figura 7).
</p>

<a id="tabla-10"></a>

**Tabla 10. Resultados de validación de stg_products.**

| Validación | Esperado | Obtenido |
| --- | --- | --- |
| Registros | 699 | 699 |
| product_id únicos | 699 | 699 |
| Categorías | 10 | 10 |
| Subcategorías | 53 | 53 |

*Descripción: comparación entre los valores esperados y los obtenidos.*

<a id="figura-5"></a>

**Figura 5. Validación del número de registros.**

<p align="center">

  <img src="img/num_registros.png" alt="Conteo de registros en stg_products" width="500">

</p>

*Descripción: total de registros en staging.*

<a id="figura-6"></a>

**Figura 6. Validación de identificadores de producto únicos.**

<p align="center">

  <img src="img/productos_unicos.png" alt="Conteo de product_id únicos en stg_products" width="600">

</p>

*Descripción: product_id distintos.*

<a id="figura-7"></a>

**Figura 7. Validación del número de categorías y subcategorías.**

<p align="center">

  <img src="img/categorias_subcategorias.png" alt="Conteo de categorías y subcategorías distintas" width="600">

</p>

*Descripción: categorías y subcategorías distintas.*

### 6.5. Limpieza de los datos

<p align="justify">
Se ejecutó un UPDATE sobre staging que limpió los espacios y tabulaciones de los 699 registros (Figura 8). Un detalle: btrim no elimina tabulaciones, así que el nombre de P0000 quedó con un espacio al inicio (Figura 14). Aplicar btrim después de regexp_replace lo evitaría.
</p>

<a id="figura-8"></a>

**Figura 8. Limpieza de texto en stg_products.**

<p align="center">

  <img src="img/limpieza_datos.png" alt="UPDATE de limpieza sobre stg_products" width="800">

</p>

*Descripción: UPDATE de 699 registros.*

<p align="justify">
Después se comprobó que no hubiera códigos duplicados (Figura 9) ni nulos o vacíos (Figura 10); ambas consultas no devolvieron filas.
</p>

<a id="figura-9"></a>

**Figura 9. Verificación de identificadores duplicados.**

<p align="center">

  <img src="img/verificar_duplicados.png" alt="Consulta de product_id duplicados sin resultados" width="500">

</p>

*Descripción: sin duplicados.*

<a id="figura-10"></a>

**Figura 10. Verificación de identificadores nulos o vacíos.**

<p align="center">

  <img src="img/verificar_nulos.png" alt="Consulta de product_id nulos o vacíos sin resultados" width="750">

</p>

*Descripción: sin nulos ni vacíos.*

### 6.6. Creación y carga de dim_product

<p align="justify">
Se creó dim_product con la estructura de la Tabla 4 (Figura 11) y se cargó desde staging, con 699 filas insertadas (Figura 12).
</p>

<a id="figura-11"></a>

**Figura 11. Creación de la dimensión dim_product.**

<p align="center">

  <img src="img/crear_dim.png" alt="Creación de la tabla dim_product" width="650">

</p>

*Descripción: DDL de dim_product.*

<a id="figura-12"></a>

**Figura 12. Carga de dim_product desde staging.**

<p align="center">

  <img src="img/cargar_dim.png" alt="INSERT SELECT desde stg_products hacia dim_product" width="700">

</p>

*Descripción: INSERT 0 699.*

<p align="justify">
El conteo de la dimensión dio 699 registros (Figura 13). En la Figura 14 se ve que product_key es consecutiva aunque product_id salte de P0002 a P0004, y que los nombres ya están limpios.
</p>

<a id="figura-13"></a>

**Figura 13. Conteo de registros cargados en dim_product.**

<p align="center">

  <img src="img/verificar_carga_dim.png" alt="Conteo de registros en dim_product" width="650">

</p>

*Descripción: 699 registros en la dimensión.*

<a id="figura-14"></a>

**Figura 14. Primeros 20 registros de dim_product.**

<p align="center">

  <img src="img/tabla_dim.png" alt="Primeros 20 registros de dim_product" width="850">

</p>

*Descripción: primeros registros ordenados por product_key.*

### 6.7. Consultas de análisis sobre dim_product

#### 6.7.1. Productos por categoría

<p align="justify">
La categoría con más productos es Snacks & Branded Foods (227) y la que menos tiene es Baby Care (2), como se observa en la Figura 15.
</p>

<a id="figura-15"></a>

**Figura 15. Productos por categoría.**

<p align="center">

  <img src="img/productos_categoria.png" alt="Número de productos por categoría" width="500">

</p>

*Descripción: productos por categoría, de mayor a menor.*

#### 6.7.2. Productos por subcategoría

<p align="justify">
Las subcategorías con más productos son Snacks & Namkeen (75), Fresh Vegetables (66) y Masalas & Spices (60) (Figura 16).
</p>

<a id="figura-16"></a>

**Figura 16. Productos por subcategoría.**

<p align="center">

  <img src="img/productos_subcategoria.png" alt="Número de productos por subcategoría" width="500">

</p>

*Descripción: primeras diez subcategorías.*

#### 6.7.3. Productos de la categoría Beauty and Hygiene

<p align="justify">
El filtro por la categoría Beauty & Hygiene devuelve sus 48 productos (Figura 17).
</p>

<a id="figura-17"></a>

**Figura 17. Productos de la categoría Beauty & Hygiene.**

<p align="center">

  <img src="img/categoria_beauty.png" alt="Productos de la categoría Beauty & Hygiene" width="600">

</p>

*Descripción: productos de Beauty & Hygiene ordenados por nombre.*

#### 6.7.4. Productos de la subcategoría Biscuits and Cookies

<p align="justify">
El filtro por Biscuits & Cookies devuelve productos de Snacks & Branded Foods, entre ellos P0748 sin nombre y Banana - Raw, ya señalados en la Tabla 6 (Figura 18).
</p>

<a id="figura-18"></a>

**Figura 18. Productos de la subcategoría Biscuits & Cookies.**

<p align="center">

  <img src="img/subcategoria_biscuits.png" alt="Productos de la subcategoría Biscuits & Cookies" width="750">

</p>

*Descripción: productos de Biscuits & Cookies ordenados por nombre.*

#### 6.7.5. Número de subcategorías por categoría

<p align="justify">
Snacks & Branded Foods tiene 8 subcategorías, mientras que Baby Care y Kitchen, Garden & Pets tienen 2 (Figura 19).
</p>

<a id="figura-19"></a>

**Figura 19. Número de subcategorías por categoría.**

<p align="center">

  <img src="img/subcategoria_por_categoria.png" alt="Número de subcategorías por categoría" width="600">

</p>

*Descripción: subcategorías distintas por categoría.*

---

## 7. Proceso ETL de la tabla de ventas

### 7.1. Vista general del flujo

<p align="justify">
Se repitió el proceso de la sección 6 con la tabla de ventas: la hoja VentasDesnormalizada se exportó a CSV, se cargó en public.stg_ventas y desde ahí se llenó el esquema dw_ventas. Las dimensiones de producto y cliente usan claves sustitutas y guardan la clave original en source_product_key y source_customer_key. Las transformaciones se resumen en la Tabla 11.
</p>

<a id="tabla-11"></a>

**Tabla 11. Transformaciones aplicadas en el proceso de ventas.**

| Paso | Transformación |
| --- | --- |
| Limpieza | Recorte de espacios en los campos de texto y género en mayúsculas |
| Carga de dimensiones | SELECT DISTINCT desde staging y claves sustitutas |
| Carga de dim_date | Unión de fechas de pedido y envío; cálculo de año, trimestre, mes y día |
| Carga de hechos | Reemplazo de las claves originales por las claves sustitutas |

*Descripción: transformaciones del flujo de ventas.*

### 7.2. Creación de la tabla de staging stg_ventas

<p align="justify">
Se creó stg_ventas con las 26 columnas del archivo, ya con tipos numéricos y de fecha (Figura 20).
</p>

<a id="figura-20"></a>

**Figura 20. Creación de la tabla de staging stg_ventas.**

<p align="center">

  <img src="img/crear_stg_ventas.png" alt="Creación de la tabla stg_ventas" width="550">

</p>

*Descripción: DDL de stg_ventas.*

### 7.3. Importación de los datos de ventas

<p align="justify">
Se usó \copy igual que en la sección 6.3, cambiando el delimitador a punto y coma (Tabla 12). Se cargaron las 100 ventas (Figura 21).
</p>

<a id="tabla-12"></a>

**Tabla 12. Configuración de la importación de Tabla_Desnormalizada_Ventas.csv.**

| Parámetro | Valor |
| --- | --- |
| Tabla destino | public.stg_ventas |
| Formato | CSV |
| Encabezado | Sí |
| Delimitador | ; |
| Codificación | UTF-8 |

*Descripción: parámetros de la importación de ventas.*

<a id="figura-21"></a>

**Figura 21. Importación de los datos de ventas mediante \copy.**

<p align="center">

  <img src="img/importar_data_ventas.png" alt="Importación del CSV de ventas con copy" width="850">

</p>

*Descripción: resultado COPY 100.*

### 7.4. Validación de stg_ventas

<p align="justify">
Los resultados de las validaciones se resumen en la Tabla 13. El conteo general dio 100 registros, 9 productos, 10 clientes, 100 pedidos y 2 categorías (Figura 22). No hubo pedidos repetidos (Figura 23), campos obligatorios nulos (Figura 24) ni claves de fecha que no coincidieran con su fecha (Figura 25).
</p>

<a id="tabla-13"></a>

**Tabla 13. Resultados de validación de stg_ventas.**

| Validación | Resultado |
| --- | --- |
| Registros / productos / clientes / pedidos / categorías | 100 / 9 / 10 / 100 / 2 |
| Pedidos repetidos | 0 |
| Campos obligatorios nulos | 0 |
| Claves de fecha inconsistentes | 0 |

*Descripción: validaciones sobre stg_ventas.*

<a id="figura-22"></a>

**Figura 22. Conteos generales en stg_ventas.**

<p align="center">

  <img src="img/validar_stg_ventas.png" alt="Conteos de validación de stg_ventas" width="750">

</p>

*Descripción: registros y valores distintos en staging.*

<a id="figura-23"></a>

**Figura 23. Verificación de ventas duplicadas.**

<p align="center">

  <img src="img/verificar_duplicados_ventas.png" alt="Consulta de pedidos duplicados sin resultados" width="700">

</p>

*Descripción: sin pedidos duplicados.*

<a id="figura-24"></a>

**Figura 24. Verificación de campos obligatorios nulos.**

<p align="center">

  <img src="img/verificar_nulos_ventas.png" alt="Conteo de filas con campos obligatorios nulos" width="750">

</p>

*Descripción: 0 filas con nulos.*

<a id="figura-25"></a>

**Figura 25. Verificación de las claves de fecha.**

<p align="center">

  <img src="img/verificar_fechas_ventas.png" alt="Conteo de claves de fecha inconsistentes" width="700">

</p>

*Descripción: 0 claves inconsistentes.*

### 7.5. Limpieza de los datos de ventas

<p align="justify">
Se aplicó una limpieza preventiva a los campos de texto de las 100 filas (Figura 26).
</p>

<a id="figura-26"></a>

**Figura 26. Limpieza de texto en stg_ventas.**

<p align="center">

  <img src="img/limpieza_datos_ventas.png" alt="UPDATE de limpieza sobre stg_ventas" width="800">

</p>

*Descripción: UPDATE de 100 registros.*

### 7.6. Creación del esquema estrella dw_ventas

<p align="justify">
Se creó el esquema dw_ventas (Figura 27) y dentro de él las cuatro tablas descritas en la Tabla 14.
</p>

<a id="figura-27"></a>

**Figura 27. Creación del esquema dw_ventas.**

<p align="center">

  <img src="img/crear_esquema_ventas.png" alt="Creación del esquema dw_ventas" width="500">

</p>

*Descripción: esquema creado.*

<a id="tabla-14"></a>

**Tabla 14. Estructura de las tablas del esquema dw_ventas.**

| Tabla | Clave primaria | Otras restricciones |
| --- | --- | --- |
| dim_product | product_key (BIGSERIAL) | source_product_key UNIQUE |
| dim_customer | customer_key (BIGSERIAL) | source_customer_key UNIQUE |
| dim_date | date_key (AAAAMMDD) | full_date UNIQUE |
| fact_sales | sales_key (BIGSERIAL) | Claves foráneas a las tres dimensiones, pedido y línea UNIQUE, CHECK en cantidad y montos |

*Descripción: claves y restricciones de cada tabla.*

<p align="justify">
Se crearon las dimensiones de producto (Figura 28), cliente (Figura 29) y fecha (Figura 30).
</p>

<a id="figura-28"></a>

**Figura 28. Creación de dw_ventas.dim_product.**

<p align="center">

  <img src="img/crear_dim_product.png" alt="Creación de dw_ventas.dim_product" width="650">

</p>

*Descripción: DDL de la dimensión de producto.*

<a id="figura-29"></a>

**Figura 29. Creación de dw_ventas.dim_customer.**

<p align="center">

  <img src="img/crear_dim_customer.png" alt="Creación de dw_ventas.dim_customer" width="650">

</p>

*Descripción: DDL de la dimensión de cliente.*

<a id="figura-30"></a>

**Figura 30. Creación de dw_ventas.dim_date.**

<p align="center">

  <img src="img/crear_dim_date.png" alt="Creación de dw_ventas.dim_date" width="650">

</p>

*Descripción: DDL de la dimensión de fecha.*

<p align="justify">
Al final se creó fact_sales, con dos claves foráneas hacia dim_date (Figura 31). La consulta a information_schema confirmó las cuatro tablas en el esquema (Figura 32).
</p>

<a id="figura-31"></a>

**Figura 31. Creación de dw_ventas.fact_sales.**

<p align="center">

  <img src="img/create_fact_sales.png" alt="Creación de dw_ventas.fact_sales" width="850">

</p>

*Descripción: DDL de la tabla de hechos.*

<a id="figura-32"></a>

**Figura 32. Tablas creadas en el esquema dw_ventas.**

<p align="center">

  <img src="img/verificar_tablas_sales.png" alt="Listado de tablas del esquema dw_ventas" width="450">

</p>

*Descripción: tablas del esquema dw_ventas.*

### 7.7. Carga del modelo estrella

<p align="justify">
Se cargaron 9 productos (Figura 33) y 10 clientes (Figura 34). La dimensión de fecha recibió 147 fechas, resultado de unir las de pedido y las de envío (Figura 35). Por último se cargaron las 100 ventas en fact_sales, reemplazando las claves originales por las sustitutas (Figura 36).
</p>

<a id="figura-33"></a>

**Figura 33. Carga de dw_ventas.dim_product.**

<p align="center">

  <img src="img/cargar_dim_product.png" alt="Carga de la dimensión de producto de ventas" width="800">

</p>

*Descripción: INSERT 0 9.*

<a id="figura-34"></a>

**Figura 34. Carga de dw_ventas.dim_customer.**

<p align="center">

  <img src="img/cargar_dim_customer.png" alt="Carga de la dimensión de cliente" width="800">

</p>

*Descripción: INSERT 0 10.*

<a id="figura-35"></a>

**Figura 35. Carga de dw_ventas.dim_date.**

<p align="center">

  <img src="img/cargar_dim_date.png" alt="Carga de la dimensión de fecha" width="750">

</p>

*Descripción: INSERT 0 147.*

<a id="figura-36"></a>

**Figura 36. Carga de dw_ventas.fact_sales.**

<p align="center">

  <img src="img/cargar_fact_sales.png" alt="Carga de la tabla de hechos fact_sales" width="750">

</p>

*Descripción: INSERT 0 100.*

<p align="justify">
El conteo por tabla confirmó la carga (Tabla 15 y Figura 37). La suma de las medidas de fact_sales dio 296 unidades y 69 547 en ventas (Figura 38).
</p>

<a id="tabla-15"></a>

**Tabla 15. Registros cargados en el esquema dw_ventas.**

| Tabla | Registros |
| --- | --- |
| dim_product | 9 |
| dim_customer | 10 |
| dim_date | 147 |
| fact_sales | 100 |

*Descripción: filas por tabla después de la carga.*

<a id="figura-37"></a>

**Figura 37. Conteo de registros por tabla en dw_ventas.**

<p align="center">

  <img src="img/verificar_carga_datos.png" alt="Conteo de registros de cada tabla de dw_ventas" width="800">

</p>

*Descripción: registros por tabla.*

<a id="figura-38"></a>

**Figura 38. Totales de cantidad y ventas en fact_sales.**

<p align="center">

  <img src="img/verificar_datos_fact_sales.png" alt="Suma de cantidad y monto de ventas" width="550">

</p>

*Descripción: total de unidades y de ventas.*

### 7.8. Consultas de negocio sobre el modelo estrella

<p align="justify">
Las cinco consultas están en <a href="scripts/consultas_analisis.sql">consultas_analisis.sql</a>.
</p>

#### 7.8.1. Ventas por categoría de producto y mes

<p align="justify">
Se unió fact_sales con dim_product y con dim_date por la fecha de pedido. Hubo 60 ventas de Electronics y 40 de Accessories, y junio de 2022 fue el mes con más ventas (7), como se observa en la Figura 39.
</p>

<a id="figura-39"></a>

**Figura 39. Ventas por categoría de producto y mes.**

<p align="center">

  <img src="img/ventas_categoria_mes.png" alt="Número de ventas por categoría y mes" width="750">

</p>

*Descripción: ventas por año, mes y categoría.*

#### 7.8.2. Ingreso total por cliente y género

<p align="justify">
El cliente 1022 (M) es el que más compró, con 11 656, y el 1016 (F) el que menos, con 2 496 (Figura 40). Por género, las mujeres suman 38 836 y los hombres 30 711.
</p>

<a id="figura-40"></a>

**Figura 40. Ingreso total por cliente y género.**

<p align="center">

  <img src="img/ingreso_clientes_genero.png" alt="Ingreso total por cliente y género" width="650">

</p>

*Descripción: ventas por cliente, de mayor a menor.*

#### 7.8.3. Cantidad total vendida por producto

<p align="justify">
Product 19 es el más vendido, con 60 unidades, y Product 5 el que menos, con 16 (Figura 41).
</p>

<a id="figura-41"></a>

**Figura 41. Cantidad total vendida por producto.**

<p align="center">

  <img src="img/total_venta_producto.png" alt="Cantidad total vendida por producto" width="650">

</p>

*Descripción: unidades vendidas por producto.*

#### 7.8.4. Cantidad enviada por mes de envío

<p align="justify">
En este caso dim_date se unió por la fecha de envío. Diciembre de 2022 fue el mes con más unidades enviadas, con 18 (Figura 42).
</p>

<a id="figura-42"></a>

**Figura 42. Cantidad enviada por mes de envío.**

<p align="center">

  <img src="img/cantidad_envio_mes.png" alt="Cantidad enviada por mes de envío" width="650">

</p>

*Descripción: unidades enviadas por año y mes.*

#### 7.8.5. Ventas por tamaño de producto y estado civil del cliente

<p align="justify">
La combinación con más ventas es Medium y Married (23 714) y la de menos es Small y Single (2 264). En todos los tamaños los casados compraron más que los solteros (Figura 43).
</p>

<a id="figura-43"></a>

**Figura 43. Ventas por tamaño de producto y estado civil del cliente.**

<p align="center">

  <img src="img/venta_producto_estado_civil.png" alt="Ventas por tamaño de producto y estado civil" width="650">

</p>

*Descripción: ventas por tamaño y estado civil.*

---

## 8. Scripts SQL entregables

- **Creación de tablas (DDL):** [crear_tablas.sql](scripts/crear_tablas.sql)
- **Limpieza y carga (DML):** [limpieza_carga.sql](scripts/limpieza_carga.sql)
- **Consultas de negocio:** [consultas_analisis.sql](scripts/consultas_analisis.sql)

---

## 9. Relación con una arquitectura Data Warehouse

<p align="justify">
stg_products y stg_ventas corresponden al área de staging, donde los datos se revisan y limpian sin modificar las fuentes. Las dimensiones y la tabla de hechos forman la capa de presentación, con datos validados, restricciones de integridad y claves sustitutas propias. Con products.csv solo se llegó a la dimensión porque no hay un evento que medir; con la tabla de ventas se completó el esquema estrella, donde fact_sales guarda las medidas y las dimensiones dan el contexto para analizarlas.
</p>

---

## 10. Conclusiones

1. El área de staging permitió validar los datos antes de cargarlos; en ambos procesos los conteos coincidieron con las fuentes.
2. La limpieza eliminó tabulaciones y espacios repetidos, aunque el orden de btrim y regexp_replace dejó un espacio inicial en un registro.
3. Las claves sustitutas independizan el modelo de los códigos de la fuente, que se conservan como referencia.
4. Mantener categoría y subcategoría en la dimensión permite agrupar y filtrar sin uniones adicionales.
5. Las preguntas de negocio requerían un evento medible, por lo que se construyó un esquema estrella de ventas con una dimensión de fecha usada para el pedido y para el envío.

---

## 11. Referencias bibliográficas

[1] Escuela Politécnica Nacional, *Guía de Práctica 4: Implementación física de una dimensión para un modelo estrella en PostgreSQL*, Facultad de Ingeniería de Sistemas, Business Intelligence, 2026.

[2] R. Kimball y M. Ross, *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling*, 3.ª ed. Indianapolis, IN, EE. UU.: John Wiley & Sons, 2013.

[3] R. Kimball y J. Caserta, *The Data Warehouse ETL Toolkit: Practical Techniques for Extracting, Cleaning, Conforming, and Delivering Data*. Indianapolis, IN, EE. UU.: John Wiley & Sons, 2004.

[4] The PostgreSQL Global Development Group, "COPY," *PostgreSQL Documentation*. [En línea]. Disponible en: https://www.postgresql.org/docs/current/sql-copy.html

[5] The PostgreSQL Global Development Group, "String Functions and Operators," *PostgreSQL Documentation*. [En línea]. Disponible en: https://www.postgresql.org/docs/current/functions-string.html

---

## 12. Declaración de uso de Inteligencia Artificial

Se declara un uso estimado del **35 % de inteligencia artificial generativa** (Claude, de Anthropic) como apoyo en la redacción y organización del informe. El diseño del modelo, los scripts SQL, la carga de datos, las consultas, el diagrama en Power Pivot y las capturas fueron realizados por los integrantes del grupo.
