#if !defined(UTILS_H)
#define UTILS_H

#include "FreeRTOS.h"
#include "task.h"

#define unused(v) (void)(v)
#define forever for(;;)
#define hold_ms(ms) (vTaskDelay(pdMS_TO_TICKS((ms))))
#define flip(b) do { (b) = !(b); } while (0)

// Returns the count of ticks since vTaskStartScheduler was called
static inline unsigned long since_start_ticks(void) 
{
    return (unsigned long)xTaskGetTickCount();
}

// Returns the time in ms since vTaskStartScheduler was called
static inline unsigned long since_start_ms(void) 
{
    return (unsigned long)xTaskGetTickCount() * portTICK_PERIOD_MS;
}


typedef uint8_t     u8;
typedef uint16_t    u16;
typedef uint32_t    u32;
typedef uint64_t    u64;

typedef int8_t      s8;
typedef int16_t     s16;
typedef int32_t     s32;
typedef int64_t     s64;

#endif // UTILS_H
