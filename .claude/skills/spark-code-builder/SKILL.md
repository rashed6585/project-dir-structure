---
name: spark-code-builder
description: Generate a new PySpark analysis script for the spark-node layer. Use when the user says "create spark script", "build spark node", "new spark pipeline", or asks to add a new PySpark analysis module to backend/src/data-pipeline/spark-node/.
argument-hint: <script_name.py> "<one-line description of what it does>"
---

# /spark-code-builder — Generate a PySpark Spark-Node Script

Generate a new PySpark script in `backend/src/data-pipeline/spark-node/` following project conventions.

**Arguments:** `$ARGUMENTS`

---

## Steps

1. Parse `$ARGUMENTS`: extract `<script_name.py>` and the description string.
   - If no script name provided, show usage and stop:
     ```
     Usage: /spark-code-builder <script_name.py> "<description of what this pipeline does>"
     ```

2. If the description is ambiguous, clarify before writing any code:
   - What Hive source table(s) does it read from?
   - What output table(s) and partition key does it write to?
   - What are the KPI columns or grouping dimensions?
   - Does it need period comparisons, window functions, or sampling logic?

3. Create `backend/src/data-pipeline/spark-node/<script_name.py>` using the **canonical structure** documented below. Use `example_spark_node.py` in this skill directory as a runnable reference template.

4. If new config keys are required, add them to `backend/configs/spark_node_data_config.yaml` under a new appropriately-named section. Never add pipeline-specific keys to `default:`.

5. If requested, register the new pipeline function call in `backend/src/data-pipeline/spark_data_processor.py` following the existing `if RUN_*:` switch pattern.

6. Report the output file path and any config keys added.

---

## Canonical Script Structure

### 1. Imports
```python
import sys
from pathlib import Path

import yaml
from pyspark.sql import DataFrame, functions as F, types as T

sys.path.insert(0, str(Path(__file__).parents[2]))
from utils.logger import get_logger
from utils.spark_session import get_spark

sys.path.insert(0, str(Path(__file__).parents[1]))
from utils.spark_utils import update_partition
```
- Always `from pyspark.sql import functions as F` and `types as T` — never import individual functions.
- `parents[2]` resolves to `backend/src/` (for `utils.logger`, `utils.spark_session`).
- `parents[1]` resolves to `backend/src/data-pipeline/` (for `utils.spark_utils`).

### 2. Config Loading (module level, run once)
```python
_CONFIG_PATH = Path(__file__).parents[3] / "configs" / "spark_node_data_config.yaml"
with open(_CONFIG_PATH) as _f:
    _raw = yaml.safe_load(_f)

_default_cfg = _raw["default"]
_pipeline_cfg = _raw["<your_section>"]
```
Never hard-code table names, schema names, thresholds, or file paths. Derive all constants from config.

### 3. Module-Level Constants
```python
logger = get_logger(__name__, _default_cfg["log_file_name"])

TABLE_SOURCE = f"{_pipeline_cfg['schema_hive']}.{_pipeline_cfg['table_source']}"
TABLE_OUT    = f"{_pipeline_cfg['schema_hive']}.{_pipeline_cfg['table_out']}"
MIN_COUNT    = _pipeline_cfg["min_count"]
RETENSION    = _pipeline_cfg["retension"]
```

### 4. Transformation Functions (pure — no I/O)
```python
def _transform_name(df: DataFrame, ...) -> DataFrame:
    """One-line docstring only when input/output schema is non-obvious."""
    return (
        df.filter(...)
        .withColumn(...)
        .select(...)
    )
```
Rules:
- Each private function (`_`) takes and returns a DataFrame. No side effects.
- No `.show()`, `.collect()`, `print()`, or `logger` calls inside transform functions.
- Alias both sides before a join: `df1.alias("a")`, `df2.alias("b")`.
- Always specify `how=` join type explicitly.
- Use `F.col("name")` in conditions and transforms; string literals only in `.select([...])`.
- Keep function count minimal — this is an analysis script, not a library.

### 5. Pipeline Entry Function (only public function)
```python
def <pipeline_name>(execution_date: str) -> None:
    from datetime import datetime
    datetime.strptime(execution_date, "%Y%m%d")  # validate format early
    logger.info(f"[pipeline] Starting <pipeline_name> for date: {execution_date}")

    spark = get_spark()
    df_raw  = spark.table(TABLE_SOURCE).filter(F.col("pdate") == execution_date)
    df_out  = _transform_name(df_raw)
    df_out  = df_out.withColumn("pdate", F.lit(execution_date))

    update_partition(spark, df_out, TABLE_OUT, execution_date, MIN_COUNT, RETENSION)
    logger.info(f"[pipeline] Complete for date: {execution_date}")
```
All reads, writes, and logger calls live in the pipeline function. Transformations are delegated to `_` helpers.

### 6. No `__main__` block
Scripts are imported by `spark_data_processor.py` — never add `if __name__ == "__main__":`.

---

## PySpark Coding Rules

**Column references**
- `F.col("name")` for all conditions, `withColumn`, `orderBy`, `groupBy`.
- String literals only inside `.select(["col1", "col2"])`.

**Performance**
- No `.collect()`, `.toPandas()`, or `.show()` on large DataFrames in production paths.
- Filter and project early — push `.select()` and `.filter()` before joins.
- Use `F.broadcast()` explicitly for small-dimension lookup tables.
- `cache()` / `persist()` only when a DataFrame is reused multiple times; always `unpersist()` after.
- Prefer native Spark functions over Python UDFs. If a UDF is unavoidable, use `pandas_udf` (vectorized).
- Watch for skew on telecom keys (cell ID, MSISDN) — salt keys if aggregation is severely skewed.

**Schema & data quality**
- Define explicit `StructType` schemas for CSV/JSON sources; never use `inferSchema`.
- Handle nulls explicitly with `F.coalesce`, `.fillna()`, or `.na.drop()` — don't let them propagate silently.
- Use `.dropDuplicates(subset=[...])` with explicit columns, not bare `.distinct()`.
- Validate row counts after major transforms, especially after joins (fan-out check).

**Joins & aggregations**
- Always specify `how=` (`"left"`, `"inner"`, `"left_semi"`, etc.).
- Alias both DataFrames before joining.
- Use `Window.partitionBy().orderBy()` for per-entity or time-series calculations; avoid manual self-joins.

**Style**
- Chain transforms with parentheses; one operation per line.
- Name intermediate DataFrames descriptively: `df_filtered`, `df_enriched`, `df_with_kpi`.
- No markdown, no unnecessary comments, no `print()`.
- Reuse `df` only in a clear linear pipeline; otherwise use distinct names.

---

## Config YAML Convention

New sections follow this shape (add to `backend/configs/spark_node_data_config.yaml`):
```yaml
<section_name>:
  pipeline_process: true
  schema_hive: "BI_TEMP"
  table_source: "TBL_SOURCE_TABLE"
  table_out: "TBL_OUTPUT_TABLE"
  min_count: 100000
  retension: 7
```
- `pipeline_process: true/false` — toggle without touching `spark_data_processor.py`.
- `retension` (project spelling) — days of partitions to retain; `null` disables cleanup.
- `min_count` — sanity threshold; `update_partition` raises `RuntimeError` if row count is below this.
