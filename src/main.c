#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/multicore.h"
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

const int task_delay = 500;
const int task_size = 128;

SemaphoreHandle_t mutex;

void vGuardedPrint(char *out)
{
    xSemaphoreTake(mutex, portMAX_DELAY);
    puts(out);
    xSemaphoreGive(mutex);
}

void vTaskSMP_print_core(void *pvParameters)
{
    char *task_name = pcTaskGetName(NULL);
    char out[12];

    for (;;) {
        sprintf(out, "%s %d", task_name, get_core_num());
        vGuardedPrint(out);
        vTaskDelay(task_delay);
    }
}

int main()
{
    stdio_init_all();

    mutex = xSemaphoreCreateMutex();    // Create the mutex

    TaskHandle_t handleA;
    TaskHandle_t handleB;

    // create 4x tasks with different names & 2 with handles
    xTaskCreate(vTaskSMP_print_core, "A", task_size, NULL, 1, &handleA);
    xTaskCreate(vTaskSMP_print_core, "B", task_size, NULL, 1, &handleB);
    xTaskCreate(vTaskSMP_print_core, "C", task_size, NULL, 1, NULL);
    xTaskCreate(vTaskSMP_print_core, "D", task_size, NULL, 1, NULL);

    // Pin Tasks
    vTaskCoreAffinitySet(handleA, (1 << 0));
    vTaskCoreAffinitySet(handleB, (1 << 1));

    vTaskStartScheduler();
    while(1){};
}