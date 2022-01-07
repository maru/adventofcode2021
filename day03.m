#import "utils.h"


NSInteger getGeneratorRating(NSInteger num_lines, NSInteger len, NSArray<NSString *> *lines, char maxc, char minc) {
    NSMutableSet *ratings = [NSMutableSet set];
    for (NSInteger i = 0; i < num_lines; i++) {
        [ratings addObject:@(i)];
    }
    for (int index = 0; index < len && [ratings count] > 1; index++) {
        // count 1
        int count_1 = 0;
        for (NSNumber *i in ratings) {
            NSInteger pos = [i integerValue];
            count_1 += ([lines[pos] characterAtIndex:index] == '1');
        }
        // 0 or 1 ?
        char keep_ch = (count_1 >= ([ratings count] + 1)/2) ? maxc : minc;
        NSMutableSet *ratings_new = [NSMutableSet set];
        for (NSNumber *i in ratings) {
            NSInteger pos = [i integerValue];
            if ([lines[pos] characterAtIndex:index] == keep_ch) {
                [ratings_new addObject:@([i integerValue])];
            }
        }
        ratings = ratings_new;
    }
    NSInteger oxygen = 0;
    for (NSNumber *i in ratings) {
        NSInteger o_pos = [i integerValue];
        for (int j = 0; j < lines[o_pos].length; j++) {
            oxygen = (oxygen << 1) + ([lines[o_pos] characterAtIndex:j] == '1' ? 1 : 0);
        }
    }
    return oxygen;
}

int main(int argc, const char * argv[]) {

    NSString *input = getInputFromStdin();
    NSArray<NSString *> *lines = getLines(input);
    NSInteger num_lines = [lines count];
    NSInteger len = lines[0].length;

    NSInteger gamma = 0, epsilon = 0;
    NSInteger oxygen = 0, co2 = 0;

    // (1)
    for (int j = 0; j < len; j++) {
        int count = 0;
        for (int i = 0; i < num_lines; i++) {
            if ([lines[i] characterAtIndex:j] == '1') {
                count++;
            }
        }
        gamma <<= 1;
        epsilon <<= 1;
        if (count >= num_lines/2) {
            gamma++;
        } else {
            epsilon++;
        }
    }

    // (2)
    oxygen = getGeneratorRating(num_lines, len, lines, '1', '0');
    co2 = getGeneratorRating(num_lines, len, lines, '0', '1');

    NSLog(@"(1) answer: %tu", gamma*epsilon);
    NSLog(@"(2) answer: %tu", oxygen*co2);

    return 0;
}
