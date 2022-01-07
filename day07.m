#import "utils.h"

long getNeedFuelConstantRate(NSArray *nums) {
    NSUInteger count = [nums count];
    NSUInteger mid = count/2;

    // Use median if fuel burns at constant rate
    NSInteger median = [nums[mid] integerValue];
    if (count % 2 == 0 && count > 1) {
        median = (median + [nums[mid-1] integerValue])/2;
    }
    long need_fuel = 0;
    for (NSNumber *pos in nums) {
        need_fuel += labs([pos integerValue] - median);
    }
    return need_fuel;
}

long calcFuel(NSArray *nums, NSInteger bestPos) {
    long need_fuel = 0;
    for (NSNumber *pos in nums) {
        long dist = labs([pos integerValue] - bestPos);
        need_fuel += (dist*(dist + 1))/2;
    }
    return need_fuel;
}

long getNeedFuelStepRate(NSArray *nums) {
    NSUInteger count = [nums count];
    NSInteger bestPos = 0;
    double best_pos_tmp = 0;
    for (NSNumber *pos in nums) {
        best_pos_tmp += [pos doubleValue];
    }

    bestPos = lround(best_pos_tmp / count);
    return MIN(calcFuel(nums, bestPos), calcFuel(nums, bestPos - 1));
}

int main(int argc, const char * argv[]) {
    NSString *input = getInputFromStdin();
    NSArray<NSString *> *lines = getLines(input);
    NSMutableCharacterSet *skipChars = [NSMutableCharacterSet characterSetWithCharactersInString:@","];

    NSScanner *scanner = [[NSScanner alloc] initWithString:lines[0]];
    [scanner setCharactersToBeSkipped:skipChars];

    NSMutableArray *nums = [[NSMutableArray alloc] init];
    NSInteger pos;
    while ([scanner scanInteger:&pos]) {
        [nums addObject:@(pos)];
    }
    NSArray *sorted = [nums sortedArrayUsingSelector: @selector(compare:)];

    NSLog(@"(1) answer: %ld", getNeedFuelConstantRate(sorted));
    NSLog(@"(2) answer: %ld", getNeedFuelStepRate(sorted));
    return 0;
}
