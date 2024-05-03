# NE Butterfly Species Similarity Network

`fv.m` and `vlad.m` create Fisher Vector (FV) and Vector of Linearly Aggregated Descriptors (VLAD) encodings for the Leeds Butterfly Dataset, as used in [Network enhancement as a general method to denoise weighted biological networks](https://www.nature.com/articles/s41467-018-05469-x#Sec8).

`encodings.m` generates weighted networks representing butterfly species image (i) euclidean-gaussian similarities and (ii) cosine similarities.

`run_butterfly_network.m` is a replacement for the same function in the [NE Github](https://github.com/wangboyunze/Network_Enhancement).

`plot_networks.ipynb` displays the original and NE networks.
