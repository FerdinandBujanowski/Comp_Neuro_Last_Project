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
f_Off_distinct = f_P_HA > (f_Off_HA + 5)
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
        elif b_P: # only persistent
            combined_matrix[i, j] = [1., 0., 0.]

        if b_silent: # silent
            combined_matrix[i, j] = [0, 0, 0]
        elif b_saturated: # saturated
            combined_matrix[i, j] = [0.5, 0., 0.5]

def draw_map(data, ax, title=None, colorbar=False):
    im = ax.imshow(data, origin="lower", extent=[min(w_line), max(w_line), min(n_line), max(n_line)], aspect="auto")
    ax.set_xlabel("w_HA")
    ax.set_ylabel("n_HA")
    if colorbar:
        plt.colorbar(im, ax=ax)
    if title is not None:
        ax.set_title(title)


fig, axes = plt.subplots(2, 3)
draw_map(f_Sp_distinct, ax=axes[0, 0], title='f_Sp,HA < (f_Sp,nonHA - 2.5Hz)', colorbar=True)
# draw_map(np.logical_and(f_Sp_sim > 0.5, f_Sp_sim < 1.5), '0.5 < f_Sp,HA/f_Sp,nonHA < 1.5')
draw_map(f_P_distinct, ax=axes[0, 1], title='f_P > (f_Sp,HA + 5Hz)', colorbar=True)
draw_map(f_Off_distinct, ax=axes[0, 2], title='f_P > (f_Sp,HA,Off + 5Hz)', colorbar=True)
# draw_map(f_P_sim, 'f_Sp,HA/f_P')
draw_map(f_Sp_HA, ax=axes[1, 0], title='f_Sp,HA', colorbar=True)
draw_map(f_P_HA, ax=axes[1, 2], title='f_P', colorbar=True)

draw_map(combined_matrix, ax=axes[1, 1], title='Regime Map')

fig.tight_layout()
plt.subplots_adjust(wspace=0.3)
plt.show()