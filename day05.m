#import "utils.h"

const int MAX_SIZE = 1000;

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);
    NSMutableCharacterSet *skipChars = [NSMutableCharacterSet characterSetWithCharactersInString:@" ->,"];


    int floor_hv[MAX_SIZE][MAX_SIZE] = {0};
    int floor_diag[MAX_SIZE][MAX_SIZE] = {0};
    for (int num_line = 0; num_line < [lines count]; num_line++) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:lines[num_line]];
        [scanner setCharactersToBeSkipped:skipChars];

        NSInteger x1, x2, y1, y2;
        [scanner scanInteger:&x1];
        [scanner scanInteger:&y1];
        [scanner scanInteger:&x2];
        [scanner scanInteger:&y2];

        long tmp;
        if (x1 > x2 && y1 < y2) {
            tmp = x1; x1 = x2; x2 = tmp;
            tmp = y1; y1 = y2; y2 = tmp;
        } else if (x2 < x1 && y2 < y1) {
            tmp = x1; x1 = x2; x2 = tmp;
            tmp = y1; y1 = y2; y2 = tmp;
        }

        if (y1 == y2) {
            for (long i = MIN(x1, x2); i <= MAX(x1, x2); i++) {
                floor_hv[i][y1]++;
            }
        } else if (x1 == x2) {
            for (long i = MIN(y1, y2); i <= MAX(y1, y2); i++) {
                floor_hv[x1][i]++;
            }
        } else {
            if (x1 <= x2 && y1 >= y2) {
                for (long i = x1, j = y1; i <= x2 && j >= y2; i++, j--) {
                    floor_diag[i][j]++;
                }
            }
            if (x1 <= x2 && y1 <= y2) {
                for (long i = x1, j = y1; i <= x2 && j <= y2; i++, j++) {
                    floor_diag[i][j]++;
                }
            }
        }
    }

    long dangerous_hv = 0, dangerous_all = 0;
    for (long i = 0; i < MAX_SIZE; i++) {
        for (long j = 0; j < MAX_SIZE; j++) {
            if (floor_hv[i][j] >= 2) dangerous_hv++;
            if (floor_hv[i][j] + floor_diag[i][j] >= 2) dangerous_all++;
        }
    }
    NSLog(@"(1) answer: %ld", dangerous_hv);
    NSLog(@"(2) answer: %ld", dangerous_all);
    return 0;
}
