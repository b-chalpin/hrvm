import random

NUM_SAMPLES = 100
STEPS_PER_INHALE = 2    # NOTE: an inhale is normally 1 to 2 seconds, so this makes one sample about 0.5 to 1 seconds long I guess

CHANGE_STATE_THRESHOLD = 0.97

BASELINE_HEART_RATE = 70
BASELINE_HEART_RATE_STRESSED = 75

INHALE_VARIABILITY = 10
EXHALE_VARIABILITY = 7
STRESSED_VARIABILITY = 3

def generate_and_print():
    inhale_steps = 0
    is_stressed = False
    with open('out.txt', 'a') as fwrite:
        fwrite.write("===========NOT STRESSED===========\n")
        
        for x in range(NUM_SAMPLES + 1):
            # Get the current offset
            offset = random.random()
            offset = offset * 2 - 1

            # Process the offset with the different states
            if is_stressed:
                fwrite.write(f'{BASELINE_HEART_RATE_STRESSED + offset * STRESSED_VARIABILITY}\n')
            else:
                if inhale_steps < STEPS_PER_INHALE:
                    # Inhale State
                    fwrite.write(f'{BASELINE_HEART_RATE + offset * INHALE_VARIABILITY}\n')
                else:
                    # Exhale State
                    fwrite.write(f'{BASELINE_HEART_RATE + offset * EXHALE_VARIABILITY}\n')
                inhale_steps = (inhale_steps + 1) % (STEPS_PER_INHALE * 2)

            if x > 50:
                # Change the state
                change_state_rand = random.random()
                print(change_state_rand)
                if change_state_rand > CHANGE_STATE_THRESHOLD:
                    is_stressed = not is_stressed
                    if is_stressed:
                        fwrite.write("=============STRESSED=============\n")
                    else:
                        fwrite.write("===========NOT STRESSED===========\n")


if __name__ == '__main__':
    generate_and_print()
