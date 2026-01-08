# nakamoto.py

def nakamoto_success_probability(attack_power, confirmation_blocks):
    honest_power = 100 - attack_power
    success_probability = (attack_power / honest_power) ** confirmation_blocks
    return min(success_probability, 1.0)  # Cap at 1.0