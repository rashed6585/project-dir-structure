---
name: analyze-data
description: Load a dataset from backend/data/processed/, print shape and dtypes, generate descriptive statistics, and flag columns with >10% missing values.
---

Load the dataset at the path the user provides (default: backend/data/processed/).
Using pandas:
1. Print `df.shape`, `df.dtypes`, and `df.describe()`
2. List columns where null % > 10 and suggest a fill strategy
3. Suggest one matplotlib/seaborn chart that best illustrates the distribution

Keep output concise; show code the user can paste into a notebook.
