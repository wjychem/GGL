from math import *
import numpy as np
import pandas as pd

####################

wt_edge = pd.read_csv("gene_coeffe.csv")
wt = wt_edge['weight'].values

ever_mask = (wt>0.999) ### Gurantee that for each node, at least one edge exists

N_random_variables, = wt.shape
results = np.empty(N_random_variables)

n_vals = np.ones(N_random_variables).astype(np.int32)
results = np.random.binomial(n_vals, wt)
results[ever_mask] = 1

loc_id = np.arange(N_random_variables)[results==1]

draws = wt_edge.loc[loc_id]
draws.weight = 1

draws.to_csv('gene_connection.csv', index=False)
