#include "FreeRTOS.h"
#include "task.h"

#include <stdio.h>

#include "pico/stdlib.h"
#include "utils.h"

// Blinks the onboard LED and reports over USB CDC.
static void blink_task(void *arg) {
    unused(arg);

    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
    
    forever {
        static bool led_on = 0;

        flip(led_on);
        gpio_put(PICO_DEFAULT_LED_PIN, led_on);
        printf("LED %s (tick %lu) (ms %lu)\n", led_on ? "on" : "off", since_start_ticks(), since_start_ms());
        hold_ms(500u);
    }
}

int main(void) {
    stdio_init_all();

    xTaskCreate(blink_task, "blink", configMINIMAL_STACK_SIZE, NULL, 1, NULL);
    vTaskStartScheduler();

    // Never reached: the scheduler is running.
    forever {
        tight_loop_contents();
    }
}
