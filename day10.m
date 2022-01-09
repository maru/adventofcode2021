#import "utils.h"

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    long sum_errors = 0;
    NSMutableArray *scores = [[NSMutableArray alloc] init];
    for (NSString *line in lines) {
        NSMutableArray *st = [[NSMutableArray alloc] init];
        BOOL stop_processing = NO;
        for (long i = 0; i < line.length && !stop_processing; i++) {
            char c = [line characterAtIndex:i], prev_c = 'x';
            switch (c) {
                case '(': case '[': case '{': case '<':
                    [st addObject:@(c)];
                    break;
                case ')': case ']': case '}': case '>':
                    NSCAssert([st count] > 0, @"No chars in stack");
                    prev_c = [[st objectAtIndex:([st count] - 1)] charValue];
                    [st removeLastObject];

                    if ((c == ')' && prev_c == '(') ||
                        (c == ']' && prev_c == '[') ||
                        (c == '}' && prev_c == '{') ||
                        (c == '>' && prev_c == '<'))
                        continue;

                    // Wrong closing bracket
                    stop_processing = YES;
                    if (c == ')') sum_errors += 3;
                    if (c == ']') sum_errors += 57;
                    if (c == '}') sum_errors += 1197;
                    if (c == '>') sum_errors += 25137;
                    break;
            }
        }
        if (stop_processing) continue;

        // Find the missing brackets
        long autocomplete_score = 0;
        while ([st count]) {
            char c = [[st objectAtIndex:([st count] - 1)] charValue];
            [st removeLastObject];
            autocomplete_score *= 5;
            if (c == '(') autocomplete_score += 1;
            if (c == '[') autocomplete_score += 2;
            if (c == '{') autocomplete_score += 3;
            if (c == '<') autocomplete_score += 4;
        }
        [scores addObject:@(autocomplete_score)];
    }
    NSArray *sorted = [scores sortedArrayUsingSelector: @selector(compare:)];
    long winner_score = [sorted[[sorted count]/2] longValue];

    NSLog(@"(1) answer: %ld", sum_errors);
    NSLog(@"(2) answer: %ld", winner_score);
    return 0;
}
