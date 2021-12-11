#import <Foundation/Foundation.h>
#import "utils.h"

int main(int argc, const char * argv[]) {

    NSString *input = getInputFromStdin();

    NSInteger depth = 0;
    NSInteger inc = 0, win3_inc = 0;
    NSInteger d1 = 1<<16, d2 = 1<<16, d3 = 1<<16;

    NSScanner *scanner = [[NSScanner alloc] initWithString:input];
    while ([scanner scanInteger:&depth]) {
        // (1)
        if (d3 < depth) {
            inc++;
        }

        // (2)
        if (d1 + d2 + d3 < d2 + d3 + depth) {
            win3_inc++;
        }
        d1 = d2; d2 = d3; d3 = depth;
    }
    NSLog(@"(1) answer: %tu", inc);
    NSLog(@"(2) answer: %tu", win3_inc);

    return 0;
}
