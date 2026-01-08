# monte_carlo.py

import numpy as np

def monte_carlo_simulation(attack_power, confirmation_blocks, runs):
    success_count = 0

    for _ in range(runs):
        honest_power = 100 - attack_power
        success_probability = (attack_power / honest_power) ** confirmation_blocks
        
        if np.random.rand() < success_probability:
            success_count += 1

    return success_count / runs