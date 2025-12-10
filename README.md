# 🏎️ Proyecto ELT de Datos de Fórmula 1

Este proyecto implementa un proceso **ELT (Extraer, Cargar, Transformar)** para la recopilación, almacenamiento y preparación de datos de la Fórmula 1, obtenidos desde la API de OpenF1. El objetivo final es crear un conjunto de datos limpio y estructurado para el análisis de rendimiento de los pilotos.

---

## 💡 ¿Qué Problema Resuelve?

El proyecto resuelve la necesidad de obtener, almacenar y preparar **datos históricos y recientes de la Fórmula 1** de una manera automatizada y estructurada.

* **Extracción y Carga (EL):** Permite descargar datos brutos de la API de OpenF1 (`https://api.openf1.org/v1`) para varios *endpoints* clave (sesiones, reuniones, pilotos, datos de coche y vueltas). Los datos se cargan y persisten de forma inmediata en una base de datos PostgreSQL, organizados por periodo (año y mes) para facilitar la trazabilidad y el procesamiento por lotes.
* **Transformación (T):** Estos datos crudos son luego transformados utilizando **dbt (data build tool)** con modelos basados en SQL, para crear tablas analíticas que faciliten el desarrollo de *dashboards* y el análisis del rendimiento de los pilotos durante las carreras.

En resumen, transforma datos dispersos de una API en una **fuente única de verdad** lista para el análisis de negocio o deportivo.

---

## 🔗 Endpoints de la API de OpenF1 Utilizados

La extracción de datos se realiza utilizando la API base `https://api.openf1.org/v1`. Cada *endpoint* recibe parámetros de fecha (calculados a partir del Año y Mes de ejecución) o claves específicas de sesión/piloto.

| Endpoint | Uso | Parámetros Clave |
| :--- | :--- | :--- |
| `/sessions` | Obtiene información general de las sesiones de carrera dentro de un periodo. | `date_start`, `date_end` |
| `/meetings` | Obtiene información de las reuniones (eventos/grandes premios) dentro de un periodo. | `date_start`, `date_start`, `year` |
| `/drivers` | Obtiene los detalles de los pilotos que participaron en una sesión específica. | `session_key` |
| `/car_data` | Obtiene datos de telemetría del coche (ej. velocidad) para un piloto/sesión. | `driver_number`, `session_key`, `speed` |
| `/laps` | Obtiene datos de las vueltas completadas por un piloto en una sesión. | `session_key`, `driver_number` |

> **Nota sobre la persistencia:** Los datos extraídos de cada *endpoint* se almacenan en el esquema `raw` de la base de datos PostgreSQL en tablas nombradas según el formato: `[endpoint_nombre]_[AAAA]_[MM]`. Por ejemplo: `sessions_2025_05`.

---

## 🛠️ Stack Técnico Usado

| Categoría | Tecnología | Uso Principal |
| :--- | :--- | :--- |
| **Lenguaje** | **Python** | Lógica de Extracción y Carga (EL). |
| **Librerías Python** | **Pandas** | Manipulación y preparación de datos en memoria. |
| **Librerías Python** | **SQLAlchemy, Psycopg2** | Conexión y operaciones con la base de datos PostgreSQL. |
| **Librerías Python** | **Python-dotenv** | Gestión de variables de entorno. |
| **Base de Datos** | **PostgreSQL** | Almacenamiento de datos crudos (esquema `raw`) y transformados. |
| **Orquestación** | **Apache Airflow** | Programación y monitoreo del flujo de trabajo (DAG). |
| **Contenerización** | **Docker** | Empaquetado y despliegue de la aplicación y Airflow. |
| **Transformación** | **dbt (data build tool)** | Desarrollo de modelos de transformación SQL (no detallado en la ejecución, pero parte del proceso ELT completo). |

---

## 🚀 Instrucciones para Correrlo Localmente

Existen dos métodos principales para ejecutar el proceso: utilizando **Airflow** (para producción/programación) o de forma **manual** (para desarrollo/pruebas).

### Opción 1: Ejecución con Apache Airflow (Recomendado)

Esta opción utiliza Docker para configurar un entorno de Airflow, que se encargará de orquestar la ejecución del script EL.

1.  **Clonar el Repositorio:**
    ```bash
    git clone https://github.com/matiasfeliu92/formula_1.git
    cd formula_1
    ```

2.  **Inicializar Airflow:**
    Ejecuta el siguiente comando para preparar el entorno de Airflow, inicializar la base de datos y crear el usuario administrador.
    ```bash
    docker compose up --build airflow-init
    ```

3.  **Iniciar los Servicios:**
    Inicia Airflow y el resto de los servicios (incluyendo PostgreSQL) en modo *detached* (segundo plano).
    ```bash
    docker compose up --build -d
    ```

4.  **Acceder a la Interfaz de Airflow:**
    Abre tu navegador y navega a la siguiente URL:
    * **URL:** `http://localhost:8085`
    * **Usuario:** `admin`
    * **Contraseña:** `admin`

5.  **Ejecutar el DAG:**
    Una vez en la interfaz de Airflow, busca el DAG del proyecto. Para ejecutarlo:
    * Activa el DAG (si no lo está).
    * Haz clic en el botón de "Play" para iniciar una ejecución manual.
    * El DAG está configurado para recibir dos **parámetros de configuración**: el **Año** y el **Mes** (numérico, e.g., `5` para Mayo) que deseas procesar.

### Opción 2: Ejecución Manual en Entorno Local

Esta opción es ideal para un desarrollo rápido o pruebas puntuales sin la necesidad de la orquestación de Airflow.

1.  **Configurar la Base de Datos:**
    Asegúrate de tener una instancia de **PostgreSQL** corriendo y accesible, y configura las credenciales de conexión en un archivo `.env` o similar.

2.  **Crear y Activar un Entorno Virtual (Recomendado):**
    ```bash
    python -m venv venv
    source venv/bin/activate # En Linux/macOS
    # o .\venv\Scripts\activate # En Windows
    ```

3.  **Instalar Dependencias:**
    Instala todas las librerías necesarias especificadas en tu `requirements.txt`.
    ```bash
    pip install -r requirements.txt
    ```

4.  **Ejecutar el Script Principal:**
    Ejecuta el script `main.py`, pasándole el **Año** y el **Mes** como argumentos de línea de comandos.

    **Ejemplo (Extracción de datos de Mayo de 2025):**
    ```bash
    python main.py 2025 5
    ```
