# %%
import matplotlib.pyplot as plt
import numpy as np

plt.style.use("_mpl-gallery")


def bar(ax):
    # make data
    np.random.seed(3)
    x = 0.5 + np.arange(8)
    y = np.random.uniform(2, 7, len(x))
    # plot
    ax.bar(x, y, width=1, edgecolor="white", linewidth=0.7)
    ax.set(xlim=(0, 8), ylim=(0, 8), xticks=[], yticks=[])


def line(ax):
    # make data
    x = np.linspace(0, 10, 100)
    y = 4 + 2 * np.sin(2 * x)
    # plot
    ax.plot(x, y, linewidth=2.0)
    ax.set(xlim=(0, 8), ylim=(0, 8), xticks=[], yticks=[])


def scatter(ax):
    # make data
    np.random.seed(3)
    x = 4 + np.random.normal(0, 2, 24)
    y = 4 + np.random.normal(0, 2, len(x))
    # size and color:
    sizes = np.random.uniform(15, 80, len(x))
    colors = np.random.uniform(15, 80, len(x))
    # plot
    ax.scatter(x, y, s=sizes, c=colors, vmin=0, vmax=100)
    ax.set(xlim=(0, 8), ylim=(0, 8), xticks=[], yticks=[])


def violin(ax):
    # make data
    np.random.seed(10)
    D = np.random.normal((3, 5, 4), (0.75, 1.00, 0.75), (200, 3))
    # plot
    vp = ax.violinplot(
        D, [2, 4, 6], widths=2, showmeans=False, showmedians=False, showextrema=False
    )
    # styling:
    for body in vp["bodies"]:
        body.set_alpha(0.9)
    ax.set(xlim=(0, 8), ylim=(0, 8), xticks=[], yticks=[])


if __name__ == "__main__":
    fig, axes = plt.subplots(2, 2)
    bar(axes[0, 0])
    scatter(axes[0, 1])
    line(axes[1, 0])
    violin(axes[1, 1])
    fig.savefig("matplotlib-figure.svg")
