# Base-de-Datos-y-Big-Data
# Sistema de Gestión de Inventario de Productos en Riesgo de Vencimiento - Hipermercados Tottus S.A.

[![Version](https://img.shields.io/badge/version-v1.0.0-blue.svg)](https://github.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Curso](https://img.shields.io/badge/Curso-Base_de_Datos_Avanzadas_y_Big_Data-green.svg)]()

## 👥 Integrantes del Equipo
* **Cahuana Ramon Alex Javier** (100% participación)
* **Cenas Pérez Italo Reynaldo** (100% participación)
* **Corzo Tafur Robert Martin Gonzalo** (100% participación)
* **Manchego Cepeda Stefano Sebastian** (100% participación)

**Docente:** Chavez Bardales Victor Isaac  
**Institución:** Universidad Privada del Norte (UPN) - Período 2026-2  

---

## 📌 Descripción del Proyecto
Este repositorio contiene la solución analítica integrada de **Inteligencia de Negocios (BI)** y **Big Data** desarrollada para Hipermercados Tottus S.A. La solución permite monitorear y predecir el riesgo de vencimiento de productos perecederos, reduciendo la merma por caducidad y facilitando la derivación oportuna hacia donaciones (ollas comunes/comedores) o venta en comercios aliados.

---

## 📂 Estructura del Repositorio

```text
├── 01_database/            # Scripts DDL para la BD OLTP (TOTTUSMERMA) y Data Mart(DM_Tottus_Merma)
├── 02_etl/                 # Scripts T-SQL de Extracción, Transformación, Limpieza y Carga
├── 03_big_data/            # Scripts Python y PySpark para procesamiento distribuido
├── 04_bi_dashboard/        # Archivo .pbix de Power BI Desktop y capturas del dashboard
├── 05_experimentation/     # Notebooks y logs de experimentos comparativos (EXP-01, EXP-02, EXP-03)
├── 06_data/                # Datasets original (semilla) y procesado en Parquet/CSV
├── .gitignore              # Configuración de exclusión de archivos temporales
├── LICENSE                 # Licencia de uso MIT
└── README.md               # Documentación principal del proyecto
🛠️ Tecnologías Utilizadas
Base de Datos & Data Mart: SQL Server 2022 / 2025

Procesamiento Big Data: Apache Spark 3.5.1 / PySpark (Python 3.11)

Capa Analítica & Dashboards: Power BI Desktop

Orquestación & Scripts: T-SQL, Python (Pandas, PySpark, Faker)

🚀 Instrucciones para Reproducir el Proyecto
1. Configuración de la Base de Datos Relacional y Data Mart
Abrir SQL Server Management Studio (SSMS).

Ejecutar los scripts en el siguiente orden estricto:

Bash
# 1. Crear base de datos OLTP y tablas relacionales
01_database/TOTTUSMERMA_OLTP.sql

# 2. Crear Data Mart (Esquema Estrella OLAP)
01_database/DM_Tottus_Merma_DDL.sql

# 3. Poblar tablas dimensionales iniciales
01_database/inserts_iniciales.sql
2. Ejecución del Proceso ETL
Para ejecutar la extracción, limpieza de datos y carga transaccional en el Data Mart:

Bash
02_etl/ETL_CARGA_TOTTUS.sql
3. Entorno Big Data (PySpark)
Asegurarse de tener instalado Python 3.11+ y Java JDK 11+.

Instalar las dependencias requeridas:

Bash
pip install -r 03_big_data/requirements.txt
Ejecutar el script de generación de datos masivos y procesamiento:

Bash
python 03_big_data/generate_big_data.py
python 03_big_data/Spark_Streaming_Ingest.py
4. Visualización del Dashboard en Power BI
Abrir el archivo 04_bi_dashboard/Dashboard_Tottus_Merma.pbix en Power BI Desktop.

Actualizar el origen de datos hacia la instancia local de SQL Server (DM_Tottus_Merma).

📊 Paquete Experimental
Los notebooks de ejecución y métricas comparativas entre SQL Server (T-SQL) y PySpark se encuentran documentados en la carpeta 05_experimentation/Experimentation_Spark.ipynb.