
<p align="center">
  <img src="img/EPN-color.png" alt="Escudo de la Escuela Politécnica Nacional" width="150">
</p>

<h1 align="center">Escuela Politécnica Nacional</h1>

<h2 align="center">Business Intelligence</h2>

**Curso:** GR2SW

**Integrantes:**

- Arroyo Juan
- Echeverria Gabriela
- Sarmiento Néstor
- Villavicencio Michelle

**Fecha:** 13/10/2026

---


## Índice de contenidos

1. [Introducción](#1-introducción)
2. [Objetivos](#2-objetivos)
   - [Objetivo general](#21-objetivo-general)
   - [Objetivos específicos](#22-objetivos-específicos)
3. [Herramientas y tecnologías utilizadas](#3-herramientas-y-tecnologías-utilizadas)
4. [Fuentes de datos utilizadas](#4-fuentes-de-datos-utilizadas)
   - [Flujo 1: Datos de estudiantes](#41-flujo-1-datos-de-estudiantes)
   - [Flujo 2: Fuentes de datos heterogéneas](#42-flujo-2-fuentes-de-datos-heterogéneas)
5. [Problemas identificados en los datos](#5-problemas-identificados-en-los-datos)
   - [Problemas del flujo 1](#51-problemas-del-flujo-1)
   - [Problemas del flujo 2](#52-problemas-del-flujo-2)
6. [Transformaciones aplicadas](#6-transformaciones-aplicadas)
   - [Transformaciones del flujo 1](#61-transformaciones-del-flujo-1)
   - [Transformaciones del flujo 2](#62-transformaciones-del-flujo-2)
7. [Desarrollo de los flujos ETL](#7-desarrollo-de-los-flujos-etl)
   - [Flujo 1: Limpieza y validación de estudiantes](#71-flujo-1-limpieza-y-validación-de-estudiantes)
   - [Flujo 2: Integración de fuentes de datos](#72-flujo-2-integración-de-fuentes-de-datos)
8. [Evidencias y resultados](#8-evidencias-y-resultados)
   - [Resultados del flujo 1](#81-resultados-del-flujo-1)
   - [Resultados del flujo 2](#82-resultados-del-flujo-2)
9. [Relación con una arquitectura Data Warehouse](#9-relación-con-una-arquitectura-data-warehouse)
10. [Conclusiones](#10-conclusiones)
11. [Referencias bibliográficas](#11-referencias-bibliográficas)
12. [Declaración de uso de inteligencia artificial](#12-declaración-de-uso-de-inteligencia-artificial)

---

## 1. Introducción

En el presente informe se documenta el desarrollo de dos procesos ETL (Extract, Transform, Load) utilizando la herramienta **Pentaho Data Integration (Spoon)**, con el propósito de aplicar técnicas de limpieza, transformación, validación e integración de datos.

El primer flujo se enfoca en la limpieza y validación de registros de estudiantes, corrigiendo inconsistencias en nombres, apellidos y fechas. El segundo flujo contempla la integración de información proveniente de dos tipos diferentes de fuentes de datos.

Se describen las fuentes utilizadas, los problemas identificados, las transformaciones realizadas, los flujos desarrollados y los resultados obtenidos, así como su relación con una arquitectura de Data Warehouse.
---

## 2. Objetivos

### 2.1. Objetivo general

Desarrollar procesos ETL mediante Pentaho Data Integration (Spoon) para la limpieza, transformación, validación e integración de datos provenientes de diferentes fuentes, garantizando una mayor calidad y consistencia de la información para su posterior análisis.

### 2.2. Objetivos específicos

- Identificar los problemas de calidad presentes en las fuentes de datos, reconociendo inconsistencias que requieran procesos de limpieza, validación o transformación.

- Implementar dos flujos ETL en Pentaho Data Integration (Spoon): uno orientado a la limpieza y validación de registros de estudiantes y otro a la integración de datos provenientes de fuentes de diferentes tipos.

- Verificar los resultados obtenidos mediante la revisión de los archivos de salida, evaluando la consistencia de los datos procesados y su utilidad dentro de una arquitectura de Data Warehouse.

---

## 3. Fuentes de datos utilizadas

### 3.1. Flujo 1: Datos de estudiantes

Para el primer flujo ETL se utiliza el archivo [Caso Estudiantes Original.xls](fuentes_datos/Caso%20Estudiantes%20Original.xls), una fuente de datos que contiene registros de estudiantes.

Este archivo constituye la fuente de entrada para el proceso de limpieza y validación, en el que se trabajan principalmente los campos correspondientes a nombres, apellidos y fechas, con el propósito de corregir inconsistencias y obtener registros estandarizados.

### 3.2. Flujo 2: Fuentes de datos heterogéneas

Para el segundo flujo ETL se contempla el uso de **dos fuentes de datos de diferentes tipos**, con el objetivo de extraer e integrar información en un mismo proceso.

Las fuentes específicas y sus características se documentarán una vez que sean seleccionadas, considerando sus formatos, estructuras y los datos que se utilizarán para la integración.

---
