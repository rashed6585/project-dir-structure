# ruff: noqa: I001
"""
Example spark-node script — canonical skeleton for the spark-code-builder skill.

Replace <section>, TABLE_SOURCE, TABLE_OUT, and the pipeline logic with the
real domain. Do NOT copy comments into production scripts.
"""

import sys
from pathlib import Path

import yaml  # type: ignore
from pyspark.sql import DataFrame, functions as F, types as T  # type: ignore

# ── path wiring (keep this order) ─────────────────────────────────────────────
sys.path.insert(0, str(Path(__file__).parents[2]))
from utils.logger import get_logger  # type: ignore
from utils.spark_session import get_spark  # type: ignore

sys.path.insert(0, str(Path(__file__).parents[1]))
from utils.spark_utils import update_partition  # type: ignore

# ── config ────────────────────────────────────────────────────────────────────
_CONFIG_PATH = Path(__file__).parents[3] / "configs" / "spark_node_data_config.yaml"
with open(_CONFIG_PATH) as _f:
    _raw = yaml.safe_load(_f)

_default_cfg = _raw["default"]
_pipeline_cfg = _raw["<section_name>"]  # replace with real section key

# ── module-level constants ────────────────────────────────────────────────────
logger = get_logger(__name__, _default_cfg["log_file_name"])

TABLE_SOURCE = f"{_pipeline_cfg['schema_hive']}.{_pipeline_cfg['table_source']}"
TABLE_OUT = f"{_pipeline_cfg['schema_hive']}.{_pipeline_cfg['table_out']}"
MIN_COUNT = _pipeline_cfg["min_count"]
RETENSION = _pipeline_cfg["retension"]

# ── column lists (define at top so they're easy to audit) ─────────────────────
_SELECT_COLS = [
    "msisdn",
    "pdate",
    "cell_name",
    # ... add source columns here
]

_FINAL_COLS = [
    "msisdn",
    "cell_name",
    "kpi_value",
    "pdate",
    # ... add output columns here
]


# ── pure transformation functions (no I/O, no side effects) ───────────────────


def _filter_and_select(df: DataFrame, pdate: str) -> DataFrame:
    return df.filter(
        (F.col("pdate") == pdate)
        & F.col("msisdn").isNotNull()
        & (F.length(F.col("msisdn")) == 10)
    ).select(_SELECT_COLS)


def _join_dimension(spark, df_fact: DataFrame) -> DataFrame:
    df_dim = spark.table("bi_temp.VW_SOME_DIMENSION").select(["dim_key", "dim_attr"])
    return (
        df_fact.alias("f")
        .join(
            df_dim.alias("d"), on=F.col("f.cell_name") == F.col("d.dim_key"), how="left"
        )
        .select(
            F.col("f.msisdn"),
            F.col("f.cell_name"),
            F.col("f.pdate"),
            F.col("d.dim_attr"),
        )
    )


def _derive_kpi(df: DataFrame) -> DataFrame:
    return df.withColumn(
        "kpi_value",
        F.round(
            F.when(
                F.col("some_numerator") > 0,
                F.col("some_numerator") / F.col("some_denominator") * 100,
            ).otherwise(F.lit(None).cast(T.DoubleType())),
            4,
        ),
    )


def _aggregate(df: DataFrame) -> DataFrame:
    return df.groupBy("cell_name", "pdate").agg(
        F.count("msisdn").alias("total_devices"),
        F.percentile_approx("kpi_value", 0.50, 1000).alias("median_kpi"),
    )


# ── pipeline entry point ──────────────────────────────────────────────────────


def example_pipeline(execution_date: str) -> None:
    from datetime import datetime

    datetime.strptime(execution_date, "%Y%m%d")  # noqa: DTZ007  # validate format early
    logger.info(f"[pipeline] Starting example_pipeline for date: {execution_date}")

    spark = get_spark()

    df_raw = spark.table(TABLE_SOURCE)
    df_filtered = _filter_and_select(df_raw, execution_date)
    df_enriched = _join_dimension(spark, df_filtered)
    df_with_kpi = _derive_kpi(df_enriched)
    df_out = (
        _aggregate(df_with_kpi)
        .select(_FINAL_COLS)
        .withColumn("pdate", F.lit(execution_date))
    )

    update_partition(spark, df_out, TABLE_OUT, execution_date, MIN_COUNT, RETENSION)
    logger.info(f"[pipeline] example_pipeline complete for date: {execution_date}")
