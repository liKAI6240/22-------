#ifndef LINE_TRACK_H
#define LINE_TRACK_H

#include "lm_port.h"

typedef struct
{
    int left;       /* 白色线段的左端 */
    int right;      /* 白色线段的右端 */
    float center;   /* 白色线段的中心 */
    uint8 valid;    /* 1：找到线；0：没找到 */
} TrackPoint;

#ifdef __cplusplus
extern "C" {              
#endif

void line_track_scan_row(const uint8 *row,      //这个函数使用 C 的链接规则，让 C++ 代码能正确调用 .c 文件里实现的函数。
                         int width,
                         TrackPoint *result);

#ifdef __cplusplus
}
#endif

#endif