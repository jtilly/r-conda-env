import pandas as pd

def predict(df):
  """Trivial predict function that returns a sequence 0, 1, ..., n-1."""
  return df.reset_index(drop=True).index.astype(float)
  
def check_pandas_version():
  return(f"The installed Pandas version is {pd.__version__}")
