#import "utils.h"

NSString *signals_orig[10] = { @"abcefg", @"cf", @"acdeg", @"acdfg", @"bcdf", @"abdfg", @"abdefg", @"acf", @"abcdefg", @"abcdfg" };

char strToMask(NSString *str) {
    char val = 0;
    for (int j = 0; j < [str length]; j++) {
        char c = [str characterAtIndex:j];
        val = val | (1 << (c - 'a'));
    }
    return val;
}
NSString* translate(NSString *str, char res[128]) {
    char array[10] = {0};
    for (int j = 0; j < [str length]; j++) {
        char c = [str characterAtIndex:j];
        array[j] = res[c];
    }
    NSString *t = [NSString stringWithCString:array encoding:NSASCIIStringEncoding];
    return t;
}

long getNumber(NSArray *signals, char res[128]) {
    NSMutableDictionary *signals_to = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        char mask = strToMask(signals[i]);
        [signals_to setObject:@(-1) forKey:@(mask)];
    }

    for (int i = 0; i < 10; i++) {
        char val = strToMask(translate(signals_orig[i], res));
        if ([[signals_to objectForKey:@(val)] integerValue] != -1) return -1;
        signals_to[@(val)] = @(i);
    }

    long number = 0;
    for (int i = 11; i < [signals count]; i++) {
        char val = strToMask(signals[i]);
        long digit = [signals_to[@(val)] integerValue];
        if (digit < 0) return -1;
        number = number*10 + digit;
    }
    return number;
}

long findPermutation(NSArray *signals, char c, char res[128], bool used[128]) {
    if (c > 'g') {
        return getNumber(signals, res);
    }

    for (char d = 'a'; d <= 'g'; d++) {
        if (used[d]) continue;
        used[d] = true;
        res[c] = d;
        long number = findPermutation(signals, c + 1, res, used);
        if (number != -1) return number;
        used[d] = false;
    }
    return -1;
}

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    long count_unique = 0;
    long sum = 0;
    for (NSString *line in lines) {
        NSArray *signals = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (int i = 11; i < [signals count]; i++) {
            NSUInteger len = [signals[i] length];
            if (len == 2 || len == 3 || len == 4 || len == 7) count_unique++;
        }

        char res[128] = {0};
        bool used[128] = {0};
        // This solution is not the most efficient, but given the input size and the number of signals, it is fast enough :)
        long number = findPermutation(signals, 'a', res, used);
        NSCAssert(number != -1, @"not found");
        sum += number;
    }

    NSLog(@"(1) answer: %ld", count_unique);
    NSLog(@"(2) answer: %ld", sum);
    return 0;
}
