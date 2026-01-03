import numpy as np
import matplotlib.pyplot as plt

FOLDER = "grid_search_two/"

n_line = None
w_line = None
with open(FOLDER + "grid.txt") as grid:
    [n_line, w_line] = [[float(x) for x in l.split()] for l in grid.readlines()]

def open_dat(path, folder=FOLDER):
    with open(folder + path) as file:
        np_array = np.array([[float(x) for x in l.split(",")] for l in file.readlines()])
        return np_array

print(n_line)
print(w_line)

f_Sp_HA = open_dat("f_Sp_HA.dat")
f_Sp_nonHA = open_dat("f_Sp_non_HA.dat")
f_P_HA = open_dat("f_P_HA.dat")
f_Off_HA = open_dat("f_Off_HA.dat")

f_Sp_distinct = f_Sp_HA < (f_Sp_nonHA + 2.5)
f_P_distinct = f_P_HA > (f_Sp_HA + 5)
silent_regime = f_Sp_HA == 0
saturated_regime = f_Sp_HA > 100

# additional maps
f_Sp_sim = f_Sp_HA/f_Sp_nonHA
f_P_sim = f_Sp_HA/f_P_HA

combined_matrix = np.full(shape=(10, 10, 3), fill_value=[0.5, 0.5, 0.5])
for i in range(10):
    for j in range(10):
        b_Sp = f_Sp_distinct[i, j]
        b_P = f_P_distinct[i, j]
        b_silent = silent_regime[i, j]
        b_saturated = saturated_regime[i, j]

        if b_Sp and b_P: # bistable
            combined_matrix[i, j] = [1., 165/255, 0.]
        elif b_Sp: # only spontaneous
            combined_matrix[i, j] = [0., 1., 0.]
        else: # only persistent
            combined_matrix[i, j] = [1., 0., 0.]

        if b_silent: # silent
            combined_matrix[i, j] = [0, 0, 0]
        elif b_saturated: # saturated
            combined_matrix[i, j] = [0.5, 0., 0.5]

def draw_map(data, title=None):
    plt.imshow(data, origin="lower", extent=[min(w_line), max(w_line), min(n_line), max(n_line)], aspect="auto")
    plt.xlabel("w_HA")
    plt.ylabel("n_HA")
    plt.colorbar()
    if title is not None:
        plt.title(title)
    plt.show()

draw_map(f_Sp_HA-f_Sp_nonHA, 'f_Sp,HA - f_Sp,nonHA')
draw_map(f_Sp_distinct, 'f_Sp,HA < (f_Sp,nonHA - 2.5Hz)')
draw_map(np.logical_and(f_Sp_sim > 0.5, f_Sp_sim < 1.5), '0.5 < f_Sp,HA/f_Sp,nonHA < 1.5')
draw_map(f_P_distinct, 'f_P > (f_Sp,HA + 5Hz)')
draw_map(f_P_sim, 'f_Sp,HA/f_P')

plt.imshow(combined_matrix, origin="lower", extent=[min(w_line), max(w_line), min(n_line), max(n_line)], aspect="auto")
plt.xlabel("w_HA")
plt.ylabel("n_HA")
# plt.colorbar()
plt.show()