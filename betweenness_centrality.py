import numpy as np
import pandas as pd
import os
import networkx as nx
# import seaborn as sns
# import matplotlib.pyplot as plt
import pickle
import time

currentpath=os.path.abspath('./')
input_path = currentpath+"/graph_statistics/"
output_path = input_path
f="BRD3187N_chr2_iced_40kb_el.txt";
t0=time.time()
el = pd.read_csv(input_path + f, sep=",",header=None).values
el = el.astype(int)
G = nx.Graph()
G.add_edges_from(el, weight=1)
el_btw=nx.edge_betweenness_centrality(G,k=None,normalized=False)
a=np.array(list(el_btw.keys()))
b=np.array(list(el_btw.values()))
b=np.reshape(b,(-1,1))
c=np.concatenate((a,b),axis=1)
np.savetxt(output_path+f.replace(".txt",'_btw.txt'),c,fmt="%d\t%d\t%f")
# pickle.dump(el_btw,output_path+f.replace(".txt",".pickle"),protocol=pickle.HIGHEST_PROTOCOL)
t_batch=time.time()-t0
print(t_batch)

