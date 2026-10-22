#include "line_track.h"

void line_track_scan_row(const uint8 *row,
                         int width,
                         TrackPoint *result)
{
    int x = 0;

    /* 每次扫描前，先标记为没有找到 */
    result->left = -1;
    result->right = -1;
    result->center = 0.0f;
    result->valid = 0;

    /* 1. 跳过开头的黑色像素 */
    while (x < width && row[x] != 255)
    {
        x++;
    }

    /* 扫完整行都没有白色，直接结束 */
    if (x == width)
    {
        return;
    }

    /* 2. 记录第一个白色像素的位置 */
    result->left = x;

    /* 3. 继续向右，直到白色线段结束 */
    while (x < width && row[x] == 255)
    {
        x++;
    }

    /* 此时 x 已经离开白色线段，右端需要减 1 */
    result->right = x - 1;

    /* 4. 计算中心，标记结果有效 */
    result->center = (result->left + result->right) * 0.5f;
    result->valid = 1;
}