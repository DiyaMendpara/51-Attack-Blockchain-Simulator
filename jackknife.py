# jackknife.py

import numpy as np

def jackknife_estimation(data):
    n = len(data)
    estimates = np.zeros(n)

    for i in range(n):
        leave_one_out = np.delete(data, i)
        estimates[i] = np.mean(leave_one_out)

    return estimates

def jackknife_variance(data):
    n = len(data)
    mean_estimate = np.mean(data)
    jackknife_estimates = jackknife_estimation(data)
    variance = (n - 1) * np.mean((jackknife_estimates - mean_estimate) ** 2)
    return variance