# 🏎️ Formula 1 Data Pipeline: ETL & DBT Analysis

Este repositorio contiene un proyecto de Ingeniería de Datos end-to-end centrado en el análisis de telemetría y sesiones de Fórmula 1. Implementa un pipeline de extracción incremental, almacenamiento en base de datos relacional y transformación moderna utilizando **DBT**.

El sistema está diseñado para interactuar con la **OpenF1 API**, optimizando la ingesta de datos y preparando vistas analíticas para su posterior consumo.

---

## 📋 Tabla de Contenidos

1. [Descripción del Proyecto](#descripción-del-proyecto)
2. [Stack Tecnológico](#stack-tecnológico)
3. [Arquitectura y Flujo de Datos](#arquitectura-y-flujo-de-datos)
    - [1. Extracción de Datos (Incremental)](#1-extracción-de-datos-incremental)
    - [2. Carga de Datos (Raw)](#2-carga-de-datos-raw)
    - [3. Transformación (DBT)](#3-transformación-dbt)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Instalación y Ejecución](#instalación-y-ejecución)

---

## 📖 Descripción del Proyecto

El proyecto automatiza el ciclo de vida de los datos de la Fórmula 1, desde su origen en APIs públicas hasta su modelado para análisis. El foco principal es la eficiencia en la carga de datos (evitando descargas redundantes) y la estructuración modular de las transformaciones mediante DBT.

Los datos abarcan desde la temporada 2023 en adelante e incluyen detalles granulares como tiempos de vuelta, información de pilotos y telemetría del coche en tiempo real.

---

## 🛠 Stack Tecnológico

* **Lenguaje Principal:** Python 3.x
* **Librerías Python:**
    * `requests`: Manejo de peticiones HTTP a la API.
    * `pandas`: Manipulación de datos en memoria.
    * `sqlalchemy` & `psycopg2`: Conexión y ORM para base de datos.
* **Base de Datos:** PostgreSQL.
* **Transformación:** DBT (Data Build Tool).
* **Plataforma:** Databricks / Entorno Local.
* **Fuente de Datos:** [OpenF1 API](https://openf1.org/).

---

## 🏗 Arquitectura y Flujo de Datos

El pipeline sigue una estrategia **ELT (Extract, Load, Transform)** dividida en tres etapas críticas:

### 1. Extracción de Datos (Incremental)
Se obtienen datos de los siguientes endpoints de la API:
* `GET /sessions`
* `GET /meetings`
* `GET /drivers`
* `GET /laps`
* `GET /car_data`

**Lógica Incremental:**
Para optimizar tiempos y recursos, el proceso no descarga el histórico completo en cada ejecución.
1.  El script consulta la base de datos para encontrar el último `session_key` y `meeting_key` registrado.
2.  Parametriza las llamadas a la API para solicitar únicamente los registros con identificadores **mayores** a los almacenados.
3.  Resultados: Solo se procesan los datos nuevos generados desde la última ejecución.

### 2. Carga de Datos (Raw)
Los datos extraídos se almacenan en **PostgreSQL** en su formato original ("Raw Data").
* Cada endpoint de la API tiene su propia tabla correspondiente.
* No se aplican limpiezas en esta etapa para garantizar la integridad del dato crudo y permitir reprocesamientos futuros si la lógica de negocio cambia.

### 3. Transformación (DBT)
Utilizando **DBT**, los datos crudos se transforman en información valiosa a través de un linaje de datos claro:

#### Etapa A: Unificación (Staging/Views)
Creación de vistas unificadas mediante `JOINs` para desnormalizar la data. En esta etapa **no se limpia la data**, solo se consolida.

* **Vista `stg_laps_unified`:**
    * Une: `sessions` + `meetings` + `drivers` + `laps`.
    * Permite analizar tiempos de vuelta con contexto del piloto y la pista.
* **Vista `stg_telemetry_unified`:**
    * Une: `sessions` + `meetings` + `drivers` + `car_data`.
    * Consolida la telemetría técnica con los datos de la sesión.

#### Etapa B: Limpieza y Enriquecimiento (Intermediate)
Se aplican reglas de negocio sobre las vistas de staging.
* **Relleno de Datos (Imputation):** Se toma la vista unificada de `Laps` y se procesan los valores nulos o faltantes para asegurar la calidad del dato antes de su uso en reportes o dashboards.

---

## 📂 Estructura del Proyecto

```bash
formula_1/
├── dbt_project/              # Directorio principal de DBT
│   ├── models/
│   │   ├── staging/          # Modelos de vistas unificadas (Joins)
│   │   └── intermediate/     # Modelos de limpieza y transformación
│   └── dbt_project.yml
├── src/                      # Código fuente Python
│   ├── extraction.py         # Script de carga incremental
│   ├── db_connection.py      # Configuración de SQLAlchemy/Postgres
│   └── load.py               # Ingesta a SQL
├── requirements.txt          # Dependencias del proyecto
└── README.md                 # Documentación
