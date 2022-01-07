#import "utils.h"


NSInteger getGeneratorRating(NSArray<NSString *> *lines, char maxc, char minc) {
    NSMutableSet *ratings = [NSMutableSet set];
    for (NSInteger i = 0; i < lines.count; i++) {
        [ratings addObject:@(i)];
    }
    for (int index = 0; index < lines[0].length && [ratings count] > 1; index++) {
        // count 1
        int count_1 = 0;
        for (NSNumber *i in ratings) {
            NSInteger pos = [i integerValue];
            count_1 += ([lines[pos] characterAtIndex:index] == '1');
        }
        // 0 or 1 ?
        char keep_ch = (count_1 >= ([ratings count] + 1)/2) ? maxc : minc;
        NSMutableSet *ratings_new = [NSMutableSet set];
        for (NSNumber *rating in ratings) {
            NSInteger pos = [rating integerValue];
            if ([lines[pos] characterAtIndex:index] == keep_ch) {
                [ratings_new addObject:rating];
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

    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    NSInteger gamma = 0, epsilon = 0;
    NSInteger oxygen = 0, co2 = 0;

    // (1)
    for (int j = 0; j < lines[0].length; j++) {
        int count = 0;
        for (int i = 0; i < lines.count; i++) {
            if ([lines[i] characterAtIndex:j] == '1') {
                count++;
            }
        }
        gamma <<= 1;
        epsilon <<= 1;
        if (count >= lines.count/2) {
            gamma++;
        } else {
            epsilon++;
        }
    }

    // (2)
    oxygen = getGeneratorRating(lines, '1', '0');
    co2 = getGeneratorRating(lines, '0', '1');

    NSLog(@"(1) answer: %tu", gamma*epsilon);
    NSLog(@"(2) answer: %tu", oxygen*co2);

    return 0;
}
