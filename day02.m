#import <Foundation/Foundation.h>
#import "utils.h"

int main(int argc, const char * argv[]) {

    NSString *input = getInputFromStdin();

    NSScanner *parser = [[NSScanner alloc] initWithString:input];
    NSInteger units = 0;
    NSString *cmd;
   
    NSInteger hpos1 = 0, depth1 = 0, hpos2 = 0, depth2 = 0, aim = 0;
    while ([parser scanUpToCharactersFromSet: [NSCharacterSet whitespaceCharacterSet] intoString: &cmd]) {
        [parser scanInteger:&units];

        // (1)
        if ([cmd isEqualToString:@"forward"]) {
            hpos1 += units;
            hpos2 += units;
            depth2 += aim*units;
        } else if ([cmd isEqualToString:@"down"]) {
            depth1 += units;
            aim += units;
        } else if ([cmd isEqualToString:@"up" ]) {
            depth1 -= units;
            aim -= units;
        }
        // (2)
    }
    NSLog(@"(1) answer: %tu", hpos1*depth1);
    NSLog(@"(2) answer: %tu", hpos2*depth2);

    return 0;
}
